import { intValue, stringValue } from "./firestore.js";
import {
  economicGoldScoreDelta,
  rankedWeeklyDelta,
} from "./weekly_competition.js";

export interface RankedWeeklyPlayerInput {
  uid: string;
  gameName: string;
  avatarId: string;
  rpDelta: number;
  goldNetDelta: number;
}

export interface RankedWeeklyScoreEvent {
  playerA: RankedWeeklyPlayerInput;
  playerB: RankedWeeklyPlayerInput;
}

export interface EconomicGoldWeeklyScoreEvent {
  uid: string;
  goldDelta: number;
}

function record(value: unknown): Record<string, unknown> {
  return value !== null && typeof value === "object"
    ? (value as Record<string, unknown>)
    : {};
}

function playerFromPayload(
  value: unknown,
  profile: unknown,
): RankedWeeklyPlayerInput | null {
  const player = record(value);
  const identity = record(profile);
  const uid = stringValue(player.uid);
  if (!uid) return null;
  const delta = rankedWeeklyDelta({
    rpDelta: intValue(player.rpDelta),
    goldNetMatchDelta: intValue(player.goldNetDelta),
  });
  return {
    uid,
    gameName: stringValue(identity.gameName, "Player"),
    avatarId: stringValue(identity.avatarId, "default_01"),
    rpDelta: delta.rpScoreDelta,
    goldNetDelta: delta.goldScoreDelta,
  };
}

/**
 * Converts the authoritative ranked settlement receipt into a weekly score
 * event. RP uses this settlement event. Gold is intentionally accumulated from
 * the immutable Gold transaction ledger instead, so conversions, purchases,
 * escrow locks/refunds and future economy actions share one source of truth.
 */
export function rankedWeeklyScoreEvent(options: {
  payload: unknown;
  profileA: unknown;
  profileB: unknown;
}): RankedWeeklyScoreEvent | null {
  const payload = record(options.payload);
  const playerA = playerFromPayload(payload.playerA, options.profileA);
  const playerB = playerFromPayload(payload.playerB, options.profileB);
  if (!playerA || !playerB || playerA.uid === playerB.uid) return null;
  return { playerA, playerB };
}

/**
 * Accepts only server-authored Gold ledger events that should affect the
 * strategic weekly board. Weekly prizes themselves are explicitly excluded so
 * last week's reward cannot create an artificial lead in the new week.
 */
export function economicGoldWeeklyScoreEvent(
  transaction: unknown,
): EconomicGoldWeeklyScoreEvent | null {
  const data = record(transaction);
  if (data.excludedFromWeeklyGoldScore === true) return null;
  const uid = stringValue(data.uid);
  if (!uid) return null;
  const rawAmount = data.amount;
  if (typeof rawAmount !== "number" || !Number.isFinite(rawAmount)) return null;
  const goldDelta = economicGoldScoreDelta(rawAmount);
  if (goldDelta === 0) return null;
  return { uid, goldDelta };
}
