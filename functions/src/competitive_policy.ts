import { applyRp, rewardFor, type RankedResult } from "./policy.js";

export const COMPETITIVE_WAGERS = [180, 500, 1000] as const;
export const DAILY_GOLD_GRANT = 1000;
export const COMPETITIVE_GAME_COUNT = 4;
export const COMPETITIVE_PICKS_PER_PLAYER = 2;
export const COMPETITIVE_DURATION_MS = 3 * 60 * 1000;

export function isCompetitiveWager(value: number): boolean {
  return COMPETITIVE_WAGERS.includes(value as (typeof COMPETITIVE_WAGERS)[number]);
}

export function competitiveReward(result: RankedResult, wager: number) {
  if (!isCompetitiveWager(wager)) throw new Error("Unsupported wager");
  const base = rewardFor(result);
  return {
    goldDelta: result === "win" ? wager : result === "loss" ? -wager : 0,
    coinsDelta: base.coins,
    rpDelta: base.rpDelta,
    xp: base.xp,
  };
}

export function applyCompetitiveRp(currentRp: number, result: RankedResult): number {
  return applyRp(currentRp, rewardFor(result).rpDelta);
}
