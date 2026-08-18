export type RankTier =
  | "bronze"
  | "silver"
  | "gold"
  | "platinum"
  | "diamond"
  | "master"
  | "grandmaster"
  | "legend";

export type RankedResult = "win" | "loss" | "tie";

export interface MatchProgress {
  completedGames: number;
  totalScore: number;
  accuracyTotal: number;
  mistakes: number;
  elapsedMs: number;
  completedAtMs: number | null;
}

export interface RankedReward {
  rpDelta: number;
  xp: number;
  coins: number;
}

export interface Progression {
  level: number;
  xp: number;
}

export const RANK_BANDS: ReadonlyArray<{
  tier: RankTier;
  minimumRp: number;
}> = [
  { tier: "bronze", minimumRp: 0 },
  { tier: "silver", minimumRp: 500 },
  { tier: "gold", minimumRp: 1200 },
  { tier: "platinum", minimumRp: 2200 },
  { tier: "diamond", minimumRp: 3500 },
  { tier: "master", minimumRp: 5000 },
  { tier: "grandmaster", minimumRp: 7000 },
  { tier: "legend", minimumRp: 10000 },
];

const REWARDS: Record<RankedResult, RankedReward> = {
  win: { rpDelta: 30, xp: 120, coins: 30 },
  loss: { rpDelta: -18, xp: 55, coins: 10 },
  tie: { rpDelta: 8, xp: 80, coins: 18 },
};

const SEASON_STARS: Record<RankTier, number> = {
  bronze: 1,
  silver: 2,
  gold: 4,
  platinum: 7,
  diamond: 11,
  master: 16,
  grandmaster: 24,
  legend: 35,
};

const SEASON_RESET_RP: Record<RankTier, number> = {
  bronze: 0,
  silver: 250,
  gold: 500,
  platinum: 900,
  diamond: 1400,
  master: 2200,
  grandmaster: 3500,
  legend: 5000,
};

export function rewardFor(result: RankedResult): RankedReward {
  return REWARDS[result];
}

export function applyRp(currentRp: number, delta: number): number {
  return Math.max(0, Math.trunc(currentRp) + Math.trunc(delta));
}

export function tierFor(rankPoints: number): RankTier {
  const safeRp = Math.max(0, Math.trunc(rankPoints));
  let result: RankTier = "bronze";
  for (const band of RANK_BANDS) {
    if (safeRp >= band.minimumRp) result = band.tier;
    else break;
  }
  return result;
}

export function higherTier(a: RankTier, b: RankTier): RankTier {
  const aIndex = RANK_BANDS.findIndex((band) => band.tier === a);
  const bIndex = RANK_BANDS.findIndex((band) => band.tier === b);
  return aIndex >= bIndex ? a : b;
}

export function xpRequiredForLevel(level: number): number {
  const safeLevel = Math.max(1, Math.trunc(level));
  return 100 + (safeLevel - 1) * 50;
}

export function applyXp(current: Progression, earnedXp: number): Progression {
  let level = Math.max(1, Math.trunc(current.level));
  let xp = Math.max(0, Math.trunc(current.xp));
  let remaining = Math.max(0, Math.trunc(earnedXp));

  while (remaining > 0) {
    const required = xpRequiredForLevel(level);
    const needed = required - xp;
    if (remaining < needed) {
      xp += remaining;
      remaining = 0;
    } else {
      remaining -= needed;
      level += 1;
      xp = 0;
    }
  }

  return { level, xp };
}

function averageAccuracy(progress: MatchProgress): number {
  return progress.completedGames <= 0
    ? 0
    : progress.accuracyTotal / progress.completedGames;
}

export function compareMatch(
  playerA: MatchProgress,
  playerB: MatchProgress,
  gameCount: number,
): "playerA" | "playerB" | "tie" {
  const aFinished = playerA.completedGames >= gameCount;
  const bFinished = playerB.completedGames >= gameCount;

  if (aFinished && bFinished) {
    const aTime = playerA.completedAtMs;
    const bTime = playerB.completedAtMs;
    if (aTime !== null && bTime !== null && aTime !== bTime) {
      return aTime < bTime ? "playerA" : "playerB";
    }
  } else if (aFinished !== bFinished) {
    return aFinished ? "playerA" : "playerB";
  }

  if (playerA.completedGames !== playerB.completedGames) {
    return playerA.completedGames > playerB.completedGames
      ? "playerA"
      : "playerB";
  }

  if (playerA.totalScore !== playerB.totalScore) {
    return playerA.totalScore > playerB.totalScore ? "playerA" : "playerB";
  }

  const aAccuracy = averageAccuracy(playerA);
  const bAccuracy = averageAccuracy(playerB);
  if (aAccuracy !== bAccuracy) {
    return aAccuracy > bAccuracy ? "playerA" : "playerB";
  }

  if (playerA.mistakes !== playerB.mistakes) {
    return playerA.mistakes < playerB.mistakes ? "playerA" : "playerB";
  }

  if (playerA.elapsedMs !== playerB.elapsedMs) {
    return playerA.elapsedMs < playerB.elapsedMs ? "playerA" : "playerB";
  }

  return "tie";
}

export function resultForPlayer(
  outcome: "playerA" | "playerB" | "tie",
  player: "playerA" | "playerB",
): RankedResult {
  if (outcome === "tie") return "tie";
  return outcome === player ? "win" : "loss";
}

export function starsForPeakTier(tier: RankTier): number {
  return SEASON_STARS[tier];
}

export function startingRpForPeakTier(tier: RankTier): number {
  return SEASON_RESET_RP[tier];
}
