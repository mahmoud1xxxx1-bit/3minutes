import { FieldValue, Timestamp, getFirestore } from "firebase-admin/firestore";
import { onDocumentCreated } from "firebase-functions/v2/firestore";

import { COLLECTIONS } from "./firestore.js";
import { WEEK_MS, weeklyCompetitionId } from "./weekly_competition.js";
import { rankedWeeklyScoreEvent } from "./weekly_score.js";

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
    const goldARef = weekRef.collection("goldEntries").doc(scoreEvent.playerA.uid);
    const goldBRef = weekRef.collection("goldEntries").doc(scoreEvent.playerB.uid);
    const bounds = weekBounds(weekId);

    await db.runTransaction(async (transaction) => {
      const marker = await transaction.get(markerRef);
      if (marker.exists) return;

      transaction.set(
        weekRef,
        {
          weekId,
          startsAt: bounds.startsAt,
          endsAt: bounds.endsAt,
          state: "open",
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );

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
      transaction.set(
        goldARef,
        {
          ...identity(scoreEvent.playerA),
          score: FieldValue.increment(scoreEvent.playerA.goldNetDelta),
        },
        { merge: true },
      );
      transaction.set(
        goldBRef,
        {
          ...identity(scoreEvent.playerB),
          score: FieldValue.increment(scoreEvent.playerB.goldNetDelta),
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
        goldDeltaA: scoreEvent.playerA.goldNetDelta,
        goldDeltaB: scoreEvent.playerB.goldNetDelta,
        createdAt: FieldValue.serverTimestamp(),
      });
    });
  },
);
