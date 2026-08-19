import { getFunctions } from "firebase-admin/functions";
import {
  FieldPath,
  FieldValue,
  Timestamp,
  getFirestore,
  type DocumentData,
  type Query,
  type QueryDocumentSnapshot,
} from "firebase-admin/firestore";
import { onSchedule } from "firebase-functions/v2/scheduler";
import { onTaskDispatched } from "firebase-functions/v2/tasks";

import { COLLECTIONS, intValue, stringValue } from "./firestore.js";
import {
  startingRpForPeakTier,
  starsForPeakTier,
  tierFor,
  type RankTier,
} from "./policy.js";
import { seasonReadyForRollover } from "./season_boundary.js";

const REGION = "me-central2";
const THIRTY_DAYS_MS = 30 * 24 * 60 * 60 * 1000;
const ROLLOVER_GRANTS = "seasonRolloverGrants";
const ROLLOVER_PAGES = "seasonRolloverPages";
const ROLLOVER_PAGE_SIZE = 200;
const PLAYER_CONCURRENCY = 20;

type RolloverCursor = {
  rankPoints: number;
  wins: number;
  losses: number;
  uid: string;
};

type RolloverPageTask = {
  seasonId: string;
  seasonNumber: number;
  offset: number;
  cursor?: RolloverCursor;
};

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

function pageTaskId(seasonId: string, offset: number): string {
  const safeSeason = seasonId.replace(/[^A-Za-z0-9_-]/g, "_");
  return `season_${safeSeason}_page_${offset}`;
}

function isTaskAlreadyExists(error: unknown): boolean {
  if (!error || typeof error !== "object") return false;
  const code = (error as { code?: unknown }).code;
  return code === "functions/task-already-exists" || code === "task-already-exists";
}

