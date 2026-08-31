import { getFunctions } from "firebase-admin/functions";
import {
  FieldPath,
  FieldValue,
  Timestamp,
  getFirestore,
  type DocumentData,
  type Query,
} from "firebase-admin/firestore";
import { onSchedule } from "firebase-functions/v2/scheduler";
import { onTaskDispatched } from "firebase-functions/v2/tasks";

import { COLLECTIONS, boolValue, intValue, stringValue } from "./firestore.js";
import {
  WEEK_MS,
  weeklyCompetitionId,
  weeklyRewardFor,
  type WeeklyBoardKind,
} from "./weekly_competition.js";
import {
  INITIAL_WEEKLY_STANDING,
  nextWeeklyStanding,
  type WeeklyStandingState,
} from "./weekly_ranking.js";
import { weeklyRolloverPlan } from "./weekly_rollover_policy.js";

const REGION = "me-central2";
const PAGE_SIZE = 200;
const PLAYER_CONCURRENCY = 20;

interface WeeklyRewardCursor extends WeeklyStandingState {
  score: number;
  uid: string;
}

interface WeeklyRewardPageTask {
  weekId: string;
  board: WeeklyBoardKind;
  offset: number;
  cursor?: WeeklyRewardCursor;
}

function entryCollection(board: WeeklyBoardKind): string {
  return board === "rp" ? "rpEntries" : "goldEntries";
}

function taskId(task: WeeklyRewardPageTask): string {
  return `${task.weekId}_${task.board}_${task.offset}`.replace(/[^A-Za-z0-9_-]/g, "_");
}

function isAlreadyExists(error: unknown): boolean {
  if (!error || typeof error !== "object") return false;
  const code = (error as { code?: unknown }).code;
  return code === "functions/task-already-exists" || code === "task-already-exists";
}

async function enqueueRewardPage(task: WeeklyRewardPageTask): Promise<void> {
  const queue = getFunctions().taskQueue<WeeklyRewardPageTask>(
    `locations/${REGION}/functions/processWeeklyRewardPage`,
  );
  try {
    await queue.enqueue(task, {
      id: taskId(task),
      dispatchDeadlineSeconds: 540,
    });
  } catch (error) {
    if (!isAlreadyExists(error)) throw error;
  }
}

function rewardPageQuery(task: WeeklyRewardPageTask): Query<DocumentData> {
  const entries = getFirestore()
    .collection(COLLECTIONS.weeklyLeaderboards)
    .doc(task.weekId)
    .collection(entryCollection(task.board));
  let query: Query<DocumentData> = entries
    .orderBy("score", "desc")
    .orderBy(FieldPath.documentId(), "asc")
    .limit(PAGE_SIZE);
  if (task.cursor) {
    query = query.startAfter(task.cursor.score, task.cursor.uid);
  }
  return query;
}

async function runWithConcurrency<T>(
  items: readonly T[],
  worker: (item: T, index: number) => Promise<void>,
): Promise<void> {
  for (let start = 0; start < items.length; start += PLAYER_CONCURRENCY) {
    const chunk = items.slice(start, start + PLAYER_CONCURRENCY);
    await Promise.all(chunk.map((item, index) => worker(item, start + index)));
  }
}

