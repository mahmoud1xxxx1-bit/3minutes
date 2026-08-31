export interface WeeklyStandingState {
  position: number;
  standing: number;
  previousScore: number | null;
}

export interface WeeklyStandingResult extends WeeklyStandingState {
  awardedStanding: number;
}

export const INITIAL_WEEKLY_STANDING: WeeklyStandingState = {
  position: 0,
  standing: 0,
  previousScore: null,
};

/**
 * Competition ranking: equal scores share the same standing. The next distinct
 * score receives its natural position, so 1,1,3 is possible. This prevents an
 * arbitrary document id from deciding a paid weekly prize.
 */
export function nextWeeklyStanding(
  state: WeeklyStandingState,
  score: number,
): WeeklyStandingResult {
  if (!Number.isFinite(score)) throw new Error("Weekly score must be finite.");
  const nextPosition = state.position + 1;
  const sameScore = state.previousScore !== null && state.previousScore === score;
  const awardedStanding = sameScore ? state.standing : nextPosition;
  return {
    position: nextPosition,
    standing: awardedStanding,
    previousScore: score,
    awardedStanding,
  };
}
