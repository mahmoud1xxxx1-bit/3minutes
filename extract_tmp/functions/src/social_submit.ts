import { FieldValue, getFirestore } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";

import { COLLECTIONS, intValue, timestampMillis } from "./firestore.js";
import {
  MATCH_DURATION_MS,
  MATCH_GAME_COUNT,
  REGISTRY_VERSION,
  parseEvidence,
  validateEvidence,
} from "./registry.js";

const OPTIONS = {
  region: "me-central2",
  enforceAppCheck: true,
  timeoutSeconds: 30,
} as const;

const COUNTDOWN_MS = 3000;
const SUBMISSION_TRANSPORT_GRACE_MS = 15000;
const EMOTE_COOLDOWN_MS = 2000;

function uidOf(uid: string | undefined): string {
  if (!uid) throw new HttpsError("unauthenticated", "Sign-in is required.");
  return uid;
}

function matchIdOf(value: unknown): string {
  if (typeof value !== "string" || value.trim().length === 0) {
    throw new HttpsError("invalid-argument", "matchId is required.");
  }
  return value.trim();
}

function emoteIdOf(value: unknown): string {
  if (value !== "emote_gg") {
    throw new HttpsError("invalid-argument", "Unsupported emote.");
  }
  return value;
}

function asRecord(value: unknown): Record<string, unknown> {
  return value !== null && typeof value === "object"
    ? (value as Record<string, unknown>)
    : {};
}

function requireActiveSubmissionWindow(match: Record<string, unknown>): void {
  const countdownStartedAtMs = timestampMillis(match.countdownStartedAt);
  if (countdownStartedAtMs === null) {
    throw new HttpsError("failed-precondition", "Social match has not started.");
  }
  const now = Date.now();
  const playStartedAtMs = countdownStartedAtMs + COUNTDOWN_MS;
  if (now < playStartedAtMs) {
    throw new HttpsError("failed-precondition", "Social countdown is still running.");
  }
  const latestTransportArrivalMs =
    playStartedAtMs + MATCH_DURATION_MS + SUBMISSION_TRANSPORT_GRACE_MS;
  if (now > latestTransportArrivalMs) {
    throw new HttpsError("deadline-exceeded", "Social submission window has closed.");
  }
}

export const submitSocialGameResult = onCall(OPTIONS, async (request) => {
  const uid = uidOf(request.auth?.uid);
  const matchId = matchIdOf(request.data?.matchId);
  let item;
  try {
    item = parseEvidence([request.data?.evidence])[0]!;
  } catch (error) {
    throw new HttpsError(
      "invalid-argument",
      error instanceof Error ? error.message : "Invalid social evidence.",
    );
  }

  const db = getFirestore();
  const matchRef = db.collection(COLLECTIONS.socialMatches).doc(matchId);
  const evidenceRef = db
    .collection(COLLECTIONS.socialEvidence)
    .doc(matchId)
    .collection(COLLECTIONS.players)
    .doc(uid);

  return db.runTransaction(async (transaction) => {
    const [matchSnap, evidenceSnap] = await Promise.all([
      transaction.get(matchRef),
      transaction.get(evidenceRef),
    ]);
    const match = matchSnap.data();
    if (!match) throw new HttpsError("not-found", "Social match not found.");
    if (intValue(match.registryVersion) !== REGISTRY_VERSION) {
      throw new HttpsError("failed-precondition", "Registry version mismatch.");
    }
    const order = Array.isArray(match.participantOrder)
      ? match.participantOrder.filter((value): value is string => typeof value === "string")
      : [];
    if (!order.includes(uid)) {
      throw new HttpsError("permission-denied", "Not a social match participant.");
    }
    const gameCount = intValue(match.gameCount, MATCH_GAME_COUNT);
    if (gameCount !== MATCH_GAME_COUNT) {
      throw new HttpsError("failed-precondition", "Unexpected social game count.");
    }
    requireActiveSubmissionWindow(match);

    let previous;
    try {
      previous = parseEvidence(evidenceSnap.data()?.evidence ?? []);
    } catch {
      throw new HttpsError("data-loss", "Stored social evidence is invalid.");
    }
    if (item.gameIndex !== previous.length) {
      throw new HttpsError("failed-precondition", "Social game result is out of order.");
    }
    const combined = [...previous, item];
    const seed = intValue(match.seed);
    if (!validateEvidence({
      matchSeed: seed,
      gameCount,
      completedGames: combined.length,
      evidence: combined,
    })) {
      throw new HttpsError("invalid-argument", "Social mini-game evidence failed integrity checks.");
    }

    const participants = { ...asRecord(match.participants) };
    const participant = asRecord(participants[uid]);
    if (Object.keys(participant).length === 0) {
      throw new HttpsError("data-loss", "Social participant state is missing.");
    }
    const totalScore = combined.reduce((total, entry) => total + entry.score, 0);
    const accuracyTotal = combined.reduce((total, entry) => total + entry.accuracy, 0);
    const mistakes = combined.reduce((total, entry) => total + entry.mistakes, 0);
    const elapsedMs = combined.reduce((total, entry) => total + entry.durationMs, 0);

    participants[uid] = {
      ...participant,
      progress: {
        completedGames: combined.length,
        totalScore,
        accuracyTotal,
        mistakes,
        elapsedMs,
        completedAt: combined.length >= gameCount ? FieldValue.serverTimestamp() : null,
      },
      finishedAt: combined.length >= gameCount ? FieldValue.serverTimestamp() : participant.finishedAt ?? null,
    };

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
      participants,
      updatedAt: FieldValue.serverTimestamp(),
    });
    return { ok: true, completedGames: combined.length };
  });
});

