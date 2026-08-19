import { randomInt } from "node:crypto";

import { FieldValue, Timestamp, getFirestore } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";

import {
  AUTHORITY_VERSION,
  COLLECTIONS,
  boolValue,
  emptyProgress,
  intValue,
  parseProgress,
  stringValue,
  timestampMillis,
} from "./firestore.js";
import {
  applyXp,
  compareMatch,
  resultForPlayer,
  type RankedResult,
} from "./policy.js";
import {
  MATCH_DURATION_MS,
  MATCH_GAME_COUNT,
  REGISTRY_VERSION,
  parseEvidence,
  validateEvidence,
} from "./registry.js";

const OPTIONS = {
  region: "me-central2",
  enforceAppCheck: true,
  timeoutSeconds: 60,
} as const;

const COUNTDOWN_MS = 3000;
const SUBMISSION_GRACE_MS = 15000;

export const QUICK_REWARDS: Readonly<Record<RankedResult, { xp: number; coins: number }>> = {
  win: { xp: 70, coins: 18 },
  tie: { xp: 50, coins: 12 },
  loss: { xp: 30, coins: 6 },
};

export function quickPairMultiplier(matchesTodayBeforeThisOne: number): number {
  if (matchesTodayBeforeThisOne < 10) return 1;
  if (matchesTodayBeforeThisOne < 20) return 0.25;
  return 0;
}

function uidOf(uid: string | undefined): string {
  if (!uid) throw new HttpsError("unauthenticated", "Sign-in is required.");
  return uid;
}

function text(value: unknown, name: string): string {
  if (typeof value !== "string" || value.trim().length === 0) {
    throw new HttpsError("invalid-argument", `${name} is required.`);
  }
  return value.trim();
}

function dayId(now: Date): string {
  return now.toISOString().slice(0, 10);
}

function weekId(now: Date): string {
  const date = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate()));
  const day = date.getUTCDay() || 7;
  date.setUTCDate(date.getUTCDate() + 4 - day);
  const start = new Date(Date.UTC(date.getUTCFullYear(), 0, 1));
  const week = Math.ceil((((date.getTime() - start.getTime()) / 86400000) + 1) / 7);
  return `${date.getUTCFullYear()}-W${String(week).padStart(2, "0")}`;
}

function freshQuickMatch(options: {
  playerAId: string;
  playerAName: string;
  playerAAvatarId: string;
  playerBId: string;
  playerBName: string;
  playerBAvatarId: string;
}): Record<string, unknown> {
  return {
    ...options,
    mode: "quick",
    authorityVersion: AUTHORITY_VERSION,
    seed: randomInt(0, 0x7fffffff),
    gameCount: MATCH_GAME_COUNT,
    registryVersion: REGISTRY_VERSION,
    status: "waitingReady",
    readyA: false,
    readyB: false,
    progressA: emptyProgress(),
    progressB: emptyProgress(),
    rematchA: false,
    rematchB: false,
    rematchMatchId: null,
    cancelledBy: null,
    countdownStartedAt: null,
    createdAt: FieldValue.serverTimestamp(),
    updatedAt: FieldValue.serverTimestamp(),
  };
}

function requireQuickMatch(match: Record<string, unknown>): void {
  if (stringValue(match.mode) !== "quick") {
    throw new HttpsError("failed-precondition", "This is not a Quick match.");
  }
  if (intValue(match.authorityVersion) !== AUTHORITY_VERSION) {
    throw new HttpsError("failed-precondition", "Quick authority is unavailable for this match.");
  }
  if (intValue(match.registryVersion) !== REGISTRY_VERSION) {
    throw new HttpsError("failed-precondition", "Registry version mismatch.");
  }
}

function requireParticipant(match: Record<string, unknown>, uid: string): {
  playerAId: string;
  playerBId: string;
} {
  const playerAId = stringValue(match.playerAId);
  const playerBId = stringValue(match.playerBId);
  if (!playerAId || !playerBId || playerAId === playerBId) {
    throw new HttpsError("data-loss", "Invalid Quick match participants.");
  }
  if (uid !== playerAId && uid !== playerBId) {
    throw new HttpsError("permission-denied", "Not a Quick match participant.");
  }
  return { playerAId, playerBId };
}

