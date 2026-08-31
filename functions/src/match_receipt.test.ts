import assert from "node:assert/strict";
import { test } from "node:test";

import { buildMatchReceipt } from "./match_receipt.js";
import type { MiniGameEvidence } from "./registry.js";

function completedEvidence(gameIndex: number, durationMs: number): MiniGameEvidence {
  return {
    gameId: `game_${gameIndex}`,
    gameVersion: 1,
    gameIndex,
    gameSeed: 1000 + gameIndex,
    completed: true,
    progressStep: 1,
    progressStepCount: 1,
    score: 1000,
    accuracy: 0.9,
    mistakes: gameIndex,
    durationMs,
  };
}

function failedEvidence(
  gameIndex: number,
  progressStep: number,
  progressStepCount: number,
  durationMs: number,
): MiniGameEvidence {
  return {
    gameId: `game_${gameIndex}`,
    gameVersion: 1,
    gameIndex,
    gameSeed: 1000 + gameIndex,
    completed: false,
    progressStep,
    progressStepCount,
    score: 0,
    accuracy: 0.5,
    mistakes: 1,
    durationMs,
  };
}

test("receipt decides the player who completed more 1000-point games", () => {
  const a = [
    completedEvidence(0, 9000),
    completedEvidence(1, 9000),
    completedEvidence(2, 9000),
    failedEvidence(3, 1, 3, 9000),
  ];
  const b = [
    completedEvidence(0, 5000),
    completedEvidence(1, 5000),
    failedEvidence(2, 2, 3, 5000),
    failedEvidence(3, 2, 3, 5000),
  ];

  const receipt = buildMatchReceipt({
    matchId: "m1",
    playerAId: "A",
    playerBId: "B",
    evidenceA: a,
    evidenceB: b,
  });

  assert.equal(receipt.winnerId, "A");
  assert.equal(receipt.reason, "score");
  assert.equal(receipt.playerATotalScore, 3000);
  assert.equal(receipt.playerBTotalScore, 2000);
  assert.equal(receipt.playerACompletedGames, 3);
  assert.equal(receipt.playerBCompletedGames, 2);
});

test("equal completed games are decided by farther discrete progress", () => {
  const a = [
    completedEvidence(0, 9000),
    completedEvidence(1, 9000),
    failedEvidence(2, 2, 3, 9000),
    failedEvidence(3, 0, 3, 9000),
  ];
  const b = [
    completedEvidence(0, 8000),
    completedEvidence(1, 8000),
    failedEvidence(2, 1, 3, 8000),
    failedEvidence(3, 0, 3, 8000),
  ];

  const receipt = buildMatchReceipt({
    matchId: "m2",
    playerAId: "A",
    playerBId: "B",
    evidenceA: a,
    evidenceB: b,
  });

  assert.equal(receipt.winnerId, "A");
  assert.equal(receipt.reason, "progress");
});

test("same score and same failed progress is double fail even if times differ", () => {
  const a = [
    completedEvidence(0, 9000),
    completedEvidence(1, 9000),
    failedEvidence(2, 2, 3, 10000),
    failedEvidence(3, 0, 3, 10000),
  ];
  const b = [
    completedEvidence(0, 5000),
    completedEvidence(1, 5000),
    failedEvidence(2, 2, 3, 5000),
    failedEvidence(3, 0, 3, 5000),
  ];

  const receipt = buildMatchReceipt({
    matchId: "m3",
    playerAId: "A",
    playerBId: "B",
    evidenceA: a,
    evidenceB: b,
  });

  assert.equal(receipt.winnerId, null);
  assert.equal(receipt.loserId, null);
  assert.equal(receipt.reason, "doubleFail");
});

test("when both clear all four, lower total time breaks the 4000-point tie", () => {
  const a = [0, 1, 2, 3].map((index) => completedEvidence(index, 9000));
  const b = [0, 1, 2, 3].map((index) => completedEvidence(index, 10000));

  const receipt = buildMatchReceipt({
    matchId: "m4",
    playerAId: "A",
    playerBId: "B",
    evidenceA: a,
    evidenceB: b,
  });

  assert.equal(receipt.winnerId, "A");
  assert.equal(receipt.reason, "timeTieBreaker");
  assert.equal(receipt.playerATotalDurationMs, 36000);
  assert.equal(receipt.playerBTotalDurationMs, 40000);
});

test("full clear with exact score and time never fabricates a winner", () => {
  const a = [0, 1, 2, 3].map((index) => completedEvidence(index, 9000));
  const b = [0, 1, 2, 3].map((index) => completedEvidence(index, 9000));

  const receipt = buildMatchReceipt({
    matchId: "m5",
    playerAId: "A",
    playerBId: "B",
    evidenceA: a,
    evidenceB: b,
  });

  assert.equal(receipt.winnerId, null);
  assert.equal(receipt.reason, "exactTie");
});

test("receipt rejects players with different locked game evidence", () => {
  const a = [0, 1, 2, 3].map((index) => completedEvidence(index, 9000));
  const b = [0, 1, 2, 3].map((index) => completedEvidence(index, 9000));
  b[2] = { ...b[2]!, gameSeed: 999999 };

  assert.throws(() => buildMatchReceipt({
    matchId: "m6",
    playerAId: "A",
    playerBId: "B",
    evidenceA: a,
    evidenceB: b,
  }));
});
