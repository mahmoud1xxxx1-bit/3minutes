import assert from "node:assert/strict";
import test from "node:test";
import { compareMatch } from "./policy.js";
import { validateEvidenceSequence, computeServerAuthoritativeElapsed, isSystemFailure } from "./match_hardening.js";

test("Evidence sequence allows forward progression and batching", () => {
  assert.equal(validateEvidenceSequence(0, 1), "ok", "First game submit should be ok");
  assert.equal(validateEvidenceSequence(1, 1), "idempotent", "Idempotent duplicate submit should return idempotent");
  assert.equal(validateEvidenceSequence(0, 3), "ok", "Batching 3 games (e.g. after reconnect) is valid");
  assert.equal(validateEvidenceSequence(5, 6), "ok", "Moving forward by 1 is ok");
  assert.equal(validateEvidenceSequence(8, 10), "ok", "Batching the last two games is ok");
  assert.equal(validateEvidenceSequence(3, 2), "invalid", "Going backwards is invalid");
  assert.equal(validateEvidenceSequence(0, 11), "invalid", "Exceeding max games is invalid");
});

test("Time Validation uses Server Absolute Time (Server-Authoritative)", () => {
  const startMs = 100000;
  
  // Fake 1ms time is completely ignored, because the client's time isn't passed here at all.
  // We only pass the completed games count.
  // 1 game submitted at 110000 (10s real elapsed). Transition allowance is 2.5s.
  // Authoritative time = 10s - 2.5s = 7.5s
  assert.equal(computeServerAuthoritativeElapsed(startMs, 110000, 1), 7500, "Normal latency properly calculates tiebreak");

  // Reconnect: Player submits 3 games at once after a drop. 
  // Real elapsed = 30s. Transition allowance = 3 * 2.5s = 7.5s.
  // Authoritative time = 30s - 7.5s = 22.5s
  assert.equal(computeServerAuthoritativeElapsed(startMs, 130000, 3), 22500, "Reconnect batch handles accumulated time safely");

  // Fake very large time / extreme lag: Real elapsed = 600s. 10 games = 25s transition.
  // Authoritative = 575s. The player loses tiebreaker due to massive lag. This is fair.
  assert.equal(computeServerAuthoritativeElapsed(startMs, 700000, 10), 575000, "Extreme lag properly inflates tiebreaker time");

  // null start time falls back to 0
  assert.equal(computeServerAuthoritativeElapsed(null, 130000, 3), 0, "Null start time is handled safely");
});

test("Technical Cancel distinguishes proven System Failures", () => {
  const serverVersion = 7;
  
  // Healthy match
  assert.equal(isSystemFailure(7, serverVersion), false, "Healthy match is not a system failure");
  
  // Registry mismatch (e.g. client is on an old match, server updated)
  assert.equal(isSystemFailure(6, serverVersion), true, "Registry mismatch proves System Failure");
  
  // No registry version
  assert.equal(isSystemFailure(null, serverVersion), false, "Missing version is treated as healthy/forfeit");
});

test("compareMatch handles forfeits and ties correctly without throwing", () => {
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