async function enqueueRolloverPage(task: RolloverPageTask): Promise<void> {
  const queue = getFunctions().taskQueue<RolloverPageTask>(
    `locations/${REGION}/functions/processSeasonRolloverPage`,
  );
  try {
    await queue.enqueue(task, {
      id: pageTaskId(task.seasonId, task.offset),
      dispatchDeadlineSeconds: 540,
    });
  } catch (error) {
    if (!isTaskAlreadyExists(error)) throw error;
  }
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

async function runWithConcurrency<T>(
  items: readonly T[],
  concurrency: number,
  worker: (item: T, index: number) => Promise<void>,
): Promise<void> {
  for (let start = 0; start < items.length; start += concurrency) {
    const chunk = items.slice(start, start + concurrency);
    await Promise.all(chunk.map((item, index) => worker(item, start + index)));
  }
}

function leaderboardPageQuery(
  seasonId: string,
  cursor?: RolloverCursor,
): Query<DocumentData> {
  const entries = getFirestore()
    .collection(COLLECTIONS.leaderboards)
    .doc(seasonId)
    .collection(COLLECTIONS.entries);

  let query: Query<DocumentData> = entries
    .orderBy("rankPoints", "desc")
    .orderBy("wins", "desc")
    .orderBy("losses", "asc")
    .orderBy(FieldPath.documentId(), "asc")
    .limit(ROLLOVER_PAGE_SIZE);

  if (cursor) {
    query = query.startAfter(
      cursor.rankPoints,
      cursor.wins,
      cursor.losses,
      cursor.uid,
    );
  }
  return query;
}

async function finalizeSeasonIfComplete(seasonId: string): Promise<void> {
  const db = getFirestore();
  const seasonRef = db.collection(COLLECTIONS.seasons).doc(seasonId);

  await db.runTransaction(async (transaction) => {
    const currentSnap = await transaction.get(seasonRef);
    const current = currentSnap.data();
    if (!current || current.rolloverState !== "processing") return;

    const expected = intValue(current.rolloverExpectedEntries, -1);
    const completed = Math.max(0, intValue(current.rolloverCompletedEntries));
    if (expected < 0 || completed < expected) return;

    const currentEnd = current.endsAt;
    if (!(currentEnd instanceof Timestamp)) return;
    const seasonNumber = Math.max(1, intValue(current.number, 1));
    const nextId = `season_${seasonNumber + 1}`;
    const nextRef = db.collection(COLLECTIONS.seasons).doc(nextId);
    const nextSnap = await transaction.get(nextRef);
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

    transaction.update(seasonRef, {
      active: false,
      rolloverState: "closed",
      finalEntryCount: expected,
      rolledOverAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });
    if (!nextSnap.exists) {
      transaction.create(nextRef, nextData);
    } else {
      transaction.set(nextRef, nextData, { merge: true });
    }
  });
}

async function markPageComplete(options: {
  seasonId: string;
  offset: number;
  processed: number;
  isLastPage: boolean;
}): Promise<void> {
  const db = getFirestore();
  const { seasonId, offset, processed, isLastPage } = options;
  const seasonRef = db.collection(COLLECTIONS.seasons).doc(seasonId);
  const pageRef = db
    .collection(ROLLOVER_PAGES)
    .doc(seasonId)
    .collection("pages")
    .doc(String(offset));

  await db.runTransaction(async (transaction) => {
    const [seasonSnap, pageSnap] = await Promise.all([
      transaction.get(seasonRef),
      transaction.get(pageRef),
    ]);
    const season = seasonSnap.data();
    if (!season || season.rolloverState !== "processing") return;
    if (pageSnap.exists) return;

    const completed = Math.max(0, intValue(season.rolloverCompletedEntries));
    const nextCompleted = completed + processed;
    const update: Record<string, unknown> = {
      rolloverCompletedEntries: nextCompleted,
      rolloverLastCompletedOffset: offset,
      updatedAt: FieldValue.serverTimestamp(),
    };
    if (isLastPage) {
      update.rolloverExpectedEntries = offset + processed;
      update.rolloverLastPageDiscoveredAt = FieldValue.serverTimestamp();
    }

    transaction.create(pageRef, {
      seasonId,
      offset,
      processed,
      completedAt: FieldValue.serverTimestamp(),
    });
    transaction.update(seasonRef, update);
  });

  await finalizeSeasonIfComplete(seasonId);
}

export const processSeasonRolloverPage = onTaskDispatched<RolloverPageTask>(
  {
    region: REGION,
    timeoutSeconds: 540,
    memory: "512MiB",
    retryConfig: {
      maxAttempts: 8,
      minBackoffSeconds: 15,
      maxBackoffSeconds: 300,
      maxDoublings: 5,
    },
    rateLimits: {
      maxConcurrentDispatches: 20,
      maxDispatchesPerSecond: 20,
    },
  },
  async (request) => {
    const task = request.data;
    const seasonId = stringValue(task?.seasonId);
    const seasonNumber = Math.max(1, intValue(task?.seasonNumber, 1));
    const offset = Math.max(0, intValue(task?.offset));
    if (!seasonId) throw new Error("seasonId is required for rollover task");

    const db = getFirestore();
    const seasonRef = db.collection(COLLECTIONS.seasons).doc(seasonId);
    const season = (await seasonRef.get()).data();
    if (!season || season.rolloverState !== "processing") return;

    const cursor = task?.cursor && typeof task.cursor === "object"
      ? {
          rankPoints: intValue(task.cursor.rankPoints),
          wins: intValue(task.cursor.wins),
          losses: intValue(task.cursor.losses),
          uid: stringValue(task.cursor.uid),
        }
      : undefined;

    const page = await leaderboardPageQuery(seasonId, cursor).get();
    const docs = page.docs;
    const isLastPage = docs.length < ROLLOVER_PAGE_SIZE;

    if (!isLastPage && docs.length > 0) {
      const last = docs[docs.length - 1]!;
      const data = last.data();
      await enqueueRolloverPage({
        seasonId,
        seasonNumber,
        offset: offset + docs.length,
        cursor: {
          rankPoints: intValue(data.rankPoints),
          wins: intValue(data.wins),
          losses: intValue(data.losses),
          uid: last.id,
        },
      });
    }

    await runWithConcurrency(docs, PLAYER_CONCURRENCY, async (entry, index) => {
      const data = entry.data();
      const rp = Math.max(0, intValue(data.rankPoints));
      await applyPlayerRollover({
        seasonId,
        seasonNumber,
        uid: entry.id,
        peakTier: safeTier(data.peakTier, rp),
        finalRankPoints: rp,
        finalStanding: offset + index + 1,
      });
    });

    await markPageComplete({
      seasonId,
      offset,
      processed: docs.length,
      isLastPage,
    });
  },
);

async function acquireRolloverSeason(): Promise<QueryDocumentSnapshot<DocumentData> | null> {
  const db = getFirestore();
  const active = await db
    .collection(COLLECTIONS.seasons)
    .where("active", "==", true)
    .limit(1)
    .get();

  if (!active.empty) {
    const seasonSnap = active.docs[0]!;
    const season = seasonSnap.data();
    const endsAtMs = season.endsAt instanceof Timestamp ? season.endsAt.toMillis() : null;
    if (!seasonReadyForRollover({ active: true, endsAtMs, nowMs: Date.now() })) return null;

    const acquired = await db.runTransaction(async (transaction) => {
      const currentSnap = await transaction.get(seasonSnap.ref);
      const current = currentSnap.data();
      if (!current) return false;
      if (current.rolloverState === "processing") return true;
      const currentEndMs = current.endsAt instanceof Timestamp ? current.endsAt.toMillis() : null;
      if (!seasonReadyForRollover({
        active: current.active === true,
        endsAtMs: currentEndMs,
        nowMs: Date.now(),
      })) {
        return false;
      }
      transaction.update(seasonSnap.ref, {
        active: false,
        rolloverState: "processing",
        rolloverCompletedEntries: 0,
        rolloverExpectedEntries: null,
        rolloverTaskQueued: false,
        settlementsClosedAt: FieldValue.serverTimestamp(),
        rolloverStartedAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      });
      return true;
    });
    return acquired ? seasonSnap : null;
  }

  const processing = await db
    .collection(COLLECTIONS.seasons)
    .where("rolloverState", "==", "processing")
    .limit(1)
    .get();
  return processing.empty ? null : processing.docs[0]!;
}

export const rolloverRankedSeason = onSchedule(
  {
    region: REGION,
    schedule: "every 5 minutes",
    timeoutSeconds: 120,
    memory: "256MiB",
  },
  async () => {
    const seasonSnap = await acquireRolloverSeason();
    if (!seasonSnap) return;

    const season = (await seasonSnap.ref.get()).data();
    if (!season || season.rolloverState !== "processing") return;
    if (season.rolloverTaskQueued === true) {
      await finalizeSeasonIfComplete(seasonSnap.id);
      return;
    }

    const seasonNumber = Math.max(1, intValue(season.number, 1));
    await enqueueRolloverPage({
      seasonId: seasonSnap.id,
      seasonNumber,
      offset: 0,
    });
    await seasonSnap.ref.update({
      rolloverTaskQueued: true,
      rolloverTaskQueuedAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });
  },
);