// Shop emotes are cosmetic but still paid/earned entitlements. This callable
// verifies the public loadout that server authority wrote after ownership was
// proven, then writes only the ephemeral emote state. Clients never receive a
// Firestore path that can forge this entitlement.
export const sendSocialEmote = onCall(OPTIONS, async (request) => {
  const uid = uidOf(request.auth?.uid);
  const matchId = matchIdOf(request.data?.matchId);
  const emoteId = emoteIdOf(request.data?.emoteId);
  const db = getFirestore();
  const matchRef = db.collection(COLLECTIONS.socialMatches).doc(matchId);
  const userRef = db.collection(COLLECTIONS.users).doc(uid);

  return db.runTransaction(async (transaction) => {
    const [matchSnap, userSnap] = await Promise.all([
      transaction.get(matchRef),
      transaction.get(userRef),
    ]);
    const match = matchSnap.data();
    const user = userSnap.data();
    if (!match || !user) {
      throw new HttpsError("not-found", "Match or player profile was not found.");
    }
    const order = Array.isArray(match.participantOrder)
      ? match.participantOrder.filter((value): value is string => typeof value === "string")
      : [];
    if (!order.includes(uid)) {
      throw new HttpsError("permission-denied", "Not a social match participant.");
    }
    requireActiveSubmissionWindow(match);

    const loadout = asRecord(user.cosmeticLoadout);
    if (loadout.equippedEmoteId !== emoteId) {
      throw new HttpsError("permission-denied", "This emote is not owned and equipped.");
    }

    const participants = { ...asRecord(match.participants) };
    const participant = asRecord(participants[uid]);
    if (Object.keys(participant).length === 0) {
      throw new HttpsError("data-loss", "Social participant state is missing.");
    }
    const previousEmoteAt = timestampMillis(participant.latestEmoteAt);
    if (previousEmoteAt !== null && Date.now() - previousEmoteAt < EMOTE_COOLDOWN_MS) {
      throw new HttpsError("resource-exhausted", "Emote cooldown is active.");
    }

    participants[uid] = {
      ...participant,
      latestEmoteId: emoteId,
      latestEmoteAt: FieldValue.serverTimestamp(),
    };
    transaction.update(matchRef, {
      participants,
      updatedAt: FieldValue.serverTimestamp(),
    });
    return { ok: true, emoteId };
  });
});
