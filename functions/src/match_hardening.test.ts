import assert from "node:assert/strict";
import test from "node:test";
import { compareMatch } from "./policy.js";
import { validateEvidenceSequence, computeAuthoritativeTime, validateTechnicalCancelTime } from "./match_hardening.js";

test("Evidence sequence allows forward progression and idempotent retry", () => {
  assert.equal(validateEvidenceSequence(0, 1), "ok", "First game submit should be ok");
  assert.equal(validateEvidenceSequence(1, 1), "idempotent", "Idempotent duplicate submit should return idempotent");
  assert.equal(validateEvidenceSequence(5, 6), "ok", "Moving forward by 1 is ok");
  assert.equal(validateEvidenceSequence(1, 3), "invalid", "Skipping games is invalid");
  assert.equal(validateEvidenceSequence(3, 2), "invalid", "Going backwards is invalid");
});

test("Time manipulation limits clamp impossible durations (Server Authoritative)", () => {
  const startMs = 1000;
  
  // Submit at 2000 (1000ms server elapsed). Client claims 1000ms. Valid.
  assert.equal(computeAuthoritativeTime(1000, startMs, 2000, 3000), 1000, "Accurate duration accepted");
  
  // Fake fast: Client claims 1ms. Server elapsed 10000ms. Allowed minimum: 10000 - 3000 = 7000. Clamped to 7000.
  assert.equal(computeAuthoritativeTime(1, startMs, 11000, 3000), 7000, "Fake fast duration (under-reporting) is clamped up to minimum possible");
  
  // Fake slow: Client claims 50000ms. Server elapsed 10000ms. Allowed max: 10000 + 3000 = 13000. Clamped to 13000.
  assert.equal(computeAuthoritativeTime(50000, startMs, 11000, 3000), 13000, "Fake slow duration (over-reporting) is clamped down to maximum possible");

  // null start time is always valid
  assert.equal(computeAuthoritativeTime(99999, null, 2000), 99999, "Null start time allows claimed duration");
});

test("Technical cancel is only allowed in the first 15 seconds", () => {
  const startMs = 100000;
  assert.equal(validateTechnicalCancelTime(startMs, 105000), true, "Cancel at 5s is valid");
  assert.equal(validateTechnicalCancelTime(startMs, 115000), true, "Cancel at 15s is valid");
  assert.equal(validateTechnicalCancelTime(startMs, 115001), false, "Cancel past 15s is blocked");
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
