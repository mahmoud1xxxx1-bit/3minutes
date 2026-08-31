import assert from "node:assert/strict";
import { test } from "node:test";

import { buildMatchReceipt } from "./match_receipt.js";
import type { MiniGameEvidence } from "./registry.js";

function evidence(gameIndex: number, score: number, durationMs: number): MiniGameEvidence {
  return {
    gameId: `game_${gameIndex}`,
    gameVersion: 1,
    gameIndex,
    gameSeed: 1000 + gameIndex,
    score,
    accuracy: 0.9,
    mistakes: gameIndex,
    durationMs,
  };
}

test("receipt records every game and decides higher total score", () => {
  const a = [
    evidence(0, 900, 9000),
    evidence(1, 800, 9000),
    evidence(2, 700, 9000),
    evidence(3, 600, 9000),
  ];
  const b = [
    evidence(0, 500, 5000),
    evidence(1, 500, 5000),
    evidence(2, 500, 5000),
    evidence(3, 500, 5000),
  ];

  const receipt = buildMatchReceipt({
    matchId: "m1",
    playerAId: "A",
    playerBId: "B",
    evidenceA: a,
    evidenceB: b,
  });

  assert.equal(receipt.winnerId, "A");
  assert.equal(receipt.loserId, "B");
  assert.equal(receipt.reason, "score");
  assert.equal(receipt.playerATotalScore, 3000);
  assert.equal(receipt.playerBTotalScore, 2000);
  assert.equal(receipt.games.length, 4);
});

test("receipt explains score tie resolved by lower four-game time", () => {
  const a = [0, 1, 2, 3].map((index) => evidence(index, 500, 9000));
  const b = [0, 1, 2, 3].map((index) => evidence(index, 500, 10000));

  const receipt = buildMatchReceipt({
    matchId: "m2",
    playerAId: "A",
    playerBId: "B",
    evidenceA: a,
    evidenceB: b,
  });

  assert.equal(receipt.winnerId, "A");
  assert.equal(receipt.reason, "timeTieBreaker");
  assert.equal(receipt.playerATotalDurationMs, 36000);
  assert.equal(receipt.playerBTotalDurationMs, 40000);
  assert.equal(receipt.timeDifferenceMs, 4000);
});

test("receipt never fabricates a winner for exact score and time equality", () => {
  const a = [0, 1, 2, 3].map((index) => evidence(index, 500, 9000));
  const b = [0, 1, 2, 3].map((index) => evidence(index, 500, 9000));

  const receipt = buildMatchReceipt({
    matchId: "m3",
    playerAId: "A",
    playerBId: "B",
    evidenceA: a,
    evidenceB: b,
  });

  assert.equal(receipt.winnerId, null);
  assert.equal(receipt.loserId, null);
  assert.equal(receipt.reason, "exactTie");
});

test("receipt rejects players with different locked game evidence", () => {
  const a = [0, 1, 2, 3].map((index) => evidence(index, 500, 9000));
  const b = [0, 1, 2, 3].map((index) => evidence(index, 500, 9000));
  b[2] = { ...b[2]!, gameSeed: 999999 };

  assert.throws(() => buildMatchReceipt({
    matchId: "m4",
    playerAId: "A",
    playerBId: "B",
    evidenceA: a,
    evidenceB: b,
  }));
});