function requireSubmissionWindow(match: Record<string, unknown>): void {
  const countdown = timestampMillis(match.countdownStartedAt);
  if (countdown === null) {
    throw new HttpsError("failed-precondition", "Quick match has not started.");
  }
  const now = Date.now();
  const startsAt = countdown + COUNTDOWN_MS;
  if (now < startsAt) {
    throw new HttpsError("failed-precondition", "Quick countdown is still running.");
  }
  if (now > startsAt + MATCH_DURATION_MS + SUBMISSION_GRACE_MS) {
    throw new HttpsError("deadline-exceeded", "Quick submission window has closed.");
  }
}

async function activeMissionSeasonId(now: Date): Promise<string | null> {
  const snapshot = await getFirestore()
    .collection(COLLECTIONS.seasons)
    .where("active", "==", true)
    .limit(2)
    .get();
  if (snapshot.size !== 1) return null;
  const doc = snapshot.docs[0]!;
  const data = doc.data();
  const startsAt = timestampMillis(data.startsAt);
  const endsAt = timestampMillis(data.endsAt);
  if (startsAt === null || endsAt === null) return null;
  const nowMs = now.getTime();
  return nowMs >= startsAt && nowMs < endsAt ? doc.id : null;
}

function objectValue(value: unknown): Record<string, unknown> {
  return value !== null && typeof value === "object"
    ? value as Record<string, unknown>
    : {};
}

function advanceMission(
  states: Record<string, unknown>,
  id: string,
  target: number,
  window: string,
  delta: number,
): void {
  const previous = objectValue(states[id]);
  const sameWindow = previous.windowId === window;
  const before = sameWindow ? Math.max(0, intValue(previous.progress)) : 0;
  const claimedAt = sameWindow && previous.claimedAt instanceof Timestamp
    ? previous.claimedAt
    : null;
  const progress = Math.min(target, before + delta);
  states[id] = { windowId: window, progress, completed: progress >= target, claimedAt };
}

export const joinQuickQueue = onCall(OPTIONS, async (request) => {
  const uid = uidOf(request.auth?.uid);
  const gameName = text(request.data?.gameName, "gameName");
  const avatarId = text(request.data?.avatarId, "avatarId");
  const db = getFirestore();
  const queue = db.collection(COLLECTIONS.quickMatchmaking);
  const ownRef = queue.doc(uid);

  await ownRef.set({
    uid,
    gameName,
    avatarId,
    status: "waiting",
    matchId: null,
    authorityVersion: AUTHORITY_VERSION,
    createdAt: FieldValue.serverTimestamp(),
    updatedAt: FieldValue.serverTimestamp(),
  });

  const candidates = await queue.where("status", "==", "waiting").limit(20).get();
  for (const candidate of candidates.docs) {
    if (candidate.id === uid) continue;
    const matchRef = db.collection(COLLECTIONS.matches).doc();
    try {
      const matchId = await db.runTransaction(async (transaction) => {
        const [ownSnap, otherSnap] = await Promise.all([
          transaction.get(ownRef),
          transaction.get(candidate.ref),
        ]);
        const own = ownSnap.data();
        const other = otherSnap.data();
        if (!own || !other || own.status !== "waiting" || other.status !== "waiting") {
          throw new Error("ticket_claimed");
        }
        if (intValue(other.authorityVersion) !== AUTHORITY_VERSION) {
          throw new Error("legacy_ticket");
        }
        const otherUid = stringValue(other.uid, candidate.id);
        if (otherUid === uid) throw new Error("self_match");

        transaction.create(
          matchRef,
          freshQuickMatch({
            playerAId: otherUid,
            playerAName: stringValue(other.gameName, "Player"),
            playerAAvatarId: stringValue(other.avatarId, "default_01"),
            playerBId: uid,
            playerBName: gameName,
            playerBAvatarId: avatarId,
          }),
        );
        transaction.update(ownRef, {
          status: "matched",
          matchId: matchRef.id,
          updatedAt: FieldValue.serverTimestamp(),
        });
        transaction.update(candidate.ref, {
          status: "matched",
          matchId: matchRef.id,
          updatedAt: FieldValue.serverTimestamp(),
        });
        return matchRef.id;
      });
      return { status: "matched", matchId };
    } catch {
      continue;
    }
  }
  return { status: "waiting", matchId: null };
});

