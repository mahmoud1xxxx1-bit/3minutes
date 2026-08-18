import { randomUUID } from "node:crypto";

import {
  FieldValue,
  Timestamp,
  getFirestore,
  type DocumentData,
} from "firebase-admin/firestore";
import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";

import { COLLECTIONS, intValue } from "./firestore.js";
import { rewardFor, type RankedResult } from "./policy.js";

const CALLABLE_OPTIONS = {
  region: "me-central2",
  enforceAppCheck: true,
  timeoutSeconds: 30,
} as const;

const MISSION_DEFINITIONS = {
  daily_play_3: { cadence: "daily", metric: "matches", target: 3, coins: 60, seasonXp: 80 },
  daily_win_1: { cadence: "daily", metric: "wins", target: 1, coins: 75, seasonXp: 100 },
  daily_friend_1: { cadence: "daily", metric: "friendMatches", target: 1, coins: 50, seasonXp: 70 },
  weekly_play_30: { cadence: "weekly", metric: "matches", target: 30, coins: 450, seasonXp: 700 },
  weekly_win_15: { cadence: "weekly", metric: "wins", target: 15, coins: 600, seasonXp: 900 },
  weekly_friend_5: { cadence: "weekly", metric: "friendMatches", target: 5, coins: 350, seasonXp: 550 },
} as const;

type MissionId = keyof typeof MISSION_DEFINITIONS;

type MissionState = {
  windowId: string;
  progress: number;
  completed: boolean;
  claimedAt: Timestamp | null;
};

const ACHIEVEMENT_DEFINITIONS = {
  first_win: { metric: "wins", target: 1, coins: 100 },
  wins_10: { metric: "wins", target: 10, coins: 250 },
  wins_100: { metric: "wins", target: 100, coins: 1000 },
  wins_500: { metric: "wins", target: 500, coins: 3000 },
  matches_1000: { metric: "matches", target: 1000, coins: 5000 },
  streak_10: { metric: "winStreak", target: 10, coins: 1500 },
  friend_matches_50: { metric: "friendMatches", target: 50, coins: 750 },
  six_player_wins_10: { metric: "sixPlayerWins", target: 10, coins: 1200 },
  seasons_10: { metric: "seasonsCompleted", target: 10, coins: 4000 },
  prestige_100: { metric: "prestigeStars", target: 100, coins: 3000 },
} as const;

type AchievementId = keyof typeof ACHIEVEMENT_DEFINITIONS;

type AchievementState = {
  progress: number;
  completed: boolean;
  completedAt: Timestamp | null;
  rewardClaimedAt: Timestamp | null;
};

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

function utcDayId(now: Date): string {
  return now.toISOString().slice(0, 10);
}

function isoWeekId(now: Date): string {
  const date = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate()));
  const day = date.getUTCDay() || 7;
  date.setUTCDate(date.getUTCDate() + 4 - day);
  const yearStart = new Date(Date.UTC(date.getUTCFullYear(), 0, 1));
  const week = Math.ceil((((date.getTime() - yearStart.getTime()) / 86400000) + 1) / 7);
  return `${date.getUTCFullYear()}-W${String(week).padStart(2, "0")}`;
}

function missionWindowId(cadence: "daily" | "weekly", now: Date): string {
  return cadence === "daily" ? `D:${utcDayId(now)}` : `W:${isoWeekId(now)}`;
}

function resultFromSettlementPlayer(player: Record<string, unknown>): RankedResult {
  const coins = intValue(player.coinsAwarded);
  if (coins === rewardFor("win").coins) return "win";
  if (coins === rewardFor("tie").coins) return "tie";
  return "loss";
}

function asRecord(value: unknown): Record<string, unknown> {
  return value !== null && typeof value === "object"
    ? (value as Record<string, unknown>)
    : {};
}

function readMissionState(
  raw: unknown,
  definition: (typeof MISSION_DEFINITIONS)[MissionId],
  now: Date,
): MissionState {
  const data = asRecord(raw);
  const windowId = missionWindowId(definition.cadence, now);
  if (data.windowId !== windowId) {
    return { windowId, progress: 0, completed: false, claimedAt: null };
  }
  return {
    windowId,
    progress: Math.max(0, intValue(data.progress)),
    completed: data.completed === true,
    claimedAt: data.claimedAt instanceof Timestamp ? data.claimedAt : null,
  };
}

