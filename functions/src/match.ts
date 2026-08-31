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
import { seasonAcceptsNewRankedMatch } from "./season_boundary.js";
import { parseGoldWager, type GoldWager } from "./wager.js";

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

function requireWager(value: unknown): GoldWager {
  try {
    return parseGoldWager(value);
  } catch (error) {
    throw new HttpsError(
      "invalid-argument",
      error instanceof Error ? error.message : "Invalid Gold wager.",
    );
  }
}

function seasonAcceptsRanked(data: Record<string, unknown>, nowMs: number): boolean {
  return seasonAcceptsNewRankedMatch({
    active: data.active === true,
    startsAtMs: timestampMillis(data.startsAt),
    endsAtMs: timestampMillis(data.endsAt),
    nowMs,
  });
}

function newMatchData(options: {
  seasonId: string;
  playerAId: string;
  playerAName: string;
  playerAAvatarId: string;
  playerBId: string;
  playerBName: string;
  playerBAvatarId: string;
  wagerGold: GoldWager;
}): Record<string, unknown> {
  return {
    ...options,
    authorityVersion: AUTHORITY_VERSION,
    seed: randomInt(0, 0x7fffffff),
    gameCount: MATCH_GAME_COUNT,
    registryVersion: REGISTRY_VERSION,
    goldEscrowStatus: "locked",
    goldEscrowPool: options.wagerGold * 2,
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
  const wagerGold = requireWager(request.data?.wagerGold);
  const db = getFirestore();
  const queue = db.collection(COLLECTIONS.matchmaking);
  const matches = db.collection(COLLECTIONS.matches);
  const ownRef = queue.doc(uid);
  const ownInventoryRef = db.collection(COLLECTIONS.inventories).doc(uid);

  const [activeSeasons, ownInventorySnap] = await Promise.all([
    db.collection(COLLECTIONS.seasons).where("active", "==", true).limit(2).get(),
    ownInventoryRef.get(),
  ]);
  if (activeSeasons.size !== 1) {
    throw new HttpsError("failed-precondition", "Ranked season is unavailable.");
  }
  const ownGold = Math.max(0, intValue(ownInventorySnap.data()?.gold));
  if (ownGold < wagerGold) {
    throw new HttpsError("failed-precondition", "Insufficient Gold for this challenge.");
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
    wagerGold,
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
    if (intValue(candidate.data().wagerGold) !== wagerGold) continue;
    const matchRef = matches.doc();

    try {
      const matchId = await db.runTransaction(async (transaction) => {
        const candidateInventoryRef = db.collection(COLLECTIONS.inventories).doc(candidate.id);
        const [seasonSnap, ownSnap, candidateSnap, ownInventory, candidateInventory] =
          await Promise.all([
            transaction.get(seasonDoc.ref),
            transaction.get(ownRef),
            transaction.get(candidate.ref),
            transaction.get(ownInventoryRef),
            transaction.get(candidateInventoryRef),
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
        if (intValue(own.wagerGold) !== wagerGold || intValue(other.wagerGold) !== wagerGold) {
          throw new Error("wager_mismatch");
        }

        const otherUid = stringValue(other.uid, candidate.id);
        if (otherUid === uid) throw new Error("self_match");

        const ownGoldNow = Math.max(0, intValue(ownInventory.data()?.gold));
        const otherGoldNow = Math.max(0, intValue(candidateInventory.data()?.gold));
        if (ownGoldNow < wagerGold) {
          throw new HttpsError("failed-precondition", "Insufficient Gold for this challenge.");
        }
        if (otherGoldNow < wagerGold) {
          throw new Error("candidate_insufficient_gold");
        }

        const ownAfter = ownGoldNow - wagerGold;
        const otherAfter = otherGoldNow - wagerGold;
        transaction.set(
          ownInventoryRef,
          { gold: ownAfter, updatedAt: FieldValue.serverTimestamp() },
          { merge: true },
        );
        transaction.set(
          candidateInventoryRef,
          { gold: otherAfter, updatedAt: FieldValue.serverTimestamp() },
          { merge: true },
        );

        transaction.create(
          db.collection(COLLECTIONS.goldTransactions).doc(`${matchRef.id}_${uid}_escrow`),
          {
            uid,
            matchId: matchRef.id,
            seasonId,
            reason: "rankedEscrowLock",
            amount: -wagerGold,
            balanceAfter: ownAfter,
            createdAt: FieldValue.serverTimestamp(),
          },
        );
        transaction.create(
          db.collection(COLLECTIONS.goldTransactions).doc(`${matchRef.id}_${otherUid}_escrow`),
          {
            uid: otherUid,
            matchId: matchRef.id,
            seasonId,
            reason: "rankedEscrowLock",
            amount: -wagerGold,
            balanceAfter: otherAfter,
            createdAt: FieldValue.serverTimestamp(),
          },
        );

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
            wagerGold,
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

      return { status: "matched", matchId, wagerGold };
    } catch (error) {
      if (error instanceof HttpsError) throw error;
      continue;
    }
  }

  return { status: "waiting", matchId: null, wagerGold };
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
      const seasonId = stringValue(data.seasonId);
      if (!seasonId) {
        throw new HttpsError("failed-precondition", "Ranked match has no season binding.");
      }
      const season = (await transaction.get(db.collection(COLLECTIONS.seasons).doc(seasonId))).data();
      if (!season || !seasonAcceptsRanked(season, Date.now())) {
        throw new HttpsError(
          "failed-precondition",
          "Not enough season time remains to start this ranked match.",
        );
      }
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
    if (data.status === "cancelled") return;
    if (data.status !== "waitingReady" || data.countdownStartedAt != null) {
      throw new HttpsError("failed-precondition", "Match already started.");
    }

    const wagerGold = requireWager(data.wagerGold);
    if (data.goldEscrowStatus !== "locked") {
      throw new HttpsError("data-loss", "Ranked Gold escrow is not locked.");
    }

    const inventoryARef = db.collection(COLLECTIONS.inventories).doc(playerAId);
    const inventoryBRef = db.collection(COLLECTIONS.inventories).doc(playerBId);
    const [inventoryA, inventoryB] = await Promise.all([
      transaction.get(inventoryARef),
      transaction.get(inventoryBRef),
    ]);
    const goldA = Math.max(0, intValue(inventoryA.data()?.gold)) + wagerGold;
    const goldB = Math.max(0, intValue(inventoryB.data()?.gold)) + wagerGold;

    transaction.set(
      inventoryARef,
      { gold: goldA, updatedAt: FieldValue.serverTimestamp() },
      { merge: true },
    );
    transaction.set(
      inventoryBRef,
      { gold: goldB, updatedAt: FieldValue.serverTimestamp() },
      { merge: true },
    );
    transaction.create(
      db.collection(COLLECTIONS.goldTransactions).doc(`${matchId}_${playerAId}_cancel_refund`),
      {
        uid: playerAId,
        matchId,
        reason: "rankedEscrowCancelRefund",
        amount: wagerGold,
        balanceAfter: goldA,
        createdAt: FieldValue.serverTimestamp(),
      },
    );
    transaction.create(
      db.collection(COLLECTIONS.goldTransactions).doc(`${matchId}_${playerBId}_cancel_refund`),
      {
        uid: playerBId,
        matchId,
        reason: "rankedEscrowCancelRefund",
        amount: wagerGold,
        balanceAfter: goldB,
        createdAt: FieldValue.serverTimestamp(),
      },
    );
    transaction.update(ref, {
      status: "cancelled",
      cancelledBy: uid,
      goldEscrowStatus: "refunded",
      goldEscrowReason: "cancel_before_start",
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
