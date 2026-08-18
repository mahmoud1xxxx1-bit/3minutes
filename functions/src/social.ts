import {
  FieldValue,
  Timestamp,
  getFirestore,
  type DocumentData,
} from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";

import { COLLECTIONS, intValue, parseProgress, stringValue } from "./firestore.js";
import {
  MATCH_DURATION_MS,
  MATCH_GAME_COUNT,
  parseEvidence,
  validateEvidence,
  type MiniGameEvidence,
} from "./registry.js";
import type { MatchProgress } from "./policy.js";

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

function objectValue(value: unknown): Record<string, unknown> {
  return value !== null && typeof value === "object"
    ? (value as Record<string, unknown>)
    : {};
}

function progressFromEvidence(evidence: MiniGameEvidence[]): MatchProgress {
  return {
    completedGames: evidence.length,
    totalScore: evidence.reduce((sum, item) => sum + item.score, 0),
    accuracyTotal: evidence.reduce((sum, item) => sum + item.accuracy, 0),
    mistakes: evidence.reduce((sum, item) => sum + item.mistakes, 0),
    elapsedMs: evidence.reduce((sum, item) => sum + item.durationMs, 0),
    completedAtMs: null,
  };
}

function averageAccuracy(progress: MatchProgress): number {
  return progress.completedGames <= 0
    ? 0
    : progress.accuracyTotal / progress.completedGames;
}

function rankParticipants(order: string[], progressByUid: Map<string, MatchProgress>): string[] {
  return [...order].sort((uidA, uidB) => {
    const a = progressByUid.get(uidA)!;
    const b = progressByUid.get(uidB)!;
    const games = b.completedGames - a.completedGames;
    if (games !== 0) return games;
    const score = b.totalScore - a.totalScore;
    if (score !== 0) return score;
    const accuracy = averageAccuracy(b) - averageAccuracy(a);
    if (accuracy !== 0) return accuracy > 0 ? 1 : -1;
    const mistakes = a.mistakes - b.mistakes;
    if (mistakes !== 0) return mistakes;
    const elapsed = a.elapsedMs - b.elapsedMs;
    if (elapsed !== 0) return elapsed;
    return uidA.localeCompare(uidB);
  });
}

function dayId(now: Date): string {
  return now.toISOString().slice(0, 10);
}

function weekId(now: Date): string {
  const date = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate()));
  const day = date.getUTCDay() || 7;
  date.setUTCDate(date.getUTCDate() + 4 - day);
  const start = new Date(Date.UTC(date.getUTCFullYear(), 0, 1));
  const week = Math.ceil((((date.getTime() - start.getTime()) / 86400000) + 1) / 7);
  return `${date.getUTCFullYear()}-W${String(week).padStart(2, "0")}`;
}

function repeatedGroupMultiplier(matchesTodayBeforeThisOne: number): number {
  if (matchesTodayBeforeThisOne < 5) return 1;
  if (matchesTodayBeforeThisOne < 10) return 0.35;
  return 0;
}

function placementBaseCoins(position: number): number {
  if (position === 1) return 20;
  if (position === 2) return 14;
  if (position === 3) return 11;
  return 8;
}

function advanceMission(
  states: Record<string, unknown>,
  id: string,
  target: number,
  window: string,
  delta: number,
): void {
  const previous = objectValue(states[id]);
  const sameWindow = previous.windowId === window;
  const before = sameWindow ? Math.max(0, intValue(previous.progress)) : 0;
  const claimedAt = sameWindow && previous.claimedAt instanceof Timestamp
    ? previous.claimedAt
    : null;
  const progress = Math.min(target, before + delta);
  states[id] = { windowId: window, progress, completed: progress >= target, claimedAt };
}

function advanceAchievement(
  states: Record<string, unknown>,
  id: string,
  target: number,
  progress: number,
  now: Date,
): void {
  const previous = objectValue(states[id]);
  const oldProgress = Math.max(0, intValue(previous.progress));
  const nextProgress = Math.max(oldProgress, Math.min(target, progress));
  const completed = previous.completed === true || nextProgress >= target;
  states[id] = {
    progress: nextProgress,
    completed,
    completedAt: previous.completedAt instanceof Timestamp
      ? previous.completedAt
      : completed
        ? Timestamp.fromDate(now)
        : null,
    rewardClaimedAt: previous.rewardClaimedAt instanceof Timestamp
      ? previous.rewardClaimedAt
      : null,
  };
}