function advanceMissionStates(options: {
  currentStates: unknown;
  now: Date;
  rankedResult: RankedResult;
}): Record<string, MissionState> {
  const current = asRecord(options.currentStates);
  const next: Record<string, MissionState> = {};
  for (const [id, definition] of Object.entries(MISSION_DEFINITIONS) as Array<
    [MissionId, (typeof MISSION_DEFINITIONS)[MissionId]]
  >) {
    const state = readMissionState(current[id], definition, options.now);
    let delta = 0;
    if (definition.metric === "matches") delta = 1;
    if (definition.metric === "wins" && options.rankedResult === "win") delta = 1;
    const progress = Math.min(definition.target, state.progress + delta);
    next[id] = {
      ...state,
      progress,
      completed: progress >= definition.target,
    };
  }
  return next;
}

function readAchievementState(raw: unknown): AchievementState {
  const data = asRecord(raw);
  return {
    progress: Math.max(0, intValue(data.progress)),
    completed: data.completed === true,
    completedAt: data.completedAt instanceof Timestamp ? data.completedAt : null,
    rewardClaimedAt:
      data.rewardClaimedAt instanceof Timestamp ? data.rewardClaimedAt : null,
  };
}

function achievementMetricValue(
  metric: (typeof ACHIEVEMENT_DEFINITIONS)[AchievementId]["metric"],
  profile: DocumentData,
): number {
  switch (metric) {
    case "wins":
      return Math.max(0, intValue(profile.wins));
    case "matches":
      return Math.max(0, intValue(profile.gamesPlayed));
    case "winStreak":
      return Math.max(0, intValue(profile.bestWinStreak));
    case "prestigeStars":
      return Math.max(0, intValue(profile.stars));
    case "friendMatches":
      return Math.max(0, intValue(profile.friendMatches));
    case "sixPlayerWins":
      return Math.max(0, intValue(profile.sixPlayerWins));
    case "seasonsCompleted":
      return Math.max(0, intValue(profile.seasonsCompleted));
  }
}

function rebuildAchievementStates(options: {
  currentStates: unknown;
  profile: DocumentData;
  now: Date;
}): Record<string, AchievementState> {
  const current = asRecord(options.currentStates);
  const nowTimestamp = Timestamp.fromDate(options.now);
  const next: Record<string, AchievementState> = {};
  for (const [id, definition] of Object.entries(ACHIEVEMENT_DEFINITIONS) as Array<
    [AchievementId, (typeof ACHIEVEMENT_DEFINITIONS)[AchievementId]]
  >) {
    const state = readAchievementState(current[id]);
    const metricValue = achievementMetricValue(definition.metric, options.profile);
    const progress = Math.max(state.progress, Math.min(definition.target, metricValue));
    const completed = state.completed || progress >= definition.target;
    next[id] = {
      progress,
      completed,
      completedAt: state.completedAt ?? (completed ? nowTimestamp : null),
      rewardClaimedAt: state.rewardClaimedAt,
    };
  }
  return next;
}

export const onRankedSettlementProgression = onDocumentCreated(
  {
    document: `${COLLECTIONS.rankedSettlements}/{matchId}`,
    region: "me-central2",
    retry: false,
  },
  async (event) => {
    const settlement = event.data?.data();
    if (!settlement) return;
    const matchId = event.params.matchId;
    const payload = asRecord(settlement.payload);
    const db = getFirestore();
    const now = new Date();

    for (const key of ["playerA", "playerB"] as const) {
      const player = asRecord(payload[key]);
      const uid = typeof player.uid === "string" ? player.uid : "";
      if (!uid) continue;
      const eventRef = db.collection("progressionEvents").doc(`${matchId}_${uid}`);
      const userRef = db.collection(COLLECTIONS.users).doc(uid);
      const missionsRef = db.collection(COLLECTIONS.playerMissions).doc(uid);
      const achievementsRef = db.collection(COLLECTIONS.playerAchievements).doc(uid);

      await db.runTransaction(async (transaction) => {
        const [eventSnap, userSnap, missionsSnap, achievementsSnap] = await Promise.all([
          transaction.get(eventRef),
          transaction.get(userRef),
          transaction.get(missionsRef),
          transaction.get(achievementsRef),
        ]);
        if (eventSnap.exists) return;
        const profile = userSnap.data();
        if (!profile) return;

        const rankedResult = resultFromSettlementPlayer(player);
        const currentStreak = rankedResult === "win"
          ? Math.max(0, intValue(profile.currentWinStreak)) + 1
          : 0;
        const bestWinStreak = Math.max(
          Math.max(0, intValue(profile.bestWinStreak)),
          currentStreak,
        );
        const profileForAchievements = {
          ...profile,
          currentWinStreak: currentStreak,
          bestWinStreak,
        };

        const missionStates = advanceMissionStates({
          currentStates: missionsSnap.data()?.states,
          now,
          rankedResult,
        });
        const achievementStates = rebuildAchievementStates({
          currentStates: achievementsSnap.data()?.states,
          profile: profileForAchievements,
          now,
        });

        transaction.set(
          missionsRef,
          { states: missionStates, updatedAt: FieldValue.serverTimestamp() },
          { merge: true },
        );
        transaction.set(
          achievementsRef,
          { states: achievementStates, updatedAt: FieldValue.serverTimestamp() },
          { merge: true },
        );
        transaction.update(userRef, {
          currentWinStreak,
          bestWinStreak,
          updatedAt: FieldValue.serverTimestamp(),
        });
        transaction.create(eventRef, {
          uid,
          matchId,
          type: "rankedSettlement",
          createdAt: FieldValue.serverTimestamp(),
        });
      });
    }
  },
);

