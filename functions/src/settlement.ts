import { FieldValue, Timestamp, getFirestore } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";

import {
  AUTHORITY_VERSION,
  COLLECTIONS,
  intValue,
  parseProgress,
  stringValue,
  timestampMillis,
} from "./firestore.js";
import { buildMatchReceipt } from "./match_receipt.js";
import {
  applyRp,
  applyXp,
  compareMatch,
  higherTier,
  resultForPlayer,
  rewardFor,
  tierFor,
  type RankTier,
} from "./policy.js";
import {
  MATCH_DURATION_MS,
  MATCH_GAME_COUNT,
  REGISTRY_VERSION,
  parseEvidence,
  validateEvidence,
} from "./registry.js";
import { advanceSeasonalRecord } from "./season_integrity.js";

const CALLABLE_OPTIONS = {
  region: "me-central2",
  enforceAppCheck: true,
  timeoutSeconds: 60,
} as const;

function requireUid(uid: string | undefined): string {
  if (!uid) throw new HttpsError("unauthenticated", "Sign-in is required.");
  return uid;
}

function requireMatchId(value: unknown): string {
  if (typeof value !== "string" || value.trim().length === 0) {
    throw new HttpsError("invalid-argument", "matchId is required.");
  }
  return value.trim();
}

function storedRankTier(value: unknown, fallback: RankTier): RankTier {
  if (
    value === "bronze" ||
    value === "silver" ||
    value === "gold" ||
    value === "platinum" ||
    value === "diamond" ||
    value === "master" ||
    value === "grandmaster" ||
    value === "legend"
  ) {
    return value;
  }
  return fallback;
}

function settlementPlayer(options: {
  uid: string;
  previousRp: number;
  nextRp: number;
  rpDelta: number;
  previousTier: RankTier;
  nextTier: RankTier;
  xpAwarded: number;
  coinsAwarded: number;
}): Record<string, unknown> {
  return { ...options };
}

