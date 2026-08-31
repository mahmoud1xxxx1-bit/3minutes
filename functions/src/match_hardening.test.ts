import assert from "node:assert/strict";
import test from "node:test";
import { compareMatch, MatchProgress } from "./policy.js";
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
  
  assert.equal(computeServerAuthoritativeElapsed(startMs, 110000, 1), 7500, "Normal latency properly calculates tiebreak");
  assert.equal(computeServerAuthoritativeElapsed(startMs, 130000, 3), 22500, "Reconnect batch handles accumulated time safely");
  assert.equal(computeServerAuthoritativeElapsed(startMs, 700000, 10), 575000, "Extreme lag properly inflates tiebreaker time");
  assert.equal(computeServerAuthoritativeElapsed(null, 130000, 3), 0, "Null start time is handled safely");
});

test("Technical Cancel distinguishes proven System Failures", () => {
  const serverVersion = 7;
  
  assert.equal(isSystemFailure(7, serverVersion), false, "Healthy match is not a system failure");
  assert.equal(isSystemFailure(6, serverVersion), true, "Registry mismatch proves System Failure");
  assert.equal(isSystemFailure(null, serverVersion), false, "Missing version is treated as healthy/forfeit");
});

test("compareMatch comprehensive scenarios for final verification", () => {
  const baseP: MatchProgress = {
    completedGames: 0,
    totalScore: 0,
    accuracyTotal: 0,
    mistakes: 0,
    elapsedMs: 0,
    completedAtMs: null,
  };

  const gameCount = 10;

  // 1. Partial Progress / Timeout (Neither finishes, score matters)
  const partialA = { ...baseP, completedGames: 5, totalScore: 5000, completedAtMs: 500 }; // Fake completedAt from bug
  const partialB = { ...baseP, completedGames: 5, totalScore: 4000, completedAtMs: null }; // Correct null completedAt
  assert.equal(compareMatch(partialA, partialB, gameCount), "playerA", "Partial progress ignores completedAt and relies on score");

  // 2. Timeout before completion (completedGames is the first tiebreaker if unfinished)
  const timeoutA = { ...baseP, completedGames: 6, totalScore: 5000 };
  const timeoutB = { ...baseP, completedGames: 5, totalScore: 9000 };
  assert.equal(compareMatch(timeoutA, timeoutB, gameCount), "playerA", "More completed games wins if both timeout");

  // 3. Both completed, different completion times (The race)
  const completeA_Fast = { ...baseP, completedGames: 10, totalScore: 10000, completedAtMs: 100000 };
  const completeB_Slow = { ...baseP, completedGames: 10, totalScore: 15000, completedAtMs: 120000 };
  assert.equal(compareMatch(completeA_Fast, completeB_Slow, gameCount), "playerA", "First to finish wins regardless of score (Race to finish)");

  // 4. Forfeit during progress
  assert.equal(compareMatch({ ...partialA, forfeited: true }, partialB, gameCount), "playerB", "Forfeit loses instantly even if score was higher");
  assert.equal(compareMatch({ ...partialA, forfeited: true }, { ...partialB, forfeited: true }, gameCount), "tie", "Double forfeit ties");

  // 5. One player completes, the other times out
  assert.equal(compareMatch(completeA_Fast, partialB, gameCount), "playerA", "Completed player always beats partial player");

  // 6. Exactly simultaneous completion (tiebreak goes to Score)
  const completeA_Sim = { ...baseP, completedGames: 10, totalScore: 12000, completedAtMs: 150000 };
  const completeB_Sim = { ...baseP, completedGames: 10, totalScore: 14000, completedAtMs: 150000 };
  assert.equal(compareMatch(completeA_Sim, completeB_Sim, gameCount), "playerB", "Simultaneous completion falls back to Score");

  // 7. Reconnect Batch / Duplicate Result Regression Check
  // Reconnect doesn't change the outcome rule: if A finishes at 100000 and B drops and batch-submits at 120000, A wins.
  assert.equal(compareMatch(completeA_Fast, completeB_Slow, gameCount), "playerA", "Late batch submission correctly loses to earlier completion");
});
