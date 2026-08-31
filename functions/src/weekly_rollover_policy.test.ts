import assert from "node:assert/strict";
import { test } from "node:test";

import { weeklyRolloverPlan } from "./weekly_rollover_policy.js";

test("open expired week starts both reward boards", () => {
  assert.deepEqual(
    weeklyRolloverPlan({
      state: "open",
      endsAtMs: 100,
      nowMs: 101,
      rpRewardsComplete: false,
      goldRewardsComplete: false,
    }),
    { markProcessing: true, boardsToEnqueue: ["rp", "gold"] },
  );
});

test("processing week can safely re-enqueue unfinished deterministic work", () => {
  assert.deepEqual(
    weeklyRolloverPlan({
      state: "processing",
      endsAtMs: 100,
      nowMs: 500,
      rpRewardsComplete: true,
      goldRewardsComplete: false,
    }),
    { markProcessing: false, boardsToEnqueue: ["gold"] },
  );
});

test("closed future or fully completed weeks do not enqueue rewards", () => {
  assert.equal(
    weeklyRolloverPlan({
      state: "closed",
      endsAtMs: 100,
      nowMs: 500,
      rpRewardsComplete: false,
      goldRewardsComplete: false,
    }),
    null,
  );
  assert.equal(
    weeklyRolloverPlan({
      state: "open",
      endsAtMs: 600,
      nowMs: 500,
      rpRewardsComplete: false,
      goldRewardsComplete: false,
    }),
    null,
  );
  assert.equal(
    weeklyRolloverPlan({
      state: "processing",
      endsAtMs: 100,
      nowMs: 500,
      rpRewardsComplete: true,
      goldRewardsComplete: true,
    }),
    null,
  );
});