export const leaveQuickQueue = onCall(OPTIONS, async (request) => {
  const uid = uidOf(request.auth?.uid);
  const ref = getFirestore().collection(COLLECTIONS.quickMatchmaking).doc(uid);
  await getFirestore().runTransaction(async (transaction) => {
    const snap = await transaction.get(ref);
    if (snap.exists && snap.data()?.status === "waiting") transaction.delete(ref);
  });
  return { ok: true };
});

export const clearQuickTicket = onCall(OPTIONS, async (request) => {
  const uid = uidOf(request.auth?.uid);
  await getFirestore().collection(COLLECTIONS.quickMatchmaking).doc(uid).delete();
  return { ok: true };
});

export const syncQuickTicket = onCall(OPTIONS, async (request) => {
  const uid = uidOf(request.auth?.uid);
  const matchId = text(request.data?.matchId, "matchId");
  const db = getFirestore();
  await db.runTransaction(async (transaction) => {
    const match = (await transaction.get(db.collection(COLLECTIONS.matches).doc(matchId))).data();
    if (!match) throw new HttpsError("not-found", "Quick match not found.");
    requireQuickMatch(match);
    requireParticipant(match, uid);
    transaction.set(
      db.collection(COLLECTIONS.quickMatchmaking).doc(uid),
      {
        uid,
        status: "matched",
        matchId,
        authorityVersion: AUTHORITY_VERSION,
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
  });
  return { ok: true };
});

export const markQuickReady = onCall(OPTIONS, async (request) => {
  const uid = uidOf(request.auth?.uid);
  const matchId = text(request.data?.matchId, "matchId");
  const ref = getFirestore().collection(COLLECTIONS.matches).doc(matchId);
  await getFirestore().runTransaction(async (transaction) => {
    const snap = await transaction.get(ref);
    const match = snap.data();
    if (!match) throw new HttpsError("not-found", "Quick match not found.");
    requireQuickMatch(match);
    const { playerAId, playerBId } = requireParticipant(match, uid);
    if (match.status !== "waitingReady") return;
    const nextReadyA = uid === playerAId ? true : boolValue(match.readyA);
    const nextReadyB = uid === playerBId ? true : boolValue(match.readyB);
    transaction.update(ref, {
      readyA: nextReadyA,
      readyB: nextReadyB,
      ...(nextReadyA && nextReadyB && match.countdownStartedAt == null
        ? { countdownStartedAt: FieldValue.serverTimestamp(), status: "countdown" }
        : {}),
      updatedAt: FieldValue.serverTimestamp(),
    });
  });
  return { ok: true };
});

export const cancelQuickMatch = onCall(OPTIONS, async (request) => {
  const uid = uidOf(request.auth?.uid);
  const matchId = text(request.data?.matchId, "matchId");
  const ref = getFirestore().collection(COLLECTIONS.matches).doc(matchId);
  await getFirestore().runTransaction(async (transaction) => {
    const snap = await transaction.get(ref);
    const match = snap.data();
    if (!match) throw new HttpsError("not-found", "Quick match not found.");
    requireQuickMatch(match);
    requireParticipant(match, uid);
    if (match.status !== "waitingReady" || match.countdownStartedAt != null) {
      throw new HttpsError("failed-precondition", "Quick match already started.");
    }
    transaction.update(ref, {
      status: "cancelled",
      cancelledBy: uid,
      updatedAt: FieldValue.serverTimestamp(),
    });
  });
  return { ok: true };
});

export const submitQuickGameResult = onCall(OPTIONS, async (request) => {
  const uid = uidOf(request.auth?.uid);
  const matchId = text(request.data?.matchId, "matchId");
  let item;
  try {
    item = parseEvidence([request.data?.evidence])[0]!;
  } catch (error) {
    throw new HttpsError(
      "invalid-argument",
      error instanceof Error ? error.message : "Invalid Quick evidence.",
    );
  }

  const db = getFirestore();
  const matchRef = db.collection(COLLECTIONS.matches).doc(matchId);
  const evidenceRef = db.collection(COLLECTIONS.quickEvidence)
    .doc(matchId)
    .collection(COLLECTIONS.players)
    .doc(uid);

  return db.runTransaction(async (transaction) => {
    const [matchSnap, evidenceSnap] = await Promise.all([
      transaction.get(matchRef),
      transaction.get(evidenceRef),
    ]);
    const match = matchSnap.data();
    if (!match) throw new HttpsError("not-found", "Quick match not found.");
    requireQuickMatch(match);
    const { playerAId } = requireParticipant(match, uid);
    if (match.status === "cancelled" || match.status === "finished") {
      throw new HttpsError("failed-precondition", "Quick match is already closed.");
    }
    requireSubmissionWindow(match);

    let previous;
    try {
      previous = parseEvidence(evidenceSnap.data()?.evidence ?? []);
    } catch {
      throw new HttpsError("data-loss", "Stored Quick evidence is invalid.");
    }
    if (item.gameIndex !== previous.length) {
      throw new HttpsError("failed-precondition", "Quick result is out of order.");
    }
    const combined = [...previous, item];
    const gameCount = intValue(match.gameCount, MATCH_GAME_COUNT);
    if (!validateEvidence({
      matchSeed: intValue(match.seed),
      gameCount,
      completedGames: combined.length,
      evidence: combined,
    })) {
      throw new HttpsError("invalid-argument", "Quick evidence failed integrity checks.");
    }

    const progressField = uid === playerAId ? "progressA" : "progressB";
    const saved = parseProgress(match[progressField]);
    if (saved.completedGames !== previous.length) {
      throw new HttpsError("failed-precondition", "Quick progress and evidence are out of sync.");
    }
    const totalScore = combined.reduce((sum, entry) => sum + entry.score, 0);
    const accuracyTotal = combined.reduce((sum, entry) => sum + entry.accuracy, 0);
    const mistakes = combined.reduce((sum, entry) => sum + entry.mistakes, 0);
    const elapsedMs = combined.reduce((sum, entry) => sum + entry.durationMs, 0);

    transaction.set(
      evidenceRef,
      {
        uid,
        matchId,
        registryVersion: REGISTRY_VERSION,
        evidence: combined,
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
    transaction.update(matchRef, {
      [progressField]: {
        completedGames: combined.length,
        totalScore,
        accuracyTotal,
        mistakes,
        elapsedMs,
        completedAt: combined.length >= gameCount ? FieldValue.serverTimestamp() : null,
      },
      status: "playing",
      updatedAt: FieldValue.serverTimestamp(),
    });
    return { ok: true, completedGames: combined.length };
  });
});

export const requestQuickRematch = onCall(OPTIONS, async (request) => {
  const uid = uidOf(request.auth?.uid);
  const matchId = text(request.data?.matchId, "matchId");
  const db = getFirestore();
  const ref = db.collection(COLLECTIONS.matches).doc(matchId);
  return db.runTransaction(async (transaction) => {
    const snap = await transaction.get(ref);
    const match = snap.data();
    if (!match) throw new HttpsError("not-found", "Quick match not found.");
    requireQuickMatch(match);
    const { playerAId: a, playerBId: b } = requireParticipant(match, uid);
    if (typeof match.rematchMatchId === "string") return { matchId: match.rematchMatchId };

    const nextA = uid === a ? true : boolValue(match.rematchA);
    const nextB = uid === b ? true : boolValue(match.rematchB);
    const updates: Record<string, unknown> = {
      rematchA: nextA,
      rematchB: nextB,
      updatedAt: FieldValue.serverTimestamp(),
    };
    let newMatchId: string | null = null;
    if (nextA && nextB) {
      const newRef = db.collection(COLLECTIONS.matches).doc();
      newMatchId = newRef.id;
      transaction.create(
        newRef,
        freshQuickMatch({
          playerAId: a,
          playerAName: stringValue(match.playerAName, "Player"),
          playerAAvatarId: stringValue(match.playerAAvatarId, "default_01"),
          playerBId: b,
          playerBName: stringValue(match.playerBName, "Player"),
          playerBAvatarId: stringValue(match.playerBAvatarId, "default_01"),
        }),
      );
      updates.rematchMatchId = newMatchId;
    }
    transaction.update(ref, updates);
    return { matchId: newMatchId };
  });
});

export const cancelQuickRematch = onCall(OPTIONS, async (request) => {
  const uid = uidOf(request.auth?.uid);
  const matchId = text(request.data?.matchId, "matchId");
  const ref = getFirestore().collection(COLLECTIONS.matches).doc(matchId);
  await getFirestore().runTransaction(async (transaction) => {
    const match = (await transaction.get(ref)).data();
    if (!match || typeof match.rematchMatchId === "string") return;
    requireQuickMatch(match);
    const { playerAId, playerBId } = requireParticipant(match, uid);
    transaction.update(ref, {
      ...(uid === playerAId
        ? { rematchA: false }
        : uid === playerBId
          ? { rematchB: false }
          : {}),
      updatedAt: FieldValue.serverTimestamp(),
    });
  });
  return { ok: true };
});

export const settleQuickMatch = onCall(OPTIONS, async (request) => {
  const callerUid = uidOf(request.auth?.uid);
  const matchId = text(request.data?.matchId, "matchId");
  const db = getFirestore();
  const matchRef = db.collection(COLLECTIONS.matches).doc(matchId);
  const settlementRef = db.collection(COLLECTIONS.quickSettlements).doc(matchId);
  const now = new Date();
  const missionSeasonId = await activeMissionSeasonId(now);

  return db.runTransaction(async (transaction) => {
    const [matchSnap, existingSettlement] = await Promise.all([
      transaction.get(matchRef),
      transaction.get(settlementRef),
    ]);
    const match = matchSnap.data();
    if (!match) throw new HttpsError("not-found", "Quick match not found.");
    requireQuickMatch(match);
    const { playerAId, playerBId } = requireParticipant(match, callerUid);
    if (existingSettlement.exists) {
      const stored = existingSettlement.data()?.payload;
      if (stored && typeof stored === "object") return stored;
      throw new HttpsError("data-loss", "Quick settlement is incomplete.");
    }
    if (match.status === "cancelled") {
      throw new HttpsError("failed-precondition", "Cancelled Quick matches cannot settle.");
    }

    const gameCount = intValue(match.gameCount, MATCH_GAME_COUNT);
    const progressA = parseProgress(match.progressA);
    const progressB = parseProgress(match.progressB);
    const countdown = timestampMillis(match.countdownStartedAt);
    const bothComplete = progressA.completedGames >= gameCount && progressB.completedGames >= gameCount;
    const deadlinePassed = countdown !== null && Date.now() >= countdown + COUNTDOWN_MS + MATCH_DURATION_MS;
    if (!bothComplete && !deadlinePassed) {
      throw new HttpsError("failed-precondition", "Quick match is still in progress.");
    }

    const evidenceARef = db.collection(COLLECTIONS.quickEvidence)
      .doc(matchId).collection(COLLECTIONS.players).doc(playerAId);
    const evidenceBRef = db.collection(COLLECTIONS.quickEvidence)
      .doc(matchId).collection(COLLECTIONS.players).doc(playerBId);
    const [evidenceASnap, evidenceBSnap] = await Promise.all([
      transaction.get(evidenceARef),
      transaction.get(evidenceBRef),
    ]);
    let evidenceA;
    let evidenceB;
    try {
      evidenceA = parseEvidence(evidenceASnap.data()?.evidence ?? []);
      evidenceB = parseEvidence(evidenceBSnap.data()?.evidence ?? []);
    } catch {
      throw new HttpsError("data-loss", "Stored Quick evidence is invalid.");
    }
    if (
      !validateEvidence({
        matchSeed: intValue(match.seed),
        gameCount,
        completedGames: progressA.completedGames,
        evidence: evidenceA,
      }) ||
      !validateEvidence({
        matchSeed: intValue(match.seed),
        gameCount,
        completedGames: progressB.completedGames,
        evidence: evidenceB,
      })
    ) {
      throw new HttpsError("failed-precondition", "Quick evidence failed integrity checks.");
    }

    const playerARef = db.collection(COLLECTIONS.users).doc(playerAId);
    const playerBRef = db.collection(COLLECTIONS.users).doc(playerBId);
    const inventoryARef = db.collection(COLLECTIONS.inventories).doc(playerAId);
    const inventoryBRef = db.collection(COLLECTIONS.inventories).doc(playerBId);
    const missionARef = db.collection(COLLECTIONS.playerMissions).doc(playerAId);
    const missionBRef = db.collection(COLLECTIONS.playerMissions).doc(playerBId);
    const pairKey = [playerAId, playerBId].sort().join("_");
    const pairRef = db.collection(COLLECTIONS.quickPairUsage).doc(`${dayId(now)}_${pairKey}`);

    const [profileASnap, profileBSnap, inventoryASnap, inventoryBSnap, missionASnap, missionBSnap, pairSnap] =
      await Promise.all([
        transaction.get(playerARef),
        transaction.get(playerBRef),
        transaction.get(inventoryARef),
        transaction.get(inventoryBRef),
        transaction.get(missionARef),
        transaction.get(missionBRef),
        transaction.get(pairRef),
      ]);
    const profileA = profileASnap.data();
    const profileB = profileBSnap.data();
    if (!profileA || !profileB) {
      throw new HttpsError("failed-precondition", "Both Quick profiles must exist.");
    }

    const outcome = compareMatch(progressA, progressB, gameCount);
    const resultA = resultForPlayer(outcome, "playerA");
    const resultB = resultForPlayer(outcome, "playerB");
    const repeatedBefore = Math.max(0, intValue(pairSnap.data()?.matches));
    const multiplier = quickPairMultiplier(repeatedBefore);
    const rewardA = QUICK_REWARDS[resultA];
    const rewardB = QUICK_REWARDS[resultB];
    const coinsA = Math.floor(rewardA.coins * multiplier);
    const coinsB = Math.floor(rewardB.coins * multiplier);
    const xpA = Math.floor(rewardA.xp * multiplier);
    const xpB = Math.floor(rewardB.xp * multiplier);

    const progressionA = applyXp(
      { level: intValue(profileA.level, 1), xp: intValue(profileA.xp) },
      xpA,
    );
    const progressionB = applyXp(
      { level: intValue(profileB.level, 1), xp: intValue(profileB.xp) },
      xpB,
    );
    const inventoryA = inventoryASnap.data() ?? {};
    const inventoryB = inventoryBSnap.data() ?? {};
    const nextCoinsA = Math.max(0, intValue(inventoryA.coins)) + coinsA;
    const nextCoinsB = Math.max(0, intValue(inventoryB.coins)) + coinsB;

    transaction.update(playerARef, {
      level: progressionA.level,
      xp: progressionA.xp,
      quickGamesPlayed: intValue(profileA.quickGamesPlayed) + 1,
      quickWins: intValue(profileA.quickWins) + (resultA === "win" ? 1 : 0),
      quickLosses: intValue(profileA.quickLosses) + (resultA === "loss" ? 1 : 0),
      quickTies: intValue(profileA.quickTies) + (resultA === "tie" ? 1 : 0),
      updatedAt: FieldValue.serverTimestamp(),
    });
    transaction.update(playerBRef, {
      level: progressionB.level,
      xp: progressionB.xp,
      quickGamesPlayed: intValue(profileB.quickGamesPlayed) + 1,
      quickWins: intValue(profileB.quickWins) + (resultB === "win" ? 1 : 0),
      quickLosses: intValue(profileB.quickLosses) + (resultB === "loss" ? 1 : 0),
      quickTies: intValue(profileB.quickTies) + (resultB === "tie" ? 1 : 0),
      updatedAt: FieldValue.serverTimestamp(),
    });
    transaction.set(inventoryARef, { coins: nextCoinsA, updatedAt: FieldValue.serverTimestamp() }, { merge: true });
    transaction.set(inventoryBRef, { coins: nextCoinsB, updatedAt: FieldValue.serverTimestamp() }, { merge: true });

    if (missionSeasonId !== null) {
      for (const [missionSnap, missionRef, result] of [
        [missionASnap, missionARef, resultA],
        [missionBSnap, missionBRef, resultB],
      ] as const) {
        const data = missionSnap.data() ?? {};
        const states = stringValue(data.seasonId) === missionSeasonId
          ? { ...objectValue(data.states) }
          : {};
        advanceMission(states, "daily_play_3", 3, `D:${dayId(now)}`, 1);
        advanceMission(states, "weekly_play_30", 30, `W:${weekId(now)}`, 1);
        if (result === "win") {
          advanceMission(states, "daily_win_1", 1, `D:${dayId(now)}`, 1);
          advanceMission(states, "weekly_win_15", 15, `W:${weekId(now)}`, 1);
        }
        transaction.set(
          missionRef,
          { seasonId: missionSeasonId, states, updatedAt: FieldValue.serverTimestamp() },
          { merge: true },
        );
      }
    }

    transaction.set(
      pairRef,
      {
        participantUids: [playerAId, playerBId].sort(),
        dayId: dayId(now),
        matches: repeatedBefore + 1,
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );

    if (coinsA > 0) {
      transaction.create(db.collection(COLLECTIONS.coinTransactions).doc(`${matchId}_${playerAId}_quick`), {
        transactionId: `${matchId}_${playerAId}_quick`,
        uid: playerAId,
        matchId,
        reason: "quickMatchReward",
        result: resultA,
        repeatedPairMatchesBefore: repeatedBefore,
        multiplier,
        amount: coinsA,
        balanceAfter: nextCoinsA,
        createdAt: Timestamp.fromDate(now),
      });
    }
    if (coinsB > 0) {
      transaction.create(db.collection(COLLECTIONS.coinTransactions).doc(`${matchId}_${playerBId}_quick`), {
        transactionId: `${matchId}_${playerBId}_quick`,
        uid: playerBId,
        matchId,
        reason: "quickMatchReward",
        result: resultB,
        repeatedPairMatchesBefore: repeatedBefore,
        multiplier,
        amount: coinsB,
        balanceAfter: nextCoinsB,
        createdAt: Timestamp.fromDate(now),
      });
    }

    const payload = {
      matchId,
      mode: "quick",
      missionSeasonId,
      repeatedPairMatchesBefore: repeatedBefore,
      multiplier,
      playerA: { uid: playerAId, result: resultA, xpAwarded: xpA, coinsAwarded: coinsA, rpDelta: 0 },
      playerB: { uid: playerBId, result: resultB, xpAwarded: xpB, coinsAwarded: coinsB, rpDelta: 0 },
      settledAt: now.toISOString(),
    };
    transaction.update(matchRef, {
      status: "finished",
      settledMode: "quick",
      updatedAt: FieldValue.serverTimestamp(),
    });
    transaction.create(settlementRef, {
      matchId,
      mode: "quick",
      payload,
      settledAt: Timestamp.fromDate(now),
      createdAt: FieldValue.serverTimestamp(),
    });
    return payload;
  });
});
