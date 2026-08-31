import type { WeeklyBoardKind } from "./weekly_competition.js";

export interface WeeklyRolloverPlanInput {
  state: unknown;
  endsAtMs: number | null;
  nowMs: number;
  rpRewardsComplete: boolean;
  goldRewardsComplete: boolean;
}

export interface WeeklyRolloverPlan {
  markProcessing: boolean;
  boardsToEnqueue: WeeklyBoardKind[];
}

/**
 * A weekly rollover can be retried after a scheduler/task-queue interruption.
 * Deterministic task ids make re-enqueue safe, while completed boards are not
 * scheduled again.
 */
export function weeklyRolloverPlan(
  input: WeeklyRolloverPlanInput,
): WeeklyRolloverPlan | null {
  if (input.state === "closed") return null;
  if (input.endsAtMs === null || input.endsAtMs > input.nowMs) return null;
  if (input.state !== "open" && input.state !== "processing") return null;

  const boardsToEnqueue: WeeklyBoardKind[] = [];
  if (!input.rpRewardsComplete) boardsToEnqueue.push("rp");
  if (!input.goldRewardsComplete) boardsToEnqueue.push("gold");
  if (boardsToEnqueue.length === 0) return null;

  return {
    markProcessing: input.state === "open",
    boardsToEnqueue,
  };
}
