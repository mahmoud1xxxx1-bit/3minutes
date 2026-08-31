import assert from "node:assert/strict";
import { test } from "node:test";

import {
  economicGoldWeeklyScoreEvent,
  rankedWeeklyScoreEvent,
} from "./weekly_score.js";

test("ranked settlement maps authoritative RP and Gold deltas into weekly score", () => {
  const event = rankedWeeklyScoreEvent({
    payload: {
      playerA: { uid: "a", rpDelta: 30, goldNetDelta: 250 },
      playerB: { uid: "b", rpDelta: -18, goldNetDelta: -250 },
    },
    profileA: { gameName: "Alpha", avatarId: "avatar_01" },
    profileB: { gameName: "Beta", avatarId: "avatar_02" },
  });

  assert.deepEqual(event, {
    playerA: {
      uid: "a",
      gameName: "Alpha",
      avatarId: "avatar_01",
      rpDelta: 30,
      goldNetDelta: 250,
    },
    playerB: {
      uid: "b",
      gameName: "Beta",
      avatarId: "avatar_02",
      rpDelta: -18,
      goldNetDelta: -250,
    },
  });
});

test("weekly score event rejects malformed or duplicated participants", () => {
  assert.equal(
    rankedWeeklyScoreEvent({
      payload: { playerA: { uid: "a" }, playerB: { uid: "a" } },
      profileA: {},
      profileB: {},
    }),
    null,
  );
  assert.equal(
    rankedWeeklyScoreEvent({ payload: {}, profileA: {}, profileB: {} }),
    null,
  );
});

test("Gold weekly score follows the authoritative economic ledger", () => {
  assert.deepEqual(
    economicGoldWeeklyScoreEvent({ uid: "a", amount: 250 }),
    { uid: "a", goldDelta: 250 },
  );
  assert.deepEqual(
    economicGoldWeeklyScoreEvent({ uid: "a", amount: -500 }),
    { uid: "a", goldDelta: -500 },
  );
});

test("weekly prize Gold is excluded from the next Gold ranking", () => {
  assert.equal(
    economicGoldWeeklyScoreEvent({
      uid: "a",
      amount: 3000,
      excludedFromWeeklyGoldScore: true,
    }),
    null,
  );
  assert.equal(economicGoldWeeklyScoreEvent({ uid: "", amount: 100 }), null);
  assert.equal(economicGoldWeeklyScoreEvent({ uid: "a", amount: Number.NaN }), null);
  assert.equal(economicGoldWeeklyScoreEvent({ uid: "a", amount: 0 }), null);
});
