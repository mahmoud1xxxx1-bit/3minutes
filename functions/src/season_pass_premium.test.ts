import assert from "node:assert/strict";
import test from "node:test";

import {
  PREMIUM_SEASON_PASS_BASE_PLAN_ID,
  PREMIUM_SEASON_PASS_PRODUCT_ID,
  PREMIUM_SEASON_PASS_STAR_LEVELS,
  PREMIUM_SEASON_PASS_USD,
  premiumSeasonPassStarsForLevel,
} from "./season_pass_premium.js";

test("Premium Season Pass product contract is the approved 30-day prepaid plan", () => {
  assert.equal(PREMIUM_SEASON_PASS_PRODUCT_ID, "premium_season_pass_30d");
  assert.equal(PREMIUM_SEASON_PASS_BASE_PLAN_ID, "prepaid-30d");
  assert.equal(PREMIUM_SEASON_PASS_USD, 30);
});

test("Premium Season Pass awards at most five stars per season", () => {
  assert.deepEqual([...PREMIUM_SEASON_PASS_STAR_LEVELS], [6, 12, 18, 24, 30]);
  let total = 0;
  for (let level = 1; level <= 30; level += 1) {
    const stars = premiumSeasonPassStarsForLevel(level);
    assert.ok(stars === 0 || stars === 1);
    total += stars;
  }
  assert.equal(total, 5);
});

test("non-milestone Premium levels never award Prestige Stars", () => {
  for (const level of [1, 5, 7, 11, 13, 17, 19, 23, 25, 29]) {
    assert.equal(premiumSeasonPassStarsForLevel(level), 0);
  }
});
