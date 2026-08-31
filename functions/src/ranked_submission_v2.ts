import { FieldValue, getFirestore } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";

import { AUTHORITY_VERSION, COLLECTIONS, intValue, parseProgress, stringValue, timestampMillis } from "./firestore.js";
import { MATCH_DURATION_MS, MATCH_GAME_COUNT, REGISTRY_VERSION, parseEvidence, validateEvidence, validateLockedGameIds } from "./registry.js";
import { RANKED_COUNTDOWN_MS, RANKED_SUBMISSION_TRANSPORT_GRACE_MS } from "./season_boundary.js";
import { parseGoldWager } from "./wager.js";

const OPTIONS = {
  region: "me-central2",
  enforceAppCheck: true,
  timeoutSeconds: 30,
} as const;

function requireUid(uid: string | undefined): string {
  if (!uid) throw new HttpsError("unauthenticated", "Sign-in is required.");
  return uid;
}

function requireText(value: unknown, name: string): string {
  if (typeof value !== "string" || value.trim().length === 0) {
    throw new HttpsError("invalid-argument", `${name} is required.`);
  }
  return value.trim();
}

function requireActiveWindow(match: Record<string, unknown>): void {
  const countdownStartedAtMs = timestampMillis(match.countdownStartedAt);
  if (countdownStartedAtMs === null) {
    throw new HttpsError("failed-precondition", "Ranked match has not started.");
  }
  const now = Date.now();
  const playStartedAtMs = countdownStartedAtMs + RANKED_COUNTDOWN_MS;
  if (now < playStartedAtMs) {
    throw new HttpsError("failed-precondition", "Ranked countdown is still running.");
  }
  const lastArrival = playStartedAtMs + MATCH_DURATION_MS + RANKED_SUBMISSION_TRANSPORT_GRACE_MS;
  if (now > lastArrival) {
    throw new HttpsError("deadline-exceeded", "Ranked submission window has closed.");
  }
}

function requireLockedGoldEscrow(match: Record<string, unknown>): void {
  try {
    parseGoldWager(match.wagerGold);
  } catch {
    throw new HttpsError("failed-precondition", "Ranked Gold wager is missing or invalid.");
  }
  if (match.goldEscrowStatus !== "locked") {
    throw new HttpsError("failed-precondition", "Ranked Gold escrow is not locked.");
  }
}

function strings(value: unknown): string[] {
  return Array.isArray(value) ? value.filter((item): item is string => typeof item === "string") : [];
}

export const submitRankedGameResultV2 = onCall(OPTIONS, async (request) => {
  const uid = requireUid(request.auth?.uid);
  const matchId = requireText(request.data?.matchId, "matchId");
  let item;
  try {
    item = parseEvidence([request.data?.evidence])[0]!;
  } catch (error) {
    throw new HttpsError("invalid-argument", error instanceof Error ? error.message : "Invalid mini-game evidence.");
  }

  const db = getFirestore();
  const matchRef = db.collection(COLLECTIONS.matches).doc(matchId);
  const evidenceRef = db.collection(COLLECTIONS.rankedEvidence).doc(matchId).collection(COLLECTIONS.players).doc(uid);

  return db.runTransaction(async (transaction) => {
    const [matchSnap, evidenceSnap] = await Promise.all([
      transaction.get(matchRef),
      transaction.get(evidenceRef),
    ]);
    const match = matchSnap.data();
    if (!match) throw new HttpsError("not-found", "Match not found.");
    if (intValue(match.authorityVersion) !== AUTHORITY_VERSION || intValue(match.registryVersion) !== REGISTRY_VERSION) {
      throw new HttpsError("failed-precondition", "Match contract version mismatch.");
    }
    requireLockedGoldEscrow(match);

    const playerAId = stringValue(match.playerAId);
    const playerBId = stringValue(match.playerBId);
    if (uid !== playerAId && uid !== playerBId) throw new HttpsError("permission-denied", "Not a participant.");
    if (match.status === "cancelled" || match.status === "finished") {
      throw new HttpsError("failed-precondition", "Match is already closed.");
    }
    requireActiveWindow(match);

    const lockedGameIds = strings(match.lockedGameIds);
    if (!validateLockedGameIds(lockedGameIds)) {
      throw new HttpsError("failed-precondition", "The four selected games were not locked correctly.");
    }

    let previous;
    try {
      previous = parseEvidence(evidenceSnap.data()?.evidence ?? []);
    } catch {
      throw new HttpsError("data-loss", "Stored ranked evidence is invalid.");
    }
    if (item.gameIndex !== previous.length) {
      throw new HttpsError("failed-precondition", "Game result is out of order.");
    }

    const combined = [...previous, item];
    const gameCount = intValue(match.gameCount, MATCH_GAME_COUNT);
    const seed = intValue(match.seed);
    if (!validateEvidence({
      matchSeed: seed,
      gameCount,
      completedGames: combined.length,
      evidence: combined,
      lockedGameIds,
    })) {
      throw new HttpsError("invalid-argument", "Mini-game evidence failed integrity checks.");
    }

    const progressField = uid === playerAId ? "progressA" : "progressB";
    const saved = parseProgress(match[progressField]);
    if (saved.completedGames !== previous.length) {
      throw new HttpsError("failed-precondition", "Stored progress and evidence are out of sync.");
    }

    const totalScore = combined.reduce((total, entry) => total + entry.score, 0);
    const accuracyTotal = combined.reduce((total, entry) => total + entry.accuracy, 0);
    const mistakes = combined.reduce((total, entry) => total + entry.mistakes, 0);
    const elapsedMs = combined.reduce((total, entry) => total + entry.durationMs, 0);

    transaction.set(evidenceRef, {
      uid,
      matchId,
      registryVersion: REGISTRY_VERSION,
      lockedGameIds,
      evidence: combined,
      updatedAt: FieldValue.serverTimestamp(),
    }, { merge: true });

    transaction.update(matchRef, {
      [progressField]: {
        completedGames: combined.length,
        totalScore,
        accuracyTotal,
        mistakes,
        elapsedMs,
        completedAt: combined.length >= gameCount ? FieldValue.serverTimestamp() : null,
      },
      status: "playing",
      updatedAt: FieldValue.serverTimestamp(),
    });

    return { ok: true, completedGames: combined.length };
  });
});
