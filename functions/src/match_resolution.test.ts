import assert from "node:assert/strict";
import { test } from "node:test";

import { compareMatch, type MatchProgress } from "./policy.js";
import { MATCH_GAME_COUNT } from "./registry.js";

function progress(options: {
  score: number;
  elapsedMs: number;
  completedAtMs?: number;
}): MatchProgress {
  return {
    completedGames: MATCH_GAME_COUNT,
    totalScore: options.score,
    accuracyTotal: MATCH_GAME_COUNT,
    mistakes: 0,
    elapsedMs: options.elapsedMs,
    completedAtMs: options.completedAtMs ?? 100000,
  };
}

test("higher score wins even when that player reaches the server later", () => {
  const playerA = progress({ score: 3200, elapsedMs: 80000, completedAtMs: 200000 });
  const playerB = progress({ score: 3100, elapsedMs: 70000, completedAtMs: 150000 });

  assert.equal(compareMatch(playerA, playerB, MATCH_GAME_COUNT), "playerA");
});

test("equal score is resolved by accumulated gameplay time", () => {
  const playerA = progress({ score: 3200, elapsedMs: 75400, completedAtMs: 250000 });
  const playerB = progress({ score: 3200, elapsedMs: 81250, completedAtMs: 180000 });

  assert.equal(compareMatch(playerA, playerB, MATCH_GAME_COUNT), "playerA");
});

test("exact score and gameplay-time equality is never resolved randomly", () => {
  const playerA = progress({ score: 3200, elapsedMs: 75400, completedAtMs: 180000 });
  const playerB = progress({ score: 3200, elapsedMs: 75400, completedAtMs: 260000 });

  assert.equal(compareMatch(playerA, playerB, MATCH_GAME_COUNT), "tie");
});
