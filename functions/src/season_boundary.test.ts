import assert from "node:assert/strict";
import test from "node:test";

import {
  SEASON_NEW_MATCH_GUARD_MS,
  SEASON_SETTLEMENT_GRACE_MS,
  seasonAcceptsNewRankedMatch,
  seasonReadyForRollover,
} from "./season_boundary.js";

test("ranked admission closes early enough for a full legal match", () => {
  const startsAtMs = 1_000_000;
  const endsAtMs = startsAtMs + 30 * 24 * 60 * 60 * 1000;
  const lastLegalStartMs = endsAtMs - SEASON_NEW_MATCH_GUARD_MS;

  assert.equal(
    seasonAcceptsNewRankedMatch({
      active: true,
      startsAtMs,
      endsAtMs,
      nowMs: lastLegalStartMs,
    }),
    true,
  );
  assert.equal(
    seasonAcceptsNewRankedMatch({
      active: true,
      startsAtMs,
      endsAtMs,
      nowMs: lastLegalStartMs + 1,
    }),
    false,
  );
});

test("inactive, not-yet-started, and malformed seasons never admit ranked", () => {
  assert.equal(
    seasonAcceptsNewRankedMatch({
      active: false,
      startsAtMs: 1000,
      endsAtMs: 1_000_000,
      nowMs: 2000,
    }),
    false,
  );
  assert.equal(
    seasonAcceptsNewRankedMatch({
      active: true,
      startsAtMs: 5000,
      endsAtMs: 1_000_000,
      nowMs: 4999,
    }),
    false,
  );
  assert.equal(
    seasonAcceptsNewRankedMatch({
      active: true,
      startsAtMs: null,
      endsAtMs: 1_000_000,
      nowMs: 5000,
    }),
    false,
  );
});

test("rollover cannot lock settlements at endsAt and waits the full grace", () => {
  const endsAtMs = 10_000_000;
  assert.equal(
    seasonReadyForRollover({
      active: true,
      endsAtMs,
      nowMs: endsAtMs,
    }),
    false,
  );
  assert.equal(
    seasonReadyForRollover({
      active: true,
      endsAtMs,
      nowMs: endsAtMs + SEASON_SETTLEMENT_GRACE_MS - 1,
    }),
    false,
  );
  assert.equal(
    seasonReadyForRollover({
      active: true,
      endsAtMs,
      nowMs: endsAtMs + SEASON_SETTLEMENT_GRACE_MS,
    }),
    true,
  );
});
