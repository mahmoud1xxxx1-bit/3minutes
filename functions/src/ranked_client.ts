import { randomInt } from "node:crypto";

import { FieldValue, getFirestore } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";

import {
  AUTHORITY_VERSION,
  COLLECTIONS,
  boolValue,
  emptyProgress,
  intValue,
  parseProgress,
  stringValue,
  timestampMillis,
} from "./firestore.js";
import {
  MATCH_DURATION_MS,
  MATCH_GAME_COUNT,
  REGISTRY_VERSION,
  parseEvidence,
  validateEvidence,
} from "./registry.js";
import {
  RANKED_COUNTDOWN_MS,
  RANKED_SUBMISSION_TRANSPORT_GRACE_MS,
  seasonAcceptsNewRankedMatch,
} from "./season_boundary.js";

const OPTIONS = {
  region: "me-central2",
  enforceAppCheck: true,
  timeoutSeconds: 30,
} as const;

function uidOf(uid: string | undefined): string {
  if (!uid) throw new HttpsError("unauthenticated", "Sign-in is required.");
  return uid;
}

function text(value: unknown, name: string): string {
  if (typeof value !== "string" || value.trim().length === 0) {
    throw new HttpsError("invalid-argument", `${name} is required.`);
  }
  return value.trim();
}

function seasonAcceptsRanked(data: Record<string, unknown>, nowMs: number): boolean {
  return seasonAcceptsNewRankedMatch({
    active: data.active === true,
    startsAtMs: timestampMillis(data.startsAt),
    endsAtMs: timestampMillis(data.endsAt),
    nowMs,
  });
}

function requireActiveSubmissionWindow(match: Record<string, unknown>): void {
  const countdownStartedAtMs = timestampMillis(match.countdownStartedAt);
  if (countdownStartedAtMs === null) {
    throw new HttpsError("failed-precondition", "Ranked match has not started.");
  }
  const now = Date.now();
  const playStartedAtMs = countdownStartedAtMs + RANKED_COUNTDOWN_MS;
  if (now < playStartedAtMs) {
    throw new HttpsError("failed-precondition", "Ranked countdown is still running.");
  }
  const latestTransportArrivalMs =
    playStartedAtMs + MATCH_DURATION_MS + RANKED_SUBMISSION_TRANSPORT_GRACE_MS;
  if (now > latestTransportArrivalMs) {
    throw new HttpsError("deadline-exceeded", "Ranked submission window has closed.");
  }
}

function freshMatch(options: {
  seasonId: string;
  playerAId: string;
  playerAName: string;
  playerAAvatarId: string;
  playerBId: string;
  playerBName: string;
  playerBAvatarId: string;
}): Record<string, unknown> {
  return {
    ...options,
    authorityVersion: AUTHORITY_VERSION,
    seed: randomInt(0, 0x7fffffff),
    gameCount: MATCH_GAME_COUNT,
    registryVersion: REGISTRY_VERSION,
    status: "waitingReady",
    readyA: false,
    readyB: false,
    progressA: emptyProgress(),
    progressB: emptyProgress(),
    rematchA: false,
    rematchB: false,
    rematchMatchId: null,
    cancelledBy: null,
    countdownStartedAt: null,
    createdAt: FieldValue.serverTimestamp(),
    updatedAt: FieldValue.serverTimestamp(),
  };
}

