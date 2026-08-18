import { FieldValue, Timestamp, getFirestore } from "firebase-admin/firestore";
import { onSchedule } from "firebase-functions/v2/scheduler";

import { COLLECTIONS, intValue } from "./firestore.js";
import {
  startingRpForPeakTier,
  starsForPeakTier,
  tierFor,
  type RankTier,
} from "./policy.js";

const THIRTY_DAYS_MS = 30 * 24 * 60 * 60 * 1000;
const ROLLOVER_GRANTS = "seasonRolloverGrants";

function safeTier(value: unknown, rankPoints: number): RankTier {
  if (
    value === "bronze" ||
    value === "silver" ||
    value === "gold" ||
    value === "platinum" ||
    value === "diamond" ||
    value === "master"
  ) {
    return value;
  }
  return tierFor(rankPoints);
}

async function applyPlayerRollover(options: {
  seasonId: string;
  uid: string;
  peakTier: RankTier;
}): Promise<void> {
  const db = getFirestore();
  const { seasonId, uid, peakTier } = options;
  const userRef = db.collection(COLLECTIONS.users).doc(uid);
  const boardRef = db
    .collection(COLLECTIONS.leaderboards)
    .doc(seasonId)
    .collection(COLLECTIONS.entries)
    .doc(uid);
  const grantRef = db
    .collection(ROLLOVER_GRANTS)
    .doc(seasonId)
    .collection(COLLECTIONS.players)
    .doc(uid);

  await db.runTransaction(async (transaction) => {
    const grant = await transaction.get(grantRef);
    if (grant.exists) return;

    const [userSnap, boardSnap] = await Promise.all([
      transaction.get(userRef),
      transaction.get(boardRef),
    ]);
    const user = userSnap.data();
    if (!user) {
      transaction.create(grantRef, {
        uid,
        seasonId,
        skipped: true,
        reason: "missingUser",
        createdAt: FieldValue.serverTimestamp(),
      });
      return;
    }

    const previousStars = Math.max(0, intValue(user.stars));
    const starsAwarded = starsForPeakTier(peakTier);
    const nextStars = previousStars + starsAwarded;
    const previousRp = Math.max(0, intValue(user.rankPoints));
    const nextRp = startingRpForPeakTier(peakTier);

    transaction.update(userRef, {
      stars: nextStars,
      rankPoints: nextRp,
      updatedAt: FieldValue.serverTimestamp(),
    });
    if (boardSnap.exists) {
      transaction.update(boardRef, {
        rolloverApplied: true,
        starsAwarded,
        finalStars: nextStars,
        resetRp: nextRp,
        updatedAt: FieldValue.serverTimestamp(),
      });
    }
    transaction.create(grantRef, {
      uid,
      seasonId,
      peakTier,
      previousStars,
      starsAwarded,
      nextStars,
      previousRp,
      nextRp,
      createdAt: FieldValue.serverTimestamp(),
    });
  });
}

export const rolloverRankedSeason = onSchedule(
  {
    region: "me-central2",
    schedule: "every 1 hours",
    timeoutSeconds: 540,
    memory: "512MiB",
  },
  async () => {
    const db = getFirestore();
    const active = await db
      .collection(COLLECTIONS.seasons)
      .where("active", "==", true)
      .limit(1)
      .get();
    if (active.empty) return;

    const seasonSnap = active.docs[0]!;
    const season = seasonSnap.data();
    const endsAt = season.endsAt;
    if (!(endsAt instanceof Timestamp)) return;
    if (Date.now() < endsAt.toMillis()) return;

    const seasonId = seasonSnap.id;
    const entries = await db
      .collection(COLLECTIONS.leaderboards)
      .doc(seasonId)
      .collection(COLLECTIONS.entries)
      .get();

    for (const entry of entries.docs) {
      const data = entry.data();
      const rp = Math.max(0, intValue(data.rankPoints));
      const peakTier = safeTier(data.peakTier, rp);
      await applyPlayerRollover({
        seasonId,
        uid: entry.id,
        peakTier,
      });
    }

    const number = Math.max(1, intValue(season.number, 1));
    const nextId = `season_${number + 1}`;
    const nextRef = db.collection(COLLECTIONS.seasons).doc(nextId);

    await db.runTransaction(async (transaction) => {
      const [currentSnap, nextSnap] = await Promise.all([
        transaction.get(seasonSnap.ref),
        transaction.get(nextRef),
      ]);
      const current = currentSnap.data();
      if (!current) return;
      if (current.active !== true) return;

      const currentEnd = current.endsAt;
      if (!(currentEnd instanceof Timestamp)) return;
      if (Date.now() < currentEnd.toMillis()) return;

      const startMs = currentEnd.toMillis();
      const nextData = {
        number: number + 1,
        startsAt: Timestamp.fromMillis(startMs),
        endsAt: Timestamp.fromMillis(startMs + THIRTY_DAYS_MS),
        active: true,
        createdAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      };

      transaction.update(seasonSnap.ref, {
        active: false,
        rolledOverAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      });
      if (!nextSnap.exists) {
        transaction.create(nextRef, nextData);
      } else {
        transaction.set(nextRef, nextData, { merge: true });
      }
    });
  },
);
