import assert from "node:assert/strict";
import test from "node:test";

import { APPROVED_GAMES, REGISTRY_VERSION, gameSequence } from "./registry.js";

test("server registry matches Flutter v7 active library", () => {
  assert.equal(REGISTRY_VERSION, 7);
  assert.equal(APPROVED_GAMES.length, 13);
  assert.equal(APPROVED_GAMES.some((game) => game.id === "find_differences"), false);
});

test("server registry v7 sequence matches Flutter cross-platform vector", () => {
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
