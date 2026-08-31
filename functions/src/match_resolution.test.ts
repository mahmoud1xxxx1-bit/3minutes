import assert from "node:assert/strict";
import { test } from "node:test";

import { compareMatch, type MatchProgress } from "./policy.js";
import { MATCH_GAME_COUNT } from "./registry.js";

function progress(options: {
  score: number;
  elapsedMs: number;
  games?: number;
  completedAtMs?: number;
}): MatchProgress {
  return {
    completedGames: options.games ?? MATCH_GAME_COUNT,
    totalScore: options.score,
    accuracyTotal: 0,
    mistakes: 0,
    elapsedMs: options.elapsedMs,
    completedAtMs: options.completedAtMs ?? null,
  };
}

test("higher official score wins regardless of arrival time", () => {
  const playerA = progress({ score: 3000, elapsedMs: 80000, completedAtMs: 200000 });
  const playerB = progress({ score: 2000, elapsedMs: 70000, completedAtMs: 150000 });
  assert.equal(compareMatch(playerA, playerB, MATCH_GAME_COUNT), "playerA");
});

test("equal points at timeout are decided by farther game position", () => {
  const playerA = progress({ score: 1000, games: 1, elapsedMs: 50000 });
  const playerB = progress({ score: 1000, games: 2, elapsedMs: 70000 });
  assert.equal(compareMatch(playerA, playerB, MATCH_GAME_COUNT), "playerB");
});

test("time breaks a tie only after both correctly clear all four games", () => {
  const playerA = progress({ score: 4000, elapsedMs: 75400 });
  const playerB = progress({ score: 4000, elapsedMs: 81250 });
  assert.equal(compareMatch(playerA, playerB, MATCH_GAME_COUNT), "playerA");
});

test("same failed score and same game position remains a true tie", () => {
  const playerA = progress({ score: 2000, games: 3, elapsedMs: 75400 });
  const playerB = progress({ score: 2000, games: 3, elapsedMs: 81250 });
  assert.equal(compareMatch(playerA, playerB, MATCH_GAME_COUNT), "tie");
});

test("exact full-clear score and time equality is never resolved randomly", () => {
  const playerA = progress({ score: 4000, elapsedMs: 75400 });
  const playerB = progress({ score: 4000, elapsedMs: 75400 });
  assert.equal(compareMatch(playerA, playerB, MATCH_GAME_COUNT), "tie");
});
