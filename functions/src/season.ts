import { FieldValue, Timestamp, getFirestore } from "firebase-admin/firestore";
import { onSchedule } from "firebase-functions/v2/scheduler";

import { COLLECTIONS, intValue, stringValue } from "./firestore.js";
import {
  startingRpForPeakTier,
  starsForPeakTier,
  tierFor,
  type RankTier,
} from "./policy.js";
import { seasonReadyForRollover } from "./season_boundary.js";

const THIRTY_DAYS_MS = 30 * 24 * 60 * 60 * 1000;
const ROLLOVER_GRANTS = "seasonRolloverGrants";

function safeTier(value: unknown, rankPoints: number): RankTier {
  if (
    value === "bronze" ||
    value === "silver" ||
    value === "gold" ||
    value === "platinum" ||
    value === "diamond" ||
    value === "master" ||
    value === "grandmaster" ||
    value === "legend"
  ) {
    return value;
  }
  return tierFor(rankPoints);
}

async function applyPlayerRollover(options: {
  seasonId: string;
  seasonNumber: number;
  uid: string;
  peakTier: RankTier;
  finalRankPoints: number;
  finalStanding: number;
}): Promise<void> {
  const db = getFirestore();
  const {
    seasonId,
    seasonNumber,
    uid,
    peakTier,
    finalRankPoints,
    finalStanding,
  } = options;
  const userRef = db.collection(COLLECTIONS.users).doc(uid);
  const boardRef = db
    .collection(COLLECTIONS.leaderboards)
    .doc(seasonId)
    .collection(COLLECTIONS.entries)
    .doc(uid);
  const historyRef = db
    .collection(COLLECTIONS.seasonHistory)
    .doc(uid)
    .collection("seasons")
    .doc(seasonId);
  const achievementsRef = db.collection(COLLECTIONS.playerAchievements).doc(uid);
  const grantRef = db
    .collection(ROLLOVER_GRANTS)
    .doc(seasonId)
    .collection(COLLECTIONS.players)
    .doc(uid);

  await db.runTransaction(async (transaction) => {
    const [grant, userSnap, boardSnap, historySnap, achievementsSnap] = await Promise.all([
      transaction.get(grantRef),
      transaction.get(userRef),
      transaction.get(boardRef),
      transaction.get(historyRef),
      transaction.get(achievementsRef),
    ]);
    if (grant.exists) return;

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

    const board = boardSnap.data() ?? {};
    const previousStars = Math.max(0, intValue(user.stars));
    const starsAwarded = starsForPeakTier(peakTier);
    const nextStars = previousStars + starsAwarded;
    const previousRp = Math.max(0, intValue(user.rankPoints));
    const nextRp = startingRpForPeakTier(peakTier);
    const previousSeasons = Math.max(0, intValue(user.seasonsCompleted));
    const seasonsCompleted = previousSeasons + 1;
    const previousLegendarySeasons = Math.max(0, intValue(user.legendarySeasons));
    const legendaryAwarded = peakTier === "legend" ? 1 : 0;
    const legendarySeasons = previousLegendarySeasons + legendaryAwarded;
    const finalTier = tierFor(finalRankPoints);

    transaction.update(userRef, {
      stars: nextStars,
      rankPoints: nextRp,
      seasonsCompleted,
      legendarySeasons,
      updatedAt: FieldValue.serverTimestamp(),
    });

    if (boardSnap.exists) {
      transaction.update(boardRef, {
        rolloverApplied: true,
        starsAwarded,
        finalStars: nextStars,
        resetRp: nextRp,
        finalStanding,
        legendaryAwarded,
        legendarySeasons,
        updatedAt: FieldValue.serverTimestamp(),
      });
    }

    if (!historySnap.exists) {
      transaction.create(historyRef, {
        seasonId,
        seasonNumber,
        finalStanding,
        finalRankPoints,
        finalTier,
        peakTier,
        wins: Math.max(0, intValue(board.wins)),
        losses: Math.max(0, intValue(board.losses)),
        ties: Math.max(0, intValue(board.ties)),
        matches: Math.max(
          0,
          intValue(board.wins) + intValue(board.losses) + intValue(board.ties),
        ),
        starsBefore: previousStars,
        starsAwarded,
        starsAfter: nextStars,
        legendaryAwarded,
        legendarySeasonsAfter: legendarySeasons,
        resetRp: nextRp,
        closedAt: FieldValue.serverTimestamp(),
      });
    }

    const achievementStates = {
      ...((achievementsSnap.data()?.states as Record<string, unknown> | undefined) ?? {}),
    };
    const previousSeasonsState =
      achievementStates.seasons_10 && typeof achievementStates.seasons_10 === "object"
        ? (achievementStates.seasons_10 as Record<string, unknown>)
        : {};
    achievementStates.seasons_10 = {
      ...previousSeasonsState,
      progress: Math.min(10, seasonsCompleted),
      completed: seasonsCompleted >= 10,
      completedAt:
        previousSeasonsState.completedAt instanceof Timestamp
          ? previousSeasonsState.completedAt
          : seasonsCompleted >= 10
            ? FieldValue.serverTimestamp()
            : null,
      rewardClaimedAt: previousSeasonsState.rewardClaimedAt ?? null,
    };
    const prestigeState =
      achievementStates.prestige_100 && typeof achievementStates.prestige_100 === "object"
        ? (achievementStates.prestige_100 as Record<string, unknown>)
        : {};
    achievementStates.prestige_100 = {
      ...prestigeState,
      progress: Math.min(100, nextStars),
      completed: nextStars >= 100,
      completedAt:
        prestigeState.completedAt instanceof Timestamp
          ? prestigeState.completedAt
          : nextStars >= 100
            ? FieldValue.serverTimestamp()
            : null,
      rewardClaimedAt: prestigeState.rewardClaimedAt ?? null,
    };
    transaction.set(
      achievementsRef,
      { states: achievementStates, updatedAt: FieldValue.serverTimestamp() },
      { merge: true },
    );

    transaction.create(grantRef, {
      uid,
      seasonId,
      seasonNumber,
      gameName: stringValue(user.gameName, "Player"),
      peakTier,
      finalTier,
      finalStanding,
      previousStars,
      starsAwarded,
      nextStars,
      previousRp,
      finalRankPoints,
      nextRp,
      seasonsCompleted,
      previousLegendarySeasons,
      legendaryAwarded,
      legendarySeasons,
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

    let seasonSnap;
    const active = await db
      .collection(COLLECTIONS.seasons)
      .where("active", "==", true)
      .limit(1)
      .get();

    if (!active.empty) {
      seasonSnap = active.docs[0]!;
      const season = seasonSnap.data();
      const endsAt = season.endsAt;
      const endsAtMs = endsAt instanceof Timestamp ? endsAt.toMillis() : null;
      if (!seasonReadyForRollover({ active: true, endsAtMs, nowMs: Date.now() })) return;

      const acquired = await db.runTransaction(async (transaction) => {
        const currentSnap = await transaction.get(seasonSnap!.ref);
        const current = currentSnap.data();
        if (!current) return false;
        if (current.rolloverState === "processing") return true;
        const currentEnd = current.endsAt;
        const currentEndMs = currentEnd instanceof Timestamp ? currentEnd.toMillis() : null;
        if (!seasonReadyForRollover({
          active: current.active === true,
          endsAtMs: currentEndMs,
          nowMs: Date.now(),
        })) {
          return false;
        }
        transaction.update(seasonSnap!.ref, {
          active: false,
          rolloverState: "processing",
          settlementsClosedAt: FieldValue.serverTimestamp(),
          rolloverStartedAt: FieldValue.serverTimestamp(),
          updatedAt: FieldValue.serverTimestamp(),
        });
        return true;
      });
      if (!acquired) return;
    } else {
      const processing = await db
        .collection(COLLECTIONS.seasons)
        .where("rolloverState", "==", "processing")
        .limit(1)
        .get();
      if (processing.empty) return;
      seasonSnap = processing.docs[0]!;
    }

    const season = seasonSnap.data();
    const endsAt = season.endsAt;
    if (!(endsAt instanceof Timestamp)) return;
    const seasonId = seasonSnap.id;
    const seasonNumber = Math.max(1, intValue(season.number, 1));

    const entries = await db
      .collection(COLLECTIONS.leaderboards)
      .doc(seasonId)
      .collection(COLLECTIONS.entries)
      .get();

    const ordered = [...entries.docs].sort((a, b) => {
      const aData = a.data();
      const bData = b.data();
      const rp = intValue(bData.rankPoints) - intValue(aData.rankPoints);
      if (rp !== 0) return rp;
      const wins = intValue(bData.wins) - intValue(aData.wins);
      if (wins !== 0) return wins;
      const losses = intValue(aData.losses) - intValue(bData.losses);
      if (losses !== 0) return losses;
      return a.id.localeCompare(b.id);
    });

    for (let i = 0; i < ordered.length; i += 1) {
      const entry = ordered[i]!;
      const data = entry.data();
      const rp = Math.max(0, intValue(data.rankPoints));
      const peakTier = safeTier(data.peakTier, rp);
      await applyPlayerRollover({
        seasonId,
        seasonNumber,
        uid: entry.id,
        peakTier,
        finalRankPoints: rp,
        finalStanding: i + 1,
      });
    }

    const nextId = `season_${seasonNumber + 1}`;
    const nextRef = db.collection(COLLECTIONS.seasons).doc(nextId);

    await db.runTransaction(async (transaction) => {
      const [currentSnap, nextSnap] = await Promise.all([
        transaction.get(seasonSnap.ref),
        transaction.get(nextRef),
      ]);
      const current = currentSnap.data();
      if (!current || current.rolloverState !== "processing") return;

      const currentEnd = current.endsAt;
      if (!(currentEnd instanceof Timestamp)) return;

      const startMs = currentEnd.toMillis();
      const nextData = {
        number: seasonNumber + 1,
        startsAt: Timestamp.fromMillis(startMs),
        endsAt: Timestamp.fromMillis(startMs + THIRTY_DAYS_MS),
        active: true,
        rolloverState: "open",
        createdAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      };

      transaction.update(seasonSnap.ref, {
        active: false,
        rolloverState: "closed",
        finalEntryCount: ordered.length,
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
