import assert from "node:assert/strict";
import test from "node:test";

import { QUICK_REWARDS, quickPairMultiplier } from "./quick.js";

test("Quick rewards are lower than Ranked-style progression and never modify RP", () => {
  assert.deepEqual(QUICK_REWARDS.win, { xp: 70, coins: 18 });
  assert.deepEqual(QUICK_REWARDS.tie, { xp: 50, coins: 12 });
  assert.deepEqual(QUICK_REWARDS.loss, { xp: 30, coins: 6 });
  for (const reward of Object.values(QUICK_REWARDS)) {
    assert.equal("rpDelta" in reward, false);
    assert.ok(reward.coins >= 0);
    assert.ok(reward.xp >= 0);
  }
});

test("Quick same-pair farming is throttled and then stopped", () => {
  assert.equal(quickPairMultiplier(0), 1);
  assert.equal(quickPairMultiplier(9), 1);
  assert.equal(quickPairMultiplier(10), 0.25);
  assert.equal(quickPairMultiplier(19), 0.25);
  assert.equal(quickPairMultiplier(20), 0);
  assert.equal(quickPairMultiplier(200), 0);
});
