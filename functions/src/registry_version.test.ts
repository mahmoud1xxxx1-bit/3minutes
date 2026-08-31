import assert from "node:assert/strict";
import test from "node:test";

import { APPROVED_GAMES, REGISTRY_VERSION, gameSequence } from "./registry.js";

test("server registry matches Flutter v7 active library", () => {
  assert.equal(REGISTRY_VERSION, 7);
  assert.equal(APPROVED_GAMES.length, 11);
  assert.equal(APPROVED_GAMES.some((game) => game.id === "find_differences"), true);
});

test("server registry v7 sequence matches Flutter cross-platform vector", () => {
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
