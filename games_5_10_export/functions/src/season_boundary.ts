import { MATCH_DURATION_MS } from "./registry.js";

export const RANKED_COUNTDOWN_MS = 3000;
export const RANKED_SUBMISSION_TRANSPORT_GRACE_MS = 15000;

// A new ranked match may only be created or started while there is enough
// season time left for countdown + the full 3-minute match + final evidence
// transport. This guarantees a legally started match can finish before the
// season boundary.
export const SEASON_NEW_MATCH_GUARD_MS =
  RANKED_COUNTDOWN_MS + MATCH_DURATION_MS + RANKED_SUBMISSION_TRANSPORT_GRACE_MS;

// Rollover never locks settlements exactly at endsAt. This additional grace
// allows the final legal evidence/settlement calls to arrive before standings
// are frozen. Hourly scheduling can make the actual delay longer, never shorter.
export const SEASON_SETTLEMENT_GRACE_MS = 5 * 60 * 1000;

export function seasonAcceptsNewRankedMatch(options: {
  active: boolean;
  startsAtMs: number | null;
  endsAtMs: number | null;
  nowMs: number;
}): boolean {
  const { active, startsAtMs, endsAtMs, nowMs } = options;
  if (!active || startsAtMs === null || endsAtMs === null) return false;
  if (nowMs < startsAtMs) return false;
  return nowMs + SEASON_NEW_MATCH_GUARD_MS <= endsAtMs;
}

export function seasonCanAcceptSettlement(options: {
  active: boolean;
  rolloverState?: unknown;
}): boolean {
  return options.active && options.rolloverState !== "processing" && options.rolloverState !== "closed";
}

export function seasonReadyForRollover(options: {
  active: boolean;
  endsAtMs: number | null;
  nowMs: number;
}): boolean {
  const { active, endsAtMs, nowMs } = options;
  return active && endsAtMs !== null && nowMs >= endsAtMs + SEASON_SETTLEMENT_GRACE_MS;
}
