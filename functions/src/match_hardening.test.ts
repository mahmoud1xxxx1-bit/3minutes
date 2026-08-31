import assert from "node:assert/strict";
import test from "node:test";
import { compareMatch } from "./policy.js";
import { validateEvidenceSequence, validateTimeManipulation, validateTechnicalCancelTime } from "./match_hardening.js";

test("Evidence sequence allows forward progression and idempotent retry", () => {
  assert.equal(validateEvidenceSequence(0, 1), "ok", "First game submit should be ok");
  assert.equal(validateEvidenceSequence(1, 1), "idempotent", "Idempotent duplicate submit should return idempotent");
  assert.equal(validateEvidenceSequence(5, 6), "ok", "Moving forward by 1 is ok");
  assert.equal(validateEvidenceSequence(1, 3), "invalid", "Skipping games is invalid");
  assert.equal(validateEvidenceSequence(3, 2), "invalid", "Going backwards is invalid");
});

test("Time manipulation limits block impossible durations", () => {
  const startMs = 1000;
  
  // Submit at 2000 (1000ms elapsed). Submitted duration: 5000ms. With 10s buffer: 1000 + 10000 = 11000ms allowed.
  assert.equal(validateTimeManipulation(5000, startMs, 2000), true, "Fast submit within buffer is allowed");
  
  // Submit at 2000. Submitted duration: 12000ms. 12000 > 11000, blocked.
  assert.equal(validateTimeManipulation(12000, startMs, 2000), false, "Duration significantly larger than real time + buffer is blocked");

  // null start time is always valid (hasn't started countdown)
  assert.equal(validateTimeManipulation(99999, null, 2000), true, "Null start time is valid");
});

test("Technical cancel is only allowed in the first 15 seconds", () => {
  const startMs = 100000;
  
  // Cancel at 105000 (5s in) -> valid
  assert.equal(validateTechnicalCancelTime(startMs, 105000), true, "Cancel at 5s is valid");
  
  // Cancel at 115000 (15s in) -> valid
  assert.equal(validateTechnicalCancelTime(startMs, 115000), true, "Cancel at 15s is valid");

  // Cancel at 115001 (15.001s in) -> invalid
  assert.equal(validateTechnicalCancelTime(startMs, 115001), false, "Cancel past 15s is blocked");

  // null start time -> valid
  assert.equal(validateTechnicalCancelTime(null, 200000), true, "Cancel before start is valid");
});

test("compareMatch handles forfeits correctly without throwing", () => {
  const pA = {
    completedGames: 8,
    totalScore: 8000,
    accuracyTotal: 8,
    mistakes: 0,
    elapsedMs: 80000,
    completedAtMs: 10000,
  };
  const pB = {
    completedGames: 8,
    totalScore: 7000,
    accuracyTotal: 7,
    mistakes: 1,
    elapsedMs: 85000,
    completedAtMs: 11000,
  };

  assert.equal(compareMatch(pA, pB, 8), "playerA", "Normal match A wins");
  assert.equal(compareMatch({ ...pA, forfeited: true }, pB, 8), "playerB", "Forfeited A loses to B");
  assert.equal(compareMatch(pA, { ...pB, forfeited: true }, 8), "playerA", "Forfeited B loses to A");
  assert.equal(compareMatch({ ...pA, forfeited: true }, { ...pB, forfeited: true }, 8), "tie", "Double forfeit is a tie");
});
