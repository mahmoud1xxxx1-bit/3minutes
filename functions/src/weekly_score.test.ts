import assert from "node:assert/strict";
import { test } from "node:test";

import { rankedWeeklyScoreEvent } from "./weekly_score.js";

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
