import test from "node:test";
import assert from "node:assert/strict";

import { startingRpForPeakTier, starsForPeakTier } from "./policy.js";
import { advanceSeasonalRecord } from "./season_integrity.js";

test("seasonal result accounting keeps win loss and tie counters separate", () => {
  const base = { wins: 4, losses: 3, ties: 2 };

  assert.deepEqual(advanceSeasonalRecord(base, "win"), {
    wins: 5,
    losses: 3,
    ties: 2,
  });
  assert.deepEqual(advanceSeasonalRecord(base, "loss"), {
    wins: 4,
    losses: 4,
    ties: 2,
  });
  assert.deepEqual(advanceSeasonalRecord(base, "tie"), {
    wins: 4,
    losses: 3,
    ties: 3,
  });
});

test("prestige star and soft reset tables remain locked by peak tier", () => {
  assert.deepEqual(
    [
      "bronze",
      "silver",
      "gold",
      "platinum",
      "diamond",
      "master",
      "grandmaster",
      "legend",
    ].map((tier) => starsForPeakTier(tier as Parameters<typeof starsForPeakTier>[0])),
    [1, 2, 4, 7, 11, 16, 24, 35],
  );

  assert.deepEqual(
    [
      "bronze",
      "silver",
      "gold",
      "platinum",
      "diamond",
      "master",
      "grandmaster",
      "legend",
    ].map((tier) => startingRpForPeakTier(tier as Parameters<typeof startingRpForPeakTier>[0])),
    [0, 250, 500, 900, 1400, 2200, 3500, 5000],
  );
});
