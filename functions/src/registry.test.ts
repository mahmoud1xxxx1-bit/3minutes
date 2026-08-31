import assert from "node:assert/strict";
import { test } from "node:test";

import {
  APPROVED_GAMES,
  MATCH_GAME_COUNT,
  REGISTRY_VERSION,
  gameSequence,
} from "./registry.js";

test("registry v7 matches the current Flutter production catalog", () => {
  assert.equal(REGISTRY_VERSION, 7);
  assert.equal(MATCH_GAME_COUNT, 4);
  assert.deepEqual(
    APPROVED_GAMES.map((game) => [game.id, game.category]),
    [
      ["find_differences", "precision"],
      ["follow_the_cup", "memory"],
      ["key_escape", "logic"],
      ["level_devil", "reaction"],
      ["mirror_control", "precision"],
      ["mole_strike", "reaction"],
      ["ninja_slice", "reaction"],
      ["onet_connect", "logic"],
      ["path_rush", "logic"],
      ["traffic_loop", "logic"],
      ["hidden_pigeon", "precision"],
    ],
  );
});

test("registry v7 keeps the Flutter four-game cross-platform vector", () => {
  assert.deepEqual(
    gameSequence(20260818, MATCH_GAME_COUNT).map((game) => game.id),
    ["key_escape", "follow_the_cup", "find_differences", "mole_strike"],
  );
});

test("four-game competitive sequence contains one game from every category", () => {
  const sequence = gameSequence(982451653, MATCH_GAME_COUNT);
  assert.equal(sequence.length, 4);
  assert.equal(new Set(sequence.map((game) => game.id)).size, 4);
  assert.deepEqual(
    new Set(sequence.map((game) => game.category)),
    new Set(["reaction", "logic", "memory", "precision"]),
  );
});
