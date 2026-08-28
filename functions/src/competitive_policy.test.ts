import test from "node:test";
import assert from "node:assert/strict";
import {
  COMPETITIVE_DURATION_MS,
  COMPETITIVE_GAME_COUNT,
  COMPETITIVE_PICKS_PER_PLAYER,
  COMPETITIVE_WAGERS,
  DAILY_GOLD_GRANT,
  competitiveReward,
  isCompetitiveWager,
} from "./competitive_policy.js";

test("approved competitive constants remain stable", () => {
  assert.deepEqual(COMPETITIVE_WAGERS, [180, 500, 1000]);
  assert.equal(DAILY_GOLD_GRANT, 1000);
  assert.equal(COMPETITIVE_GAME_COUNT, 4);
  assert.equal(COMPETITIVE_PICKS_PER_PLAYER, 2);
  assert.equal(COMPETITIVE_DURATION_MS, 180000);
});

test("only approved GOLD wagers are accepted", () => {
  assert.equal(isCompetitiveWager(180), true);
  assert.equal(isCompetitiveWager(500), true);
  assert.equal(isCompetitiveWager(1000), true);
  assert.equal(isCompetitiveWager(250), false);
});

test("winner receives opponent stake plus normal Coins and RP reward", () => {
  assert.deepEqual(competitiveReward("win", 500), {
    goldDelta: 500,
    coinsDelta: 30,
    rpDelta: 30,
    xp: 120,
  });
});

test("loser loses held stake but still follows existing Coins and RP policy", () => {
  assert.deepEqual(competitiveReward("loss", 500), {
    goldDelta: -500,
    coinsDelta: 10,
    rpDelta: -18,
    xp: 55,
  });
});