export const claimMissionReward = onCall(CALLABLE_OPTIONS, async (request) => {
  const uid = requireUid(request.auth?.uid);
  const missionId = requireString(request.data?.missionId, "missionId") as MissionId;
  const definition = MISSION_DEFINITIONS[missionId];
  if (!definition) throw new HttpsError("not-found", "Unknown mission.");

  const db = getFirestore();
  const missionsRef = db.collection(COLLECTIONS.playerMissions).doc(uid);
  const inventoryRef = db.collection(COLLECTIONS.inventories).doc(uid);
  const passRef = db.collection(COLLECTIONS.seasonPass).doc(uid);
  const now = new Date();
  const ledgerId = `mission_${missionId}_${missionWindowId(definition.cadence, now)}_${uid}`;
  const ledgerRef = db.collection(COLLECTIONS.coinTransactions).doc(ledgerId);

  return db.runTransaction(async (transaction) => {
    const [missionsSnap, inventorySnap, passSnap, ledgerSnap] = await Promise.all([
      transaction.get(missionsRef),
      transaction.get(inventoryRef),
      transaction.get(passRef),
      transaction.get(ledgerRef),
    ]);
    if (ledgerSnap.exists) throw new HttpsError("already-exists", "Mission reward already claimed.");
    const states = { ...asRecord(missionsSnap.data()?.states) };
    const state = readMissionState(states[missionId], definition, now);
    if (!state.completed) throw new HttpsError("failed-precondition", "Mission is not complete.");
    if (state.claimedAt) throw new HttpsError("already-exists", "Mission reward already claimed.");

    const coins = Math.max(0, intValue(inventorySnap.data()?.coins));
    const nextCoins = coins + definition.coins;
    const seasonXp = Math.max(0, intValue(passSnap.data()?.seasonXp));
    const nextSeasonXp = seasonXp + definition.seasonXp;
    states[missionId] = { ...state, claimedAt: Timestamp.fromDate(now) };

    transaction.set(missionsRef, { states, updatedAt: FieldValue.serverTimestamp() }, { merge: true });
    transaction.set(
      inventoryRef,
      { coins: nextCoins, updatedAt: FieldValue.serverTimestamp() },
      { merge: true },
    );
    transaction.set(
      passRef,
      {
        seasonXp: nextSeasonXp,
        premiumUnlocked: passSnap.data()?.premiumUnlocked === true,
        claimedFreeLevels: Array.isArray(passSnap.data()?.claimedFreeLevels)
          ? passSnap.data()?.claimedFreeLevels
          : [],
        claimedPremiumLevels: Array.isArray(passSnap.data()?.claimedPremiumLevels)
          ? passSnap.data()?.claimedPremiumLevels
          : [],
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
    transaction.create(ledgerRef, {
      transactionId: ledgerId,
      uid,
      missionId,
      reason: "missionReward",
      amount: definition.coins,
      balanceAfter: nextCoins,
      createdAt: Timestamp.fromDate(now),
    });

    return {
      missionId,
      coinsAwarded: definition.coins,
      seasonXpAwarded: definition.seasonXp,
      balanceAfter: nextCoins,
      seasonXpAfter: nextSeasonXp,
    };
  });
});

export const claimAchievementReward = onCall(CALLABLE_OPTIONS, async (request) => {
  const uid = requireUid(request.auth?.uid);
  const achievementId = requireString(
    request.data?.achievementId,
    "achievementId",
  ) as AchievementId;
  const definition = ACHIEVEMENT_DEFINITIONS[achievementId];
  if (!definition) throw new HttpsError("not-found", "Unknown achievement.");

  const db = getFirestore();
  const achievementsRef = db.collection(COLLECTIONS.playerAchievements).doc(uid);
  const inventoryRef = db.collection(COLLECTIONS.inventories).doc(uid);
  const ledgerRef = db.collection(COLLECTIONS.coinTransactions).doc(`achievement_${achievementId}_${uid}`);
  const now = new Date();

  return db.runTransaction(async (transaction) => {
    const [achievementSnap, inventorySnap, ledgerSnap] = await Promise.all([
      transaction.get(achievementsRef),
      transaction.get(inventoryRef),
      transaction.get(ledgerRef),
    ]);
    if (ledgerSnap.exists) throw new HttpsError("already-exists", "Achievement reward already claimed.");
    const states = { ...asRecord(achievementSnap.data()?.states) };
    const state = readAchievementState(states[achievementId]);
    if (!state.completed) throw new HttpsError("failed-precondition", "Achievement is not complete.");
    if (state.rewardClaimedAt) throw new HttpsError("already-exists", "Achievement reward already claimed.");

    const coins = Math.max(0, intValue(inventorySnap.data()?.coins));
    const nextCoins = coins + definition.coins;
    states[achievementId] = { ...state, rewardClaimedAt: Timestamp.fromDate(now) };

    transaction.set(
      achievementsRef,
      { states, updatedAt: FieldValue.serverTimestamp() },
      { merge: true },
    );
    transaction.set(
      inventoryRef,
      { coins: nextCoins, updatedAt: FieldValue.serverTimestamp() },
      { merge: true },
    );
    transaction.create(ledgerRef, {
      transactionId: ledgerRef.id,
      uid,
      achievementId,
      reason: "achievementReward",
      amount: definition.coins,
      balanceAfter: nextCoins,
      createdAt: Timestamp.fromDate(now),
    });

    return {
      achievementId,
      coinsAwarded: definition.coins,
      balanceAfter: nextCoins,
    };
  });
});

export function seasonPassLevelForXp(seasonXp: number): number {
  const safeXp = Math.max(0, Math.trunc(seasonXp));
  return Math.min(30, 1 + Math.floor(safeXp / 500));
}

function freePassCoins(level: number): number {
  return 40 + level * 10;
}

function premiumPassCoins(level: number): number {
  return 100 + level * 20;
}

export const claimSeasonPassReward = onCall(CALLABLE_OPTIONS, async (request) => {
  const uid = requireUid(request.auth?.uid);
  const level = Math.trunc(Number(request.data?.level));
  const track = requireString(request.data?.track, "track");
  if (level < 1 || level > 30) throw new HttpsError("invalid-argument", "Invalid season pass level.");
  if (track !== "free" && track !== "premium") {
    throw new HttpsError("invalid-argument", "Invalid season pass track.");
  }

  const db = getFirestore();
  const passRef = db.collection(COLLECTIONS.seasonPass).doc(uid);
  const inventoryRef = db.collection(COLLECTIONS.inventories).doc(uid);
  const ledgerRef = db.collection(COLLECTIONS.coinTransactions).doc(`seasonPass_${track}_${level}_${uid}`);
  const now = new Date();

  return db.runTransaction(async (transaction) => {
    const [passSnap, inventorySnap, ledgerSnap] = await Promise.all([
      transaction.get(passRef),
      transaction.get(inventoryRef),
      transaction.get(ledgerRef),
    ]);
    if (ledgerSnap.exists) throw new HttpsError("already-exists", "Season pass reward already claimed.");
    const pass = passSnap.data() ?? {};
    const unlockedLevel = seasonPassLevelForXp(intValue(pass.seasonXp));
    if (level > unlockedLevel) throw new HttpsError("failed-precondition", "Season pass level is locked.");
    if (track === "premium" && pass.premiumUnlocked !== true) {
      throw new HttpsError("failed-precondition", "Premium season pass is locked.");
    }

    const claimedField = track === "free" ? "claimedFreeLevels" : "claimedPremiumLevels";
    const claimed = Array.isArray(pass[claimedField])
      ? pass[claimedField].filter((value): value is number => typeof value === "number")
      : [];
    if (claimed.includes(level)) throw new HttpsError("already-exists", "Season pass reward already claimed.");

    const rewardCoins = track === "free" ? freePassCoins(level) : premiumPassCoins(level);
    const coins = Math.max(0, intValue(inventorySnap.data()?.coins));
    const nextCoins = coins + rewardCoins;
    const nextClaimed = [...claimed, level].sort((a, b) => a - b);

    transaction.set(
      passRef,
      { [claimedField]: nextClaimed, updatedAt: FieldValue.serverTimestamp() },
      { merge: true },
    );
    transaction.set(
      inventoryRef,
      { coins: nextCoins, updatedAt: FieldValue.serverTimestamp() },
      { merge: true },
    );
    transaction.create(ledgerRef, {
      transactionId: ledgerRef.id,
      uid,
      level,
      track,
      reason: "seasonPassReward",
      amount: rewardCoins,
      balanceAfter: nextCoins,
      createdAt: Timestamp.fromDate(now),
    });

    return { level, track, coinsAwarded: rewardCoins, balanceAfter: nextCoins };
  });
});

export function newProgressionEventId(): string {
  return randomUUID();
}
