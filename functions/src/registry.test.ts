import assert from "node:assert/strict";
import { test } from "node:test";

import { APPROVED_GAMES, REGISTRY_VERSION, gameSequence } from "./registry.js";

test("registry v7 includes the 11 approved production games", () => {
  assert.equal(REGISTRY_VERSION, 7);
  assert.equal(APPROVED_GAMES.length, 11);
  for (const id of ["mole_strike", "follow_the_cup", "path_rush"]) {
    assert.equal(APPROVED_GAMES.filter((game) => game.id === id).length, 1);
  }
});

test("registry v7 keeps the Flutter cross-platform vector", () => {
  assert.deepEqual(
    gameSequence(20260818, 8).map((game) => game.id),
    [
      "level_devil",
      "find_differences",
      "key_escape",
      "path_rush",
      "ninja_slice",
      "follow_the_cup",
      "mirror_control",
      "mole_strike",
    ],
  );
});