async function grantWeeklyReward(options: {
  weekId: string;
  board: WeeklyBoardKind;
  uid: string;
  standing: number;
  score: number;
  active: boolean;
}): Promise<void> {
  const db = getFirestore();
  const { weekId, board, uid, standing, score, active } = options;
  const reward = weeklyRewardFor(board, standing, active);
  const grantRef = db
    .collection(COLLECTIONS.weeklyCompetitionGrants)
    .doc(weekId)
    .collection("grants")
    .doc(`${board}_${uid}`);
  const inventoryRef = db.collection(COLLECTIONS.inventories).doc(uid);
  const userRef = db.collection(COLLECTIONS.users).doc(uid);
  const entryRef = db
    .collection(COLLECTIONS.weeklyLeaderboards)
    .doc(weekId)
    .collection(entryCollection(board))
    .doc(uid);
  const goldTxRef = db
    .collection(COLLECTIONS.goldTransactions)
    .doc(`weekly_${weekId}_${board}_${uid}`);
  const starTxRef = db
    .collection(COLLECTIONS.prestigeStarTransactions)
    .doc(`weekly_${weekId}_${board}_${uid}`);

  await db.runTransaction(async (transaction) => {
    const grant = await transaction.get(grantRef);
    if (grant.exists) return;

    if (reward.gold > 0) {
      transaction.set(
        inventoryRef,
        {
          gold: FieldValue.increment(reward.gold),
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
      transaction.create(goldTxRef, {
        uid,
        amount: reward.gold,
        type: "weeklyCompetitionReward",
        source: board,
        weekId,
        standing,
        score,
        excludedFromWeeklyGoldScore: true,
        createdAt: FieldValue.serverTimestamp(),
      });
    }
    if (reward.stars > 0) {
      transaction.set(
        userRef,
        {
          stars: FieldValue.increment(reward.stars),
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
      transaction.create(starTxRef, {
        uid,
        amount: reward.stars,
        type: "weeklyCompetitionReward",
        source: board,
        weekId,
        standing,
        score,
        createdAt: FieldValue.serverTimestamp(),
      });
    }
    transaction.set(
      entryRef,
      {
        finalStanding: standing,
        rewardGold: reward.gold,
        rewardStars: reward.stars,
        rewardGrantedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
    transaction.create(grantRef, {
      uid,
      weekId,
      board,
      standing,
      score,
      active,
      goldAwarded: reward.gold,
      starsAwarded: reward.stars,
      createdAt: FieldValue.serverTimestamp(),
    });
  });
}

async function markBoardComplete(weekId: string, board: WeeklyBoardKind): Promise<void> {
  const db = getFirestore();
  const weekRef = db.collection(COLLECTIONS.weeklyLeaderboards).doc(weekId);
  await db.runTransaction(async (transaction) => {
    const snap = await transaction.get(weekRef);
    if (!snap.exists) return;
    const data = snap.data() ?? {};
    const otherComplete = board === "rp"
      ? boolValue(data.goldRewardsComplete)
      : boolValue(data.rpRewardsComplete);
    const update: Record<string, unknown> = {
      [`${board}RewardsComplete`]: true,
      updatedAt: FieldValue.serverTimestamp(),
    };
    if (otherComplete) {
      update.state = "closed";
      update.closedAt = FieldValue.serverTimestamp();
    }
    transaction.update(weekRef, update);
  });
}

export const processWeeklyRewardPage = onTaskDispatched<WeeklyRewardPageTask>(
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
      maxConcurrentDispatches: 12,
      maxDispatchesPerSecond: 12,
    },
  },
  async (request) => {
    const raw = request.data;
    const weekId = stringValue(raw?.weekId);
    const board = raw?.board === "gold" ? "gold" : raw?.board === "rp" ? "rp" : null;
    const offset = Math.max(0, intValue(raw?.offset));
    if (!weekId || !board) throw new Error("Valid weekId and board are required.");

    const weekRef = getFirestore().collection(COLLECTIONS.weeklyLeaderboards).doc(weekId);
    const week = (await weekRef.get()).data();
    // Reward workers are allowed to run only after rollover freezes standings.
    // This blocks accidental/stale/manual task dispatches from paying an open week.
    if (!week || week.state !== "processing") return;

    const cursor = raw?.cursor && typeof raw.cursor === "object"
      ? {
          score: intValue(raw.cursor.score),
          uid: stringValue(raw.cursor.uid),
          position: Math.max(0, intValue(raw.cursor.position)),
          standing: Math.max(0, intValue(raw.cursor.standing)),
          previousScore:
            typeof raw.cursor.previousScore === "number" && Number.isFinite(raw.cursor.previousScore)
              ? Math.trunc(raw.cursor.previousScore)
              : null,
        }
      : undefined;
    const task: WeeklyRewardPageTask = { weekId, board, offset, cursor };
    const page = await rewardPageQuery(task).get();
    const docs = page.docs;

    let standingState: WeeklyStandingState = cursor
      ? {
          position: cursor.position,
          standing: cursor.standing,
          previousScore: cursor.previousScore,
        }
      : INITIAL_WEEKLY_STANDING;
    const ranked = docs.map((doc) => {
      const data = doc.data();
      const score = intValue(data.score);
      const result = nextWeeklyStanding(standingState, score);
      standingState = result;
      return {
        uid: doc.id,
        score,
        active: boolValue(data.active, false),
        standing: result.awardedStanding,
      };
    });

    await runWithConcurrency(ranked, async (entry) => {
      await grantWeeklyReward({ weekId, board, ...entry });
    });

    if (docs.length === PAGE_SIZE) {
      const last = docs[docs.length - 1]!;
      const lastScore = intValue(last.data().score);
      await enqueueRewardPage({
        weekId,
        board,
        offset: offset + docs.length,
        cursor: {
          score: lastScore,
          uid: last.id,
          position: standingState.position,
          standing: standingState.standing,
          previousScore: standingState.previousScore,
        },
      });
      return;
    }

    await markBoardComplete(weekId, board);
  },
);

export const rolloverWeeklyCompetition = onSchedule(
  {
    schedule: "every 1 hours",
    region: REGION,
    timeZone: "UTC",
    timeoutSeconds: 180,
    memory: "256MiB",
  },
  async () => {
    const now = Date.now();
    const previousWeekId = weeklyCompetitionId(now - WEEK_MS);
    const db = getFirestore();
    const weekRef = db.collection(COLLECTIONS.weeklyLeaderboards).doc(previousWeekId);

    const plan = await db.runTransaction(async (transaction) => {
      const snap = await transaction.get(weekRef);
      if (!snap.exists) return null;
      const data = snap.data() ?? {};
      const endsAt = data.endsAt;
      const nextPlan = weeklyRolloverPlan({
        state: data.state,
        endsAtMs: endsAt instanceof Timestamp ? endsAt.toMillis() : null,
        nowMs: now,
        rpRewardsComplete: boolValue(data.rpRewardsComplete),
        goldRewardsComplete: boolValue(data.goldRewardsComplete),
      });
      if (!nextPlan) return null;
      if (nextPlan.markProcessing) {
        transaction.update(weekRef, {
          state: "processing",
          processingStartedAt: FieldValue.serverTimestamp(),
          updatedAt: FieldValue.serverTimestamp(),
        });
      }
      return nextPlan;
    });
    if (!plan) return;

    await Promise.all(
      plan.boardsToEnqueue.map((board) =>
        enqueueRewardPage({ weekId: previousWeekId, board, offset: 0 }),
      ),
    );
  },
);
