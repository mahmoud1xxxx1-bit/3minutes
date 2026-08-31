export const WEEK_MS = 7 * 24 * 60 * 60 * 1000;

export type WeeklyBoardKind = "rp" | "gold";

export interface WeeklyReward {
  gold: number;
  stars: number;
}

export interface WeeklyCompetitionDelta {
  rpScoreDelta: number;
  goldScoreDelta: number;
}

const RP_REWARDS: Readonly<Record<number, WeeklyReward>> = {
  1: { gold: 3000, stars: 0 },
  2: { gold: 2000, stars: 0 },
  3: { gold: 1500, stars: 0 },
};

const GOLD_REWARDS: Readonly<Record<number, WeeklyReward>> = {
  1: { gold: 3000, stars: 5 },
  2: { gold: 2500, stars: 1 },
  3: { gold: 2000, stars: 0 },
};

const ACTIVE_MEMBER_REWARD: WeeklyReward = { gold: 300, stars: 0 };

/**
 * Stable UTC week id. Week zero begins at Unix epoch; every id therefore spans
 * exactly seven days and is independent of device locale/time zone.
 */
export function weeklyCompetitionId(nowMs: number): string {
  if (!Number.isFinite(nowMs)) throw new Error("Weekly competition time must be finite.");
  const index = Math.floor(nowMs / WEEK_MS);
  return `week_${index}`;
}

export function weeklyRewardFor(
  board: WeeklyBoardKind,
  standing: number,
  active: boolean,
): WeeklyReward {
  if (!active) return { gold: 0, stars: 0 };
  const position = Math.trunc(standing);
  const table = board === "rp" ? RP_REWARDS : GOLD_REWARDS;
  return table[position] ?? ACTIVE_MEMBER_REWARD;
}

/**
 * Ranked settlement contributes its authoritative RP delta and Gold net match
 * delta to the current seven-day competition. Persistent account RP/Gold are
 * not reset by this score accumulator.
 */
export function rankedWeeklyDelta(options: {
  rpDelta: number;
  goldNetMatchDelta: number;
}): WeeklyCompetitionDelta {
  return {
    rpScoreDelta: Math.trunc(options.rpDelta),
    goldScoreDelta: Math.trunc(options.goldNetMatchDelta),
  };
}

/**
 * Any server-authoritative economic Gold mutation can contribute to the Gold
 * board. This intentionally lets conversion, future purchases, match gains and
 * match losses affect the strategic/economic weekly ranking.
 */
export function economicGoldScoreDelta(goldBalanceDelta: number): number {
  if (!Number.isFinite(goldBalanceDelta)) {
    throw new Error("Gold leaderboard delta must be finite.");
  }
  return Math.trunc(goldBalanceDelta);
}
