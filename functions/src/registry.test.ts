import assert from "node:assert/strict";
import { test } from "node:test";

import { APPROVED_GAMES, REGISTRY_VERSION, gameSequence } from "./registry.js";

test("registry v5 includes the three approved production games", () => {
  assert.equal(REGISTRY_VERSION, 5);
  assert.equal(APPROVED_GAMES.length, 13);
  for (const id of ["mole_strike", "follow_the_cup", "path_rush"]) {
    assert.equal(APPROVED_GAMES.filter((game) => game.id === id).length, 1);
  }
});

test("registry v5 keeps the Flutter cross-platform vector", () => {
  assert.deepEqual(
    gameSequence(20260818, 8).map((game) => game.id),
    [
      "odd_one_out",
      "direction_swipe",
      "follow_the_cup",
      "memory_flash",
      "tap_target",
      "color_match",
      "reaction_stop",
      "quick_math",
    ],
  );
});