export const settleRankedMatch = onCall(CALLABLE_OPTIONS, async (request) => {
  const callerUid = requireUid(request.auth?.uid);
  const matchId = requireMatchId(request.data?.matchId);
  const db = getFirestore();
  const settlementRef = db.collection(COLLECTIONS.rankedSettlements).doc(matchId);
  const matchRef = db.collection(COLLECTIONS.matches).doc(matchId);

  return db.runTransaction(async (transaction) => {
    const [matchSnap, existingSettlement] = await Promise.all([
      transaction.get(matchRef),
      transaction.get(settlementRef),
    ]);
    const match = matchSnap.data();
    if (!match) throw new HttpsError("not-found", "Match not found.");

    const playerAId = stringValue(match.playerAId);
    const playerBId = stringValue(match.playerBId);
    if (callerUid !== playerAId && callerUid !== playerBId) {
      throw new HttpsError("permission-denied", "Not a participant.");
    }
    if (!playerAId || !playerBId || playerAId === playerBId) {
      throw new HttpsError("data-loss", "Invalid match participants.");
    }

    if (existingSettlement.exists) {
      const stored = existingSettlement.data()?.payload;
      if (stored && typeof stored === "object") return stored;
      throw new HttpsError("data-loss", "Settlement record is incomplete.");
    }

    if (intValue(match.authorityVersion) !== AUTHORITY_VERSION) {
      throw new HttpsError(
        "failed-precondition",
        "This match was not created by ranked authority.",
      );
    }
    if (intValue(match.registryVersion) !== REGISTRY_VERSION) {
      throw new HttpsError("failed-precondition", "Registry version mismatch.");
    }
    if (match.status === "cancelled") {
      throw new HttpsError("failed-precondition", "Cancelled matches cannot settle.");
    }

    const seasonId = stringValue(match.seasonId);
    if (!seasonId) {
      throw new HttpsError("failed-precondition", "Ranked match is not bound to a season.");
    }
    const seasonRef = db.collection(COLLECTIONS.seasons).doc(seasonId);
    const seasonSnap = await transaction.get(seasonRef);
    const season = seasonSnap.data();
    if (!season || season.active !== true) {
      throw new HttpsError("failed-precondition", "The match season is already closed.");
    }

    const gameCount = intValue(match.gameCount, MATCH_GAME_COUNT);
    if (gameCount !== MATCH_GAME_COUNT) {
      throw new HttpsError(
        "failed-precondition",
        `Ranked registry v${REGISTRY_VERSION} requires exactly ${MATCH_GAME_COUNT} games.`,
      );
    }
    const seed = intValue(match.seed);
    const progressA = parseProgress(match.progressA);
    const progressB = parseProgress(match.progressB);
    const bothComplete =
      progressA.completedGames >= gameCount && progressB.completedGames >= gameCount;
    const countdownMs = timestampMillis(match.countdownStartedAt);
    const deadlinePassed =
      countdownMs !== null && Date.now() >= countdownMs + 3000 + MATCH_DURATION_MS;
    if (!bothComplete && !deadlinePassed) {
      throw new HttpsError("failed-precondition", "Match is still in progress.");
    }

    const evidenceARef = db
      .collection(COLLECTIONS.rankedEvidence)
      .doc(matchId)
      .collection(COLLECTIONS.players)
      .doc(playerAId);
    const evidenceBRef = db
      .collection(COLLECTIONS.rankedEvidence)
      .doc(matchId)
      .collection(COLLECTIONS.players)
      .doc(playerBId);
    const [evidenceASnap, evidenceBSnap] = await Promise.all([
      transaction.get(evidenceARef),
      transaction.get(evidenceBRef),
    ]);

    let evidenceA;
    let evidenceB;
    try {
      evidenceA = parseEvidence(evidenceASnap.data()?.evidence ?? []);
      evidenceB = parseEvidence(evidenceBSnap.data()?.evidence ?? []);
    } catch (error) {
      throw new HttpsError(
        "data-loss",
        error instanceof Error ? error.message : "Stored evidence is invalid.",
      );
    }

    if (
      !validateEvidence({
        matchSeed: seed,
        gameCount,
        completedGames: progressA.completedGames,
        evidence: evidenceA,
      }) ||
      !validateEvidence({
        matchSeed: seed,
        gameCount,
        completedGames: progressB.completedGames,
        evidence: evidenceB,
      })
    ) {
      throw new HttpsError("failed-precondition", "Ranked evidence failed integrity checks.");
    }

    const resolution = bothComplete
      ? buildMatchReceipt({
          matchId,
          playerAId,
          playerBId,
          evidenceA,
          evidenceB,
        })
      : null;

    const playerARef = db.collection(COLLECTIONS.users).doc(playerAId);
    const playerBRef = db.collection(COLLECTIONS.users).doc(playerBId);
    const inventoryARef = db.collection(COLLECTIONS.inventories).doc(playerAId);
    const inventoryBRef = db.collection(COLLECTIONS.inventories).doc(playerBId);
    const leaderboardARef = db
      .collection(COLLECTIONS.leaderboards)
      .doc(seasonId)
      .collection(COLLECTIONS.entries)
      .doc(playerAId);
    const leaderboardBRef = db
      .collection(COLLECTIONS.leaderboards)
      .doc(seasonId)
      .collection(COLLECTIONS.entries)
      .doc(playerBId);

    const [profileASnap, profileBSnap, inventoryASnap, inventoryBSnap, boardASnap, boardBSnap] =
      await Promise.all([
        transaction.get(playerARef),
        transaction.get(playerBRef),
        transaction.get(inventoryARef),
        transaction.get(inventoryBRef),
        transaction.get(leaderboardARef),
        transaction.get(leaderboardBRef),
      ]);

    const profileA = profileASnap.data();
    const profileB = profileBSnap.data();
    if (!profileA || !profileB) {
      throw new HttpsError("failed-precondition", "Both player profiles must exist.");
    }

    const outcome = compareMatch(progressA, progressB, gameCount);
    if (resolution !== null) {
      const expectedOutcome = resolution.winnerId === playerAId
        ? "playerA"
        : resolution.winnerId === playerBId
          ? "playerB"
          : "tie";
      if (expectedOutcome !== outcome) {
        throw new HttpsError(
          "data-loss",
          "Authoritative progress and detailed evidence disagree on the winner.",
        );
      }
    }
    const resultA = resultForPlayer(outcome, "playerA");
    const resultB = resultForPlayer(outcome, "playerB");
    const rewardA = rewardFor(resultA);
    const rewardB = rewardFor(resultB);

    const previousRpA = intValue(profileA.rankPoints);
    const previousRpB = intValue(profileB.rankPoints);
    const nextRpA = applyRp(previousRpA, rewardA.rpDelta);
    const nextRpB = applyRp(previousRpB, rewardB.rpDelta);
    const previousTierA = tierFor(previousRpA);
    const previousTierB = tierFor(previousRpB);
    const nextTierA = tierFor(nextRpA);
    const nextTierB = tierFor(nextRpB);
    const lifetimePeakA = higherTier(
      storedRankTier(profileA.peakRankTier, previousTierA),
      nextTierA,
    );
    const lifetimePeakB = higherTier(
      storedRankTier(profileB.peakRankTier, previousTierB),
      nextTierB,
    );
    const progressionA = applyXp(
      { level: intValue(profileA.level, 1), xp: intValue(profileA.xp) },
      rewardA.xp,
    );
    const progressionB = applyXp(
      { level: intValue(profileB.level, 1), xp: intValue(profileB.xp) },
      rewardB.xp,
    );

    const inventoryA = inventoryASnap.data() ?? {};
    const inventoryB = inventoryBSnap.data() ?? {};
    const nextCoinsA = Math.max(0, intValue(inventoryA.coins)) + rewardA.coins;
    const nextCoinsB = Math.max(0, intValue(inventoryB.coins)) + rewardB.coins;

    const boardA = boardASnap.data() ?? {};
    const boardB = boardBSnap.data() ?? {};
    const peakTierA = higherTier(
      storedRankTier(boardA.peakTier, previousTierA),
      nextTierA,
    );
    const peakTierB = higherTier(
      storedRankTier(boardB.peakTier, previousTierB),
      nextTierB,
    );

    const lifetimeWinsA = intValue(profileA.wins) + (resultA === "win" ? 1 : 0);
    const lifetimeWinsB = intValue(profileB.wins) + (resultB === "win" ? 1 : 0);
    const lifetimeLossesA = intValue(profileA.losses) + (resultA === "loss" ? 1 : 0);
    const lifetimeLossesB = intValue(profileB.losses) + (resultB === "loss" ? 1 : 0);
    const seasonRecordA = advanceSeasonalRecord(
      {
        wins: intValue(boardA.wins),
        losses: intValue(boardA.losses),
        ties: intValue(boardA.ties),
      },
      resultA,
    );
    const seasonRecordB = advanceSeasonalRecord(
      {
        wins: intValue(boardB.wins),
        losses: intValue(boardB.losses),
        ties: intValue(boardB.ties),
      },
      resultB,
    );
    const settledAt = new Date();

    const payload = {
      matchId,
      seasonId,
      resolution,
      playerA: settlementPlayer({
        uid: playerAId,
        previousRp: previousRpA,
        nextRp: nextRpA,
        rpDelta: nextRpA - previousRpA,
        previousTier: previousTierA,
        nextTier: nextTierA,
        xpAwarded: rewardA.xp,
        coinsAwarded: rewardA.coins,
      }),
      playerB: settlementPlayer({
        uid: playerBId,
        previousRp: previousRpB,
        nextRp: nextRpB,
        rpDelta: nextRpB - previousRpB,
        previousTier: previousTierB,
        nextTier: nextTierB,
        xpAwarded: rewardB.xp,
        coinsAwarded: rewardB.coins,
      }),
      settledAt: settledAt.toISOString(),
    };

    transaction.update(playerARef, {
      rankPoints: nextRpA,
      peakRankTier: lifetimePeakA,
      level: progressionA.level,
      xp: progressionA.xp,
      wins: lifetimeWinsA,
      losses: lifetimeLossesA,
      gamesPlayed: intValue(profileA.gamesPlayed) + 1,
      updatedAt: FieldValue.serverTimestamp(),
    });
    transaction.update(playerBRef, {
      rankPoints: nextRpB,
      peakRankTier: lifetimePeakB,
      level: progressionB.level,
      xp: progressionB.xp,
      wins: lifetimeWinsB,
      losses: lifetimeLossesB,
      gamesPlayed: intValue(profileB.gamesPlayed) + 1,
      updatedAt: FieldValue.serverTimestamp(),
    });

    transaction.set(
      inventoryARef,
      {
        coins: nextCoinsA,
        ownedCosmeticIds: Array.isArray(inventoryA.ownedCosmeticIds)
          ? inventoryA.ownedCosmeticIds
          : [],
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
    transaction.set(
      inventoryBRef,
      {
        coins: nextCoinsB,
        ownedCosmeticIds: Array.isArray(inventoryB.ownedCosmeticIds)
          ? inventoryB.ownedCosmeticIds
          : [],
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );

    const leaderboardBase = (profile: Record<string, unknown>) => ({
      gameName: stringValue(profile.gameName, "Player"),
      avatarId: stringValue(profile.avatarId, "default_01"),
      stars: intValue(profile.stars),
      legendarySeasons: Math.max(0, intValue(profile.legendarySeasons)),
      updatedAt: FieldValue.serverTimestamp(),
    });
    transaction.set(
      leaderboardARef,
      {
        ...leaderboardBase(profileA),
        rankPoints: nextRpA,
        wins: seasonRecordA.wins,
        losses: seasonRecordA.losses,
        ties: seasonRecordA.ties,
        peakTier: peakTierA,
      },
      { merge: true },
    );
    transaction.set(
      leaderboardBRef,
      {
        ...leaderboardBase(profileB),
        rankPoints: nextRpB,
        wins: seasonRecordB.wins,
        losses: seasonRecordB.losses,
        ties: seasonRecordB.ties,
        peakTier: peakTierB,
      },
      { merge: true },
    );

    transaction.create(
      db.collection(COLLECTIONS.coinTransactions).doc(`${matchId}_${playerAId}_reward`),
      {
        uid: playerAId,
        matchId,
        seasonId,
        reason: "matchReward",
        amount: rewardA.coins,
        balanceAfter: nextCoinsA,
        createdAt: Timestamp.fromDate(settledAt),
      },
    );
    transaction.create(
      db.collection(COLLECTIONS.coinTransactions).doc(`${matchId}_${playerBId}_reward`),
      {
        uid: playerBId,
        matchId,
        seasonId,
        reason: "matchReward",
        amount: rewardB.coins,
        balanceAfter: nextCoinsB,
        createdAt: Timestamp.fromDate(settledAt),
      },
    );

    transaction.update(matchRef, {
      status: "finished",
      settledSeasonId: seasonId,
      updatedAt: FieldValue.serverTimestamp(),
    });
    transaction.create(settlementRef, {
      matchId,
      seasonId,
      payload,
      settledAt: Timestamp.fromDate(settledAt),
      createdAt: FieldValue.serverTimestamp(),
    });

    return payload;
  });
});
