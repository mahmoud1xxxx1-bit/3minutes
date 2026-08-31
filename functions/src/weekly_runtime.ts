import { FieldValue, Timestamp, getFirestore } from "firebase-admin/firestore";
import { onDocumentCreated } from "firebase-functions/v2/firestore";

import { COLLECTIONS, stringValue } from "./firestore.js";
import {
  WEEK_MS,
  weeklyCompetitionId,
  weeklyScoreWindowOpen,
} from "./weekly_competition.js";
import {
  economicGoldWeeklyScoreEvent,
  rankedWeeklyScoreEvent,
} from "./weekly_score.js";

const REGION = "me-central2";

function weekBounds(weekId: string): { startsAt: Timestamp; endsAt: Timestamp } {
  const index = Number(weekId.replace("week_", ""));
  const safeIndex = Number.isFinite(index) ? Math.trunc(index) : 0;
  const start = safeIndex * WEEK_MS;
  return {
    startsAt: Timestamp.fromMillis(start),
    endsAt: Timestamp.fromMillis(start + WEEK_MS),
  };
}

function weekDocument(weekId: string): Record<string, unknown> {
  const bounds = weekBounds(weekId);
  return {
    weekId,
    startsAt: bounds.startsAt,
    endsAt: bounds.endsAt,
    state: "open",
    updatedAt: FieldValue.serverTimestamp(),
  };
}

/**
 * RP weekly ranking is driven only by authoritative ranked settlements.
 * Gold is deliberately NOT written here; Gold has its own immutable-ledger
 * trigger below so every economic source is counted exactly once.
 */
export const onRankedSettlementWeeklyCompetition = onDocumentCreated(
  {
    document: `${COLLECTIONS.rankedSettlements}/{matchId}`,
    region: REGION,
  },
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;
    const matchId = event.params.matchId;
    const settlement = snapshot.data();
    const settledAt = settlement.settledAt;
    if (!(settledAt instanceof Timestamp)) return;

    const payload = settlement.payload;
    const payloadRecord = payload !== null && typeof payload === "object"
      ? (payload as Record<string, unknown>)
      : {};
    const playerA = payloadRecord.playerA;
    const playerB = payloadRecord.playerB;
    const uidA = playerA !== null && typeof playerA === "object"
      ? String((playerA as Record<string, unknown>).uid ?? "")
      : "";
    const uidB = playerB !== null && typeof playerB === "object"
      ? String((playerB as Record<string, unknown>).uid ?? "")
      : "";
    if (!uidA || !uidB || uidA === uidB) return;

    const db = getFirestore();
    const [profileASnap, profileBSnap] = await Promise.all([
      db.collection(COLLECTIONS.users).doc(uidA).get(),
      db.collection(COLLECTIONS.users).doc(uidB).get(),
    ]);
    const scoreEvent = rankedWeeklyScoreEvent({
      payload,
      profileA: profileASnap.data(),
      profileB: profileBSnap.data(),
    });
    if (!scoreEvent) return;

    const weekId = weeklyCompetitionId(settledAt.toMillis());
    const weekRef = db.collection(COLLECTIONS.weeklyLeaderboards).doc(weekId);
    const markerRef = weekRef.collection("settlements").doc(matchId);
    const rpARef = weekRef.collection("rpEntries").doc(scoreEvent.playerA.uid);
    const rpBRef = weekRef.collection("rpEntries").doc(scoreEvent.playerB.uid);

    await db.runTransaction(async (transaction) => {
      const [marker, week] = await Promise.all([
        transaction.get(markerRef),
        transaction.get(weekRef),
      ]);
      if (marker.exists) return;
      if (week.exists && !weeklyScoreWindowOpen(week.data()?.state)) return;

      if (!week.exists) {
        transaction.create(weekRef, weekDocument(weekId));
      } else {
        transaction.set(
          weekRef,
          { updatedAt: FieldValue.serverTimestamp() },
          { merge: true },
        );
      }

      const identity = (player: typeof scoreEvent.playerA) => ({
        uid: player.uid,
        gameName: player.gameName,
        avatarId: player.avatarId,
        active: true,
        matches: FieldValue.increment(1),
        updatedAt: FieldValue.serverTimestamp(),
      });

      transaction.set(
        rpARef,
        {
          ...identity(scoreEvent.playerA),
          score: FieldValue.increment(scoreEvent.playerA.rpDelta),
        },
        { merge: true },
      );
      transaction.set(
        rpBRef,
        {
          ...identity(scoreEvent.playerB),
          score: FieldValue.increment(scoreEvent.playerB.rpDelta),
        },
        { merge: true },
      );

      transaction.create(markerRef, {
        matchId,
        weekId,
        playerAId: scoreEvent.playerA.uid,
        playerBId: scoreEvent.playerB.uid,
        rpDeltaA: scoreEvent.playerA.rpDelta,
        rpDeltaB: scoreEvent.playerB.rpDelta,
        createdAt: FieldValue.serverTimestamp(),
      });
    });
  },
);

/**
 * Gold weekly ranking follows every server-created Gold ledger mutation.
 * A per-transaction marker makes Firestore's at-least-once event delivery
 * idempotent, while excluded weekly prizes cannot seed the following week.
 */
export const onGoldTransactionWeeklyCompetition = onDocumentCreated(
  {
    document: `${COLLECTIONS.goldTransactions}/{transactionId}`,
    region: REGION,
  },
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;
    const scoreEvent = economicGoldWeeklyScoreEvent(snapshot.data());
    if (!scoreEvent) return;

    const data = snapshot.data();
    const createdAt = data.createdAt;
    if (!(createdAt instanceof Timestamp)) return;

    const db = getFirestore();
    const profile = (await db.collection(COLLECTIONS.users).doc(scoreEvent.uid).get()).data() ?? {};
    const weekId = weeklyCompetitionId(createdAt.toMillis());
    const weekRef = db.collection(COLLECTIONS.weeklyLeaderboards).doc(weekId);
    const markerRef = weekRef.collection("goldEvents").doc(event.params.transactionId);
    const entryRef = weekRef.collection("goldEntries").doc(scoreEvent.uid);

    await db.runTransaction(async (transaction) => {
      const [marker, week] = await Promise.all([
        transaction.get(markerRef),
        transaction.get(weekRef),
      ]);
      if (marker.exists) return;
      if (week.exists && !weeklyScoreWindowOpen(week.data()?.state)) return;

      if (!week.exists) {
        transaction.create(weekRef, weekDocument(weekId));
      } else {
        transaction.set(
          weekRef,
          { updatedAt: FieldValue.serverTimestamp() },
          { merge: true },
        );
      }
      transaction.set(
        entryRef,
        {
          uid: scoreEvent.uid,
          gameName: stringValue(profile.gameName, "Player"),
          avatarId: stringValue(profile.avatarId, "default_01"),
          active: true,
          score: FieldValue.increment(scoreEvent.goldDelta),
          economicEvents: FieldValue.increment(1),
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
      transaction.create(markerRef, {
        transactionId: event.params.transactionId,
        uid: scoreEvent.uid,
        weekId,
        goldDelta: scoreEvent.goldDelta,
        createdAt: FieldValue.serverTimestamp(),
      });
    });
  },
);