function ensureEvidenceMatchesSavedProgress(
  uid: string,
  evidence: MiniGameEvidence[],
  savedProgressRaw: unknown,
  matchSeed: number,
  gameCount: number,
): MatchProgress {
  const saved = parseProgress(savedProgressRaw);
  if (!validateEvidence({
    matchSeed,
    gameCount,
    completedGames: saved.completedGames,
    evidence,
  })) {
    throw new HttpsError(
      "failed-precondition",
      `Social evidence failed integrity checks for ${uid}.`,
    );
  }
  const derived = progressFromEvidence(evidence);
  const accuracyDelta = Math.abs(derived.accuracyTotal - saved.accuracyTotal);
  if (
    derived.completedGames !== saved.completedGames ||
    derived.totalScore !== saved.totalScore ||
    accuracyDelta > 0.000001 ||
    derived.mistakes !== saved.mistakes ||
    derived.elapsedMs !== saved.elapsedMs
  ) {
    throw new HttpsError(
      "failed-precondition",
      `Social progress does not match verified evidence for ${uid}.`,
    );
  }
  return derived;
}

export const settleSocialMatch = onCall(CALLABLE_OPTIONS, async (request) => {
  const callerUid = requireUid(request.auth?.uid);
  const matchId = requireMatchId(request.data?.matchId);
  const db = getFirestore();
  const matchRef = db.collection(COLLECTIONS.socialMatches).doc(matchId);
  const settlementRef = db.collection(COLLECTIONS.socialSettlements).doc(matchId);
  const now = new Date();

  return db.runTransaction(async (transaction) => {
    const [matchSnap, existingSettlement] = await Promise.all([
      transaction.get(matchRef),
      transaction.get(settlementRef),
    ]);
    if (existingSettlement.exists) {
      return existingSettlement.data()?.payload ?? { matchId, alreadySettled: true };
    }
    const match = matchSnap.data();
    if (!match) throw new HttpsError("not-found", "Social match not found.");

    const maxPlayers = intValue(match.maxPlayers);
    if (maxPlayers !== 2 && maxPlayers !== 4 && maxPlayers !== 6) {
      throw new HttpsError("data-loss", "Unsupported social player count.");
    }
    const participantMap = objectValue(match.participants);
    const participantOrder = Array.isArray(match.participantOrder)
      ? match.participantOrder.filter((value): value is string => typeof value === "string")
      : Object.keys(participantMap);
    if (participantOrder.length !== maxPlayers || !participantOrder.includes(callerUid)) {
      throw new HttpsError("permission-denied", "Not a valid social match participant.");
    }

    const countdown = match.countdownStartedAt instanceof Timestamp
      ? match.countdownStartedAt.toMillis()
      : null;
    if (countdown === null) {
      throw new HttpsError("failed-precondition", "Social match did not start correctly.");
    }
    const allFinished = participantOrder.every(
      (uid) => parseProgress(objectValue(participantMap[uid]).progress).completedGames >= MATCH_GAME_COUNT,
    );
    const deadlinePassed = Date.now() >= countdown + 3000 + MATCH_DURATION_MS;
    if (!allFinished && !deadlinePassed) {
      throw new HttpsError("failed-precondition", "Social match is still in progress.");
    }

    const matchSeed = intValue(match.seed);
    const gameCount = intValue(match.gameCount, MATCH_GAME_COUNT);
    const evidenceRefs = participantOrder.map((uid) =>
      db.collection(COLLECTIONS.socialEvidence)
        .doc(matchId)
        .collection(COLLECTIONS.players)
        .doc(uid),
    );
    const evidenceSnaps = await Promise.all(evidenceRefs.map((ref) => transaction.get(ref)));
    const progressByUid = new Map<string, MatchProgress>();
    for (let i = 0; i < participantOrder.length; i += 1) {
      const uid = participantOrder[i]!;
      let evidence: MiniGameEvidence[];
      try {
        evidence = parseEvidence(evidenceSnaps[i]?.data()?.evidence ?? []);
      } catch (error) {
        throw new HttpsError(
          "failed-precondition",
          error instanceof Error ? error.message : "Invalid social evidence.",
        );
      }
      const savedProgress = objectValue(participantMap[uid]).progress;
      progressByUid.set(
        uid,
        ensureEvidenceMatchesSavedProgress(uid, evidence, savedProgress, matchSeed, gameCount),
      );
    }

    const ranked = rankParticipants(participantOrder, progressByUid);
    const groupKey = [...participantOrder].sort().join("_");
    const usageRef = db.collection(COLLECTIONS.socialPairUsage).doc(`${dayId(now)}_${groupKey}`);
    const userRefs = participantOrder.map((uid) => db.collection(COLLECTIONS.users).doc(uid));
    const inventoryRefs = participantOrder.map((uid) => db.collection(COLLECTIONS.inventories).doc(uid));
    const missionRefs = participantOrder.map((uid) => db.collection(COLLECTIONS.playerMissions).doc(uid));
    const achievementRefs = participantOrder.map((uid) => db.collection(COLLECTIONS.playerAchievements).doc(uid));

    const [usageSnap, ...snapshots] = await Promise.all([
      transaction.get(usageRef),
      ...userRefs.map((ref) => transaction.get(ref)),
      ...inventoryRefs.map((ref) => transaction.get(ref)),
      ...missionRefs.map((ref) => transaction.get(ref)),
      ...achievementRefs.map((ref) => transaction.get(ref)),
    ]);

    const n = participantOrder.length;
    const userSnaps = snapshots.slice(0, n);
    const inventorySnaps = snapshots.slice(n, n * 2);
    const missionSnaps = snapshots.slice(n * 2, n * 3);
    const achievementSnaps = snapshots.slice(n * 3, n * 4);
    const matchesToday = Math.max(0, intValue(usageSnap.data()?.matches));
    const multiplier = repeatedGroupMultiplier(matchesToday);
    const rewards: Record<string, number> = {};

    for (let i = 0; i < participantOrder.length; i += 1) {
      const uid = participantOrder[i]!;
      const profile = userSnaps[i]?.data() as DocumentData | undefined;
      if (!profile) {
        throw new HttpsError("failed-precondition", "All social players need profiles.");
      }
      const position = ranked.indexOf(uid) + 1;
      const coinsAwarded = Math.floor(placementBaseCoins(position) * multiplier);
      rewards[uid] = coinsAwarded;

      const inventory = inventorySnaps[i]?.data() ?? {};
      const nextCoins = Math.max(0, intValue(inventory.coins)) + coinsAwarded;
      const nextFriendMatches = Math.max(0, intValue(profile.friendMatches)) + 1;
      const nextSixPlayerWins = Math.max(0, intValue(profile.sixPlayerWins)) +
        (maxPlayers === 6 && position === 1 ? 1 : 0);

      const missionStates = { ...objectValue(missionSnaps[i]?.data()?.states) };
      advanceMission(missionStates, "daily_play_3", 3, `D:${dayId(now)}`, 1);
      advanceMission(missionStates, "daily_friend_1", 1, `D:${dayId(now)}`, 1);
      advanceMission(missionStates, "weekly_play_30", 30, `W:${weekId(now)}`, 1);
      advanceMission(missionStates, "weekly_friend_5", 5, `W:${weekId(now)}`, 1);

      const achievementStates = { ...objectValue(achievementSnaps[i]?.data()?.states) };
      advanceAchievement(achievementStates, "friend_matches_50", 50, nextFriendMatches, now);
      advanceAchievement(achievementStates, "six_player_wins_10", 10, nextSixPlayerWins, now);

      transaction.update(userRefs[i]!, {
        friendMatches: nextFriendMatches,
        sixPlayerWins: nextSixPlayerWins,
        updatedAt: FieldValue.serverTimestamp(),
      });
      transaction.set(
        inventoryRefs[i]!,
        { coins: nextCoins, updatedAt: FieldValue.serverTimestamp() },
        { merge: true },
      );
      transaction.set(
        missionRefs[i]!,
        { states: missionStates, updatedAt: FieldValue.serverTimestamp() },
        { merge: true },
      );
      transaction.set(
        achievementRefs[i]!,
        { states: achievementStates, updatedAt: FieldValue.serverTimestamp() },
        { merge: true },
      );

      if (coinsAwarded > 0) {
        transaction.create(
          db.collection(COLLECTIONS.coinTransactions).doc(`${matchId}_${uid}_social`),
          {
            transactionId: `${matchId}_${uid}_social`,
            uid,
            matchId,
            reason: "socialMatchReward",
            position,
            repeatedGroupMatchesBefore: matchesToday,
            multiplier,
            amount: coinsAwarded,
            balanceAfter: nextCoins,
            createdAt: Timestamp.fromDate(now),
          },
        );
      }

      for (const otherUid of participantOrder) {
        if (otherUid === uid) continue;
        const otherData = objectValue(participantMap[otherUid]);
        transaction.set(
          db.collection(COLLECTIONS.recentPlayers).doc(uid).collection("players").doc(otherUid),
          {
            displayName: stringValue(otherData.displayName, "Player"),
            avatarId: typeof otherData.avatarId === "string" ? otherData.avatarId : null,
            matchId,
            lastPlayedAt: Timestamp.fromDate(now),
          },
          { merge: true },
        );
      }
    }

    transaction.set(
      usageRef,
      {
        participantUids: [...participantOrder].sort(),
        dayId: dayId(now),
        matches: matchesToday + 1,
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );

    const payload = {
      matchId,
      maxPlayers,
      placements: ranked.map((uid, index) => ({ uid, position: index + 1 })),
      rewards,
      repeatedGroupMatchesBefore: matchesToday,
      multiplier,
      rankedRpAwarded: 0,
      evidenceVerified: true,
      settledAt: now.toISOString(),
    };
    transaction.create(settlementRef, {
      matchId,
      payload,
      settledAt: Timestamp.fromDate(now),
      createdAt: FieldValue.serverTimestamp(),
    });
    return payload;
  });
});
