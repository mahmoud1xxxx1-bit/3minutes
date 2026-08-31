import assert from "node:assert/strict";
import { test } from "node:test";

import {
  INITIAL_WEEKLY_STANDING,
  nextWeeklyStanding,
} from "./weekly_ranking.js";

test("equal weekly scores share a paid standing without arbitrary uid tie break", () => {
  const first = nextWeeklyStanding(INITIAL_WEEKLY_STANDING, 120);
  const tied = nextWeeklyStanding(first, 120);
  const third = nextWeeklyStanding(tied, 80);

  assert.equal(first.awardedStanding, 1);
  assert.equal(tied.awardedStanding, 1);
  assert.equal(third.awardedStanding, 3);
});

test("distinct descending scores receive natural standings", () => {
  const first = nextWeeklyStanding(INITIAL_WEEKLY_STANDING, 500);
  const second = nextWeeklyStanding(first, 250);
  const third = nextWeeklyStanding(second, 0);
  const fourth = nextWeeklyStanding(third, -100);

  assert.deepEqual(
    [first.awardedStanding, second.awardedStanding, third.awardedStanding, fourth.awardedStanding],
    [1, 2, 3, 4],
  );
});
