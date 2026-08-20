import assert from "node:assert/strict";
import { test } from "node:test";

import {
  APPROVED_GAMES,
  REGISTRY_VERSION,
  gameSequence,
} from "./registry.js";

test("registry v4 includes the approved Mole Strike game", () => {
  assert.equal(REGISTRY_VERSION, 4);
  assert.equal(APPROVED_GAMES.length, 11);
  assert.equal(
    APPROVED_GAMES.filter((game) => game.id === "mole_strike").length,
    1,
  );
});

test("registry v4 keeps the Flutter cross-platform vector", () => {
  assert.deepEqual(
    gameSequence(20260818, 8).map((game) => game.id),
    [
      "odd_one_out",
      "tap_target",
      "quick_math",
      "reaction_stop",
      "direction_swipe",
      "number_order",
      "memory_flash",
      "color_match",
    ],
  );
});
