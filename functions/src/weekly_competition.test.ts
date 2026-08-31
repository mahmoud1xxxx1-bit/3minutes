import assert from "node:assert/strict";
import { test } from "node:test";

import {
  WEEK_MS,
  economicGoldScoreDelta,
  rankedWeeklyDelta,
  weeklyCompetitionId,
  weeklyRewardFor,
  weeklyScoreWindowOpen,
} from "./weekly_competition.js";

test("weekly competition ids roll exactly every seven days", () => {
  assert.equal(weeklyCompetitionId(0), "week_0");
  assert.equal(weeklyCompetitionId(WEEK_MS - 1), "week_0");
  assert.equal(weeklyCompetitionId(WEEK_MS), "week_1");
});

test("weekly score window freezes as soon as rollover starts", () => {
  assert.equal(weeklyScoreWindowOpen(undefined), true);
  assert.equal(weeklyScoreWindowOpen(null), true);
  assert.equal(weeklyScoreWindowOpen("open"), true);
  assert.equal(weeklyScoreWindowOpen("processing"), false);
  assert.equal(weeklyScoreWindowOpen("closed"), false);
});

test("RP weekly leaderboard rewards match the approved table", () => {
  assert.deepEqual(weeklyRewardFor("rp", 1, true), { gold: 3000, stars: 0 });
  assert.deepEqual(weeklyRewardFor("rp", 2, true), { gold: 2000, stars: 0 });
  assert.deepEqual(weeklyRewardFor("rp", 3, true), { gold: 1500, stars: 0 });
  assert.deepEqual(weeklyRewardFor("rp", 4, true), { gold: 300, stars: 0 });
  assert.deepEqual(weeklyRewardFor("rp", 99, false), { gold: 0, stars: 0 });
});

test("Gold weekly leaderboard rewards match the approved table", () => {
  assert.deepEqual(weeklyRewardFor("gold", 1, true), { gold: 3000, stars: 5 });
  assert.deepEqual(weeklyRewardFor("gold", 2, true), { gold: 2500, stars: 1 });
  assert.deepEqual(weeklyRewardFor("gold", 3, true), { gold: 2000, stars: 0 });
  assert.deepEqual(weeklyRewardFor("gold", 4, true), { gold: 300, stars: 0 });
});

test("ranked settlement contributes RP and net Gold without changing lifetime balances", () => {
  assert.deepEqual(rankedWeeklyDelta({ rpDelta: 30, goldNetMatchDelta: 250 }), {
    rpScoreDelta: 30,
    goldScoreDelta: 250,
  });
  assert.deepEqual(rankedWeeklyDelta({ rpDelta: -18, goldNetMatchDelta: -500 }), {
    rpScoreDelta: -18,
    goldScoreDelta: -500,
  });
});

test("all authoritative Gold economic mutations can affect the Gold board", () => {
  assert.equal(economicGoldScoreDelta(100), 100);
  assert.equal(economicGoldScoreDelta(-250), -250);
});
