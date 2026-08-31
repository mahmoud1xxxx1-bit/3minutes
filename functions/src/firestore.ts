import { Timestamp } from "firebase-admin/firestore";

import type { MatchProgress } from "./policy.js";

export const COLLECTIONS = {
  users: "users",
  matchmaking: "matchmaking",
  quickMatchmaking: "quickMatchmaking",
  matches: "matches",
  seasons: "seasons",
  seasonHistory: "seasonHistory",
  leaderboards: "leaderboards",
  entries: "entries",
  inventories: "inventories",
  rankedSettlements: "rankedSettlements",
  rankedEvidence: "rankedEvidence",
  quickSettlements: "quickSettlements",
  quickEvidence: "quickEvidence",
  quickPairUsage: "quickPairUsage",
  socialEvidence: "socialEvidence",
  socialSettlements: "socialSettlements",
  socialPairUsage: "socialPairUsage",
  progressionEvents: "progressionEvents",
  players: "players",
  coinTransactions: "coinTransactions",
  goldTransactions: "goldTransactions",
  prestigeStarTransactions: "prestigeStarTransactions",
  purchaseReceipts: "purchaseReceipts",
  achievements: "achievements",
  playerAchievements: "playerAchievements",
  missions: "missions",
  playerMissions: "playerMissions",
  seasonPass: "seasonPass",
  friendships: "friendships",
  friendCodes: "friendCodes",
  recentPlayers: "recentPlayers",
  privateRooms: "privateRooms",
  roomCodes: "roomCodes",
  parties: "parties",
  socialMatches: "socialMatches",
} as const;

export const AUTHORITY_VERSION = 1;

function numberValue(value: unknown, fallback = 0): number {
  return typeof value === "number" && Number.isFinite(value)
    ? value
    : fallback;
}

export function intValue(value: unknown, fallback = 0): number {
  return Math.trunc(numberValue(value, fallback));
}

export function stringValue(value: unknown, fallback = ""): string {
  return typeof value === "string" ? value : fallback;
}

export function boolValue(value: unknown, fallback = false): boolean {
  return typeof value === "boolean" ? value : fallback;
}

export function timestampMillis(value: unknown): number | null {
  return value instanceof Timestamp ? value.toMillis() : null;
}

export function parseProgress(value: unknown): MatchProgress {
  const data =
    value !== null && typeof value === "object"
      ? (value as Record<string, unknown>)
      : {};

  return {
    completedGames: intValue(data.completedGames),
    totalScore: intValue(data.totalScore),
    accuracyTotal: numberValue(data.accuracyTotal),
    mistakes: intValue(data.mistakes),
    elapsedMs: intValue(data.elapsedMs),
    completedAtMs: timestampMillis(data.completedAt),
  };
}

export function progressToFirestore(progress: MatchProgress): Record<string, unknown> {
  return {
    completedGames: progress.completedGames,
    totalScore: progress.totalScore,
    accuracyTotal: progress.accuracyTotal,
    mistakes: progress.mistakes,
    elapsedMs: progress.elapsedMs,
    completedAt:
      progress.completedAtMs === null
        ? null
        : Timestamp.fromMillis(progress.completedAtMs),
  };
}

export function emptyProgress(): Record<string, unknown> {
  return {
    completedGames: 0,
    totalScore: 0,
    accuracyTotal: 0,
    mistakes: 0,
    elapsedMs: 0,
    completedAt: null,
  };
}
