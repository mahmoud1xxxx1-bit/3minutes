export type SeasonalResult = "win" | "loss" | "tie";

export interface SeasonalRecord {
  wins: number;
  losses: number;
  ties: number;
}

function safeCount(value: number): number {
  return Number.isFinite(value) && value > 0 ? Math.floor(value) : 0;
}

export function advanceSeasonalRecord(
  record: SeasonalRecord,
  result: SeasonalResult,
): SeasonalRecord {
  const next = {
    wins: safeCount(record.wins),
    losses: safeCount(record.losses),
    ties: safeCount(record.ties),
  };
  if (result === "win") next.wins += 1;
  if (result === "loss") next.losses += 1;
  if (result === "tie") next.ties += 1;
  return next;
}