export const submitRankedGameResult = onCall(OPTIONS, async (request) => {
  const uid = uidOf(request.auth?.uid);
  const matchId = text(request.data?.matchId, "matchId");
  let item;
  try {
    const parsed = parseEvidence([request.data?.evidence]);
    item = parsed[0]!;
  } catch (error) {
    throw new HttpsError(
      "invalid-argument",
      error instanceof Error ? error.message : "Invalid mini-game evidence.",
    );
  }

  const db = getFirestore();
  const matchRef = db.collection(COLLECTIONS.matches).doc(matchId);
  const evidenceRef = db
    .collection(COLLECTIONS.rankedEvidence)
    .doc(matchId)
    .collection(COLLECTIONS.players)
    .doc(uid);

  return db.runTransaction(async (transaction) => {
    const [matchSnap, evidenceSnap] = await Promise.all([
      transaction.get(matchRef),
      transaction.get(evidenceRef),
    ]);
    const match = matchSnap.data();
    if (!match) throw new HttpsError("not-found", "Match not found.");
    if (intValue(match.authorityVersion) !== AUTHORITY_VERSION) {
      throw new HttpsError("failed-precondition", "Ranked authority is unavailable for this match.");
    }
    if (intValue(match.registryVersion) !== REGISTRY_VERSION) {
      throw new HttpsError("failed-precondition", "Registry version mismatch.");
    }

    const playerAId = stringValue(match.playerAId);
    const playerBId = stringValue(match.playerBId);
    if (uid !== playerAId && uid !== playerBId) {
      throw new HttpsError("permission-denied", "Not a participant.");
    }
    if (match.status === "cancelled" || match.status === "finished") {
      throw new HttpsError("failed-precondition", "Match is already closed.");
    }
    requireActiveSubmissionWindow(match);

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

    transaction.set(
      evidenceRef,
      {
        uid,
        matchId,
        registryVersion: REGISTRY_VERSION,
        evidence: combined,
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
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

export const requestRankedRematch = onCall(OPTIONS, async (request) => {
  const uid = uidOf(request.auth?.uid);
  const matchId = text(request.data?.matchId, "matchId");
  const db = getFirestore();
  const ref = db.collection(COLLECTIONS.matches).doc(matchId);

  return db.runTransaction(async (transaction) => {
    const snap = await transaction.get(ref);
    const data = snap.data();
    if (!data) throw new HttpsError("not-found", "Match not found.");
    const a = stringValue(data.playerAId);
    const b = stringValue(data.playerBId);
    if (uid !== a && uid !== b) throw new HttpsError("permission-denied", "Not a participant.");
    if (typeof data.rematchMatchId === "string") {
      return { matchId: data.rematchMatchId };
    }

    const nextA = uid === a ? true : boolValue(data.rematchA);
    const nextB = uid === b ? true : boolValue(data.rematchB);
    const updates: Record<string, unknown> = {
      rematchA: nextA,
      rematchB: nextB,
      updatedAt: FieldValue.serverTimestamp(),
    };
    let newMatchId: string | null = null;
    if (nextA && nextB) {
      const seasonId = stringValue(data.seasonId);
      if (!seasonId) {
        throw new HttpsError("failed-precondition", "Original ranked match has no season binding.");
      }
      const seasonRef = db.collection(COLLECTIONS.seasons).doc(seasonId);
      const season = (await transaction.get(seasonRef)).data();
      if (!season || !seasonAcceptsRanked(season, Date.now())) {
        throw new HttpsError(
          "failed-precondition",
          "Not enough season time remains for a ranked rematch.",
        );
      }

      const newRef = db.collection(COLLECTIONS.matches).doc();
      newMatchId = newRef.id;
      transaction.create(
        newRef,
        freshMatch({
          seasonId,
          playerAId: a,
          playerAName: stringValue(data.playerAName, "Player"),
          playerAAvatarId: stringValue(data.playerAAvatarId, "default_01"),
          playerBId: b,
          playerBName: stringValue(data.playerBName, "Player"),
          playerBAvatarId: stringValue(data.playerBAvatarId, "default_01"),
        }),
      );
      updates.rematchMatchId = newMatchId;
    }
    transaction.update(ref, updates);
    return { matchId: newMatchId };
  });
});

export const cancelRankedRematch = onCall(OPTIONS, async (request) => {
  const uid = uidOf(request.auth?.uid);
  const matchId = text(request.data?.matchId, "matchId");
  const db = getFirestore();
  const ref = db.collection(COLLECTIONS.matches).doc(matchId);
  await db.runTransaction(async (transaction) => {
    const snap = await transaction.get(ref);
    const data = snap.data();
    if (!data || typeof data.rematchMatchId === "string") return;
    const a = stringValue(data.playerAId);
    const b = stringValue(data.playerBId);
    if (uid !== a && uid !== b) throw new HttpsError("permission-denied", "Not a participant.");
    transaction.update(ref, {
      ...(uid === a ? { rematchA: false } : { rematchB: false }),
      updatedAt: FieldValue.serverTimestamp(),
    });
  });
  return { ok: true };
});

export const syncRankedTicket = onCall(OPTIONS, async (request) => {
  const uid = uidOf(request.auth?.uid);
  const matchId = text(request.data?.matchId, "matchId");
  const db = getFirestore();
  const matchRef = db.collection(COLLECTIONS.matches).doc(matchId);
  const ticketRef = db.collection(COLLECTIONS.matchmaking).doc(uid);
  await db.runTransaction(async (transaction) => {
    const match = (await transaction.get(matchRef)).data();
    if (!match) throw new HttpsError("not-found", "Match not found.");
    if (uid !== match.playerAId && uid !== match.playerBId) {
      throw new HttpsError("permission-denied", "Not a participant.");
    }
    transaction.set(
      ticketRef,
      {
        uid,
        seasonId: stringValue(match.seasonId),
        status: "matched",
        matchId,
        authorityVersion: AUTHORITY_VERSION,
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
  });
  return { ok: true };
});

export const clearRankedTicket = onCall(OPTIONS, async (request) => {
  const uid = uidOf(request.auth?.uid);
  await getFirestore().collection(COLLECTIONS.matchmaking).doc(uid).delete();
  return { ok: true };
});
