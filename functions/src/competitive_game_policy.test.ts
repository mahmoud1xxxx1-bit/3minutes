import assert from "node:assert/strict";
import test from "node:test";

import {
  registeredCompetitiveGameIds,
  validateCompetitiveGameScore,
} from "./competitive_game_policy.js";

test("competitive scoring is fail-closed before game package integration", () => {
  assert.equal(registeredCompetitiveGameIds().length, 0);
  assert.throws(
    () => validateCompetitiveGameScore("unregistered_game", 10, 10),
    (error: unknown) => {
      const value = error as { code?: string };
      return value.code === "functions/failed-precondition" || value.code === "failed-precondition";
    },
  );
});
