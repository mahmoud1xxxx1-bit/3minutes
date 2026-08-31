import { intValue, stringValue } from "./firestore.js";
import { rankedWeeklyDelta } from "./weekly_competition.js";

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
 * event. The client cannot provide or override these deltas.
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
