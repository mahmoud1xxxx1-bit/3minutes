import assert from "node:assert/strict";
import test from "node:test";

import {
  freePassCoins,
  premiumPassCoins,
  seasonPassLevelForXp,
  seasonScopedPassState,
} from "./progression.js";

test("season pass state resets when stored season differs", () => {
  const state = seasonScopedPassState(
    {
      seasonId: "season_1",
      seasonXp: 9999,
      premiumUnlocked: true,
      claimedFreeLevels: [1, 2, 3],
      claimedPremiumLevels: [1, 2],
    },
    "season_2",
  );

  assert.deepEqual(state, {
    seasonId: "season_2",
    seasonXp: 0,
    premiumUnlocked: false,
    claimedFreeLevels: [],
    claimedPremiumLevels: [],
  });
});

test("season pass state preserves only current-season progress", () => {
  const state = seasonScopedPassState(
    {
      seasonId: "season_7",
      seasonXp: 1250,
      premiumUnlocked: true,
      claimedFreeLevels: [3, 1, 3, 99],
      claimedPremiumLevels: [2, 1],
    },
    "season_7",
  );

  assert.equal(state.seasonXp, 1250);
  assert.equal(state.premiumUnlocked, true);
  assert.deepEqual(state.claimedFreeLevels, [1, 3]);
  assert.deepEqual(state.claimedPremiumLevels, [1, 2]);
});

test("pass level and coin reward curves remain unchanged by scoping fix", () => {
  assert.equal(seasonPassLevelForXp(0), 1);
  assert.equal(seasonPassLevelForXp(500), 2);
  assert.equal(seasonPassLevelForXp(14500), 30);
  assert.equal(seasonPassLevelForXp(999999), 30);
  assert.equal(freePassCoins(1), 50);
  assert.equal(freePassCoins(30), 340);
  assert.equal(premiumPassCoins(1), 120);
  assert.equal(premiumPassCoins(30), 700);
});
