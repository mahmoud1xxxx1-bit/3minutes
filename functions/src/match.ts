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

const REGION = "me-central2";
const CALLABLE_OPTIONS = {
  region: REGION,
  enforceAppCheck: true,
  timeoutSeconds: 30,
} as const;

function requireUid(uid: string | undefined): string {
  if (!uid) throw new HttpsError("unauthenticated", "Sign-in is required.");
  return uid;
}

function requireString(value: unknown, name: string): string {
  if (typeof value !== "string" || value.trim().length === 0) {
    throw new HttpsError("invalid-argument", `${name} is required.`);
  }
  return value.trim();
}

function seasonAcceptsRanked(data: Record<string, unknown>, nowMs: number): boolean {
  const startsAtMs = timestampMillis(data.startsAt);
  const endsAtMs = timestampMillis(data.endsAt);
  return data.active === true &&
    startsAtMs !== null &&
    endsAtMs !== null &&
    nowMs >= startsAtMs &&
    nowMs < endsAtMs;
}

function newMatchData(options: {
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

export const joinRankedQueue = onCall(CALLABLE_OPTIONS, async (request) => {
  const uid = requireUid(request.auth?.uid);
  const gameName = requireString(request.data?.gameName, "gameName");
  const avatarId = requireString(request.data?.avatarId, "avatarId");
  const db = getFirestore();
  const queue = db.collection(COLLECTIONS.matchmaking);
  const matches = db.collection(COLLECTIONS.matches);
  const ownRef = queue.doc(uid);

  const activeSeasons = await db
    .collection(COLLECTIONS.seasons)
    .where("active", "==", true)
    .limit(2)
    .get();
  if (activeSeasons.size !== 1) {
    throw new HttpsError("failed-precondition", "Ranked season is unavailable.");
  }
  const seasonDoc = activeSeasons.docs[0]!;
  const season = seasonDoc.data();
  if (!seasonAcceptsRanked(season, Date.now())) {
    throw new HttpsError("failed-precondition", "Ranked season is not accepting matches.");
  }
  const seasonId = seasonDoc.id;

  await ownRef.set({
    uid,
    gameName,
    avatarId,
    seasonId,
    status: "waiting",
    matchId: null,
    authorityVersion: AUTHORITY_VERSION,
    createdAt: FieldValue.serverTimestamp(),
    updatedAt: FieldValue.serverTimestamp(),
  });

  const candidates = await queue.where("status", "==", "waiting").limit(20).get();

  for (const candidate of candidates.docs) {
    if (candidate.id === uid) continue;
    if (stringValue(candidate.data().seasonId) !== seasonId) continue;
    const matchRef = matches.doc();

    try {
      const matchId = await db.runTransaction(async (transaction) => {
        const [seasonSnap, ownSnap, candidateSnap] = await Promise.all([
          transaction.get(seasonDoc.ref),
          transaction.get(ownRef),
          transaction.get(candidate.ref),
        ]);
        const liveSeason = seasonSnap.data();
        const own = ownSnap.data();
        const other = candidateSnap.data();
        if (!liveSeason || !seasonAcceptsRanked(liveSeason, Date.now())) {
          throw new HttpsError("failed-precondition", "Ranked season closed before match creation.");
        }
        if (!own || !other) throw new Error("ticket_missing");
        if (own.status !== "waiting" || other.status !== "waiting") {
          throw new Error("ticket_claimed");
        }
        if (intValue(other.authorityVersion) !== AUTHORITY_VERSION) {
          throw new Error("legacy_ticket");
        }
        if (stringValue(own.seasonId) !== seasonId || stringValue(other.seasonId) !== seasonId) {
          throw new Error("season_mismatch");
        }

        const otherUid = stringValue(other.uid, candidate.id);
        if (otherUid === uid) throw new Error("self_match");

        transaction.create(
          matchRef,
          newMatchData({
            seasonId,
            playerAId: otherUid,
            playerAName: stringValue(other.gameName, "Player"),
            playerAAvatarId: stringValue(other.avatarId, "default_01"),
            playerBId: uid,
            playerBName: gameName,
            playerBAvatarId: avatarId,
          }),
        );
        transaction.update(ownRef, {
          status: "matched",
          matchId: matchRef.id,
          updatedAt: FieldValue.serverTimestamp(),
        });
        transaction.update(candidate.ref, {
          status: "matched",
          matchId: matchRef.id,
          updatedAt: FieldValue.serverTimestamp(),
        });
        return matchRef.id;
      });

      return { status: "matched", matchId };
    } catch (error) {
      if (error instanceof HttpsError) throw error;
      continue;
    }
  }

  return { status: "waiting", matchId: null };
});

export const leaveRankedQueue = onCall(CALLABLE_OPTIONS, async (request) => {
  const uid = requireUid(request.auth?.uid);
  const db = getFirestore();
  const ref = db.collection(COLLECTIONS.matchmaking).doc(uid);
  await db.runTransaction(async (transaction) => {
    const snapshot = await transaction.get(ref);
    if (!snapshot.exists) return;
    if (snapshot.data()?.status === "waiting") transaction.delete(ref);
  });
  return { ok: true };
});

export const markRankedReady = onCall(CALLABLE_OPTIONS, async (request) => {
  const uid = requireUid(request.auth?.uid);
  const matchId = requireString(request.data?.matchId, "matchId");
  const db = getFirestore();
  const ref = db.collection(COLLECTIONS.matches).doc(matchId);

  await db.runTransaction(async (transaction) => {
    const snapshot = await transaction.get(ref);
    const data = snapshot.data();
    if (!data) throw new HttpsError("not-found", "Match not found.");
    if (intValue(data.authorityVersion) !== AUTHORITY_VERSION) {
      throw new HttpsError("failed-precondition", "Legacy match cannot become ranked.");
    }
    if (data.status !== "waitingReady") return;

    const playerAId = stringValue(data.playerAId);
    const playerBId = stringValue(data.playerBId);
    if (uid !== playerAId && uid !== playerBId) {
      throw new HttpsError("permission-denied", "Not a participant.");
    }

    const nextReadyA = uid === playerAId ? true : boolValue(data.readyA);
    const nextReadyB = uid === playerBId ? true : boolValue(data.readyB);
    const update: Record<string, unknown> = {
      readyA: nextReadyA,
      readyB: nextReadyB,
      updatedAt: FieldValue.serverTimestamp(),
    };
    if (nextReadyA && nextReadyB && data.countdownStartedAt == null) {
      update.countdownStartedAt = FieldValue.serverTimestamp();
      update.status = "countdown";
    }
    transaction.update(ref, update);
  });

  return { ok: true };
});

export const cancelRankedMatch = onCall(CALLABLE_OPTIONS, async (request) => {
  const uid = requireUid(request.auth?.uid);
  const matchId = requireString(request.data?.matchId, "matchId");
  const db = getFirestore();
  const ref = db.collection(COLLECTIONS.matches).doc(matchId);

  await db.runTransaction(async (transaction) => {
    const snapshot = await transaction.get(ref);
    const data = snapshot.data();
    if (!data) throw new HttpsError("not-found", "Match not found.");
    const playerAId = stringValue(data.playerAId);
    const playerBId = stringValue(data.playerBId);
    if (uid !== playerAId && uid !== playerBId) {
      throw new HttpsError("permission-denied", "Not a participant.");
    }
    if (data.status !== "waitingReady" || data.countdownStartedAt != null) {
      throw new HttpsError("failed-precondition", "Match already started.");
    }
    transaction.update(ref, {
      status: "cancelled",
      cancelledBy: uid,
      updatedAt: FieldValue.serverTimestamp(),
    });
  });

  return { ok: true };
});

export const submitRankedProgress = onCall(CALLABLE_OPTIONS, async (request) => {
  const uid = requireUid(request.auth?.uid);
  const matchId = requireString(request.data?.matchId, "matchId");
  let evidence;
  try {
    evidence = parseEvidence(request.data?.evidence);
  } catch (error) {
    throw new HttpsError(
      "invalid-argument",
      error instanceof Error ? error.message : "Invalid evidence.",
    );
  }

  const db = getFirestore();
  const matchRef = db.collection(COLLECTIONS.matches).doc(matchId);
  const evidenceRef = db
    .collection(COLLECTIONS.rankedEvidence)
    .doc(matchId)
    .collection(COLLECTIONS.players)
    .doc(uid);

  await db.runTransaction(async (transaction) => {
    const [matchSnap, previousEvidenceSnap] = await Promise.all([
      transaction.get(matchRef),
      transaction.get(evidenceRef),
    ]);
    const match = matchSnap.data();
    if (!match) throw new HttpsError("not-found", "Match not found.");
    if (intValue(match.authorityVersion) !== AUTHORITY_VERSION) {
      throw new HttpsError("failed-precondition", "Ranked authority is not enabled for this match.");
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
      throw new HttpsError("failed-precondition", "Match is already settled.");
    }

    const gameCount = intValue(match.gameCount, MATCH_GAME_COUNT);
    const matchSeed = intValue(match.seed);
    if (!validateEvidence({
      matchSeed,
      gameCount,
      completedGames: evidence.length,
      evidence,
    })) {
      throw new HttpsError("invalid-argument", "Mini-game evidence failed integrity checks.");
    }

    const previous = previousEvidenceSnap.data()?.evidence;
    const previousLength = Array.isArray(previous) ? previous.length : 0;
    if (evidence.length < previousLength || evidence.length > previousLength + 1) {
      throw new HttpsError("failed-precondition", "Progress must move forward one game at a time.");
    }

    const totalScore = evidence.reduce((sum, item) => sum + item.score, 0);
    const accuracyTotal = evidence.reduce((sum, item) => sum + item.accuracy, 0);
    const mistakes = evidence.reduce((sum, item) => sum + item.mistakes, 0);
    const elapsedMs = evidence.reduce((sum, item) => sum + item.durationMs, 0);
    const progressField = uid === playerAId ? "progressA" : "progressB";
    const saved = parseProgress(match[progressField]);

    if (saved.completedGames > evidence.length) {
      throw new HttpsError("failed-precondition", "Stored progress is ahead of submitted evidence.");
    }

    const progress = {
      completedGames: evidence.length,
      totalScore,
      accuracyTotal,
      mistakes,
      elapsedMs,
      completedAt:
        evidence.length >= gameCount ? FieldValue.serverTimestamp() : null,
    };

    transaction.set(
      evidenceRef,
      {
        uid,
        matchId,
        registryVersion: REGISTRY_VERSION,
        evidence,
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
    transaction.update(matchRef, {
      [progressField]: progress,
      status: "playing",
      updatedAt: FieldValue.serverTimestamp(),
    });
  });

  return { ok: true, completedGames: evidence.length };
});

export function matchDeadlineMs(countdownStartedAtMs: number): number {
  return countdownStartedAtMs + 3000 + MATCH_DURATION_MS;
}
