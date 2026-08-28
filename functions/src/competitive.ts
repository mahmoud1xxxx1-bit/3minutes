import { randomInt } from "node:crypto";

import { FieldValue, getFirestore, Timestamp } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";

import {
  COMPETITIVE_DURATION_MS,
  COMPETITIVE_PICKS_PER_PLAYER,
  DAILY_GOLD_GRANT,
  isCompetitiveWager,
} from "./competitive_policy.js";

const REGION = "me-central2";
const CALLABLE_OPTIONS = {
  region: REGION,
  enforceAppCheck: true,
  timeoutSeconds: 30,
} as const;

const db = getFirestore();
const walletRefFor = (uid: string) => db.collection("competitiveWallets").doc(uid);

function requireUid(uid: string | undefined): string {
  if (!uid) throw new HttpsError("unauthenticated", "Authentication required.");
  return uid;
}

function requireString(value: unknown, name: string): string {
  if (typeof value !== "string" || value.trim().length === 0) {
    throw new HttpsError("invalid-argument", `${name} is required.`);
  }
  return value.trim();
}

function dayKey(now = new Date()): string {
  return now.toISOString().slice(0, 10);
}

function intValue(value: unknown): number {
  return Number.isFinite(Number(value)) ? Math.trunc(Number(value)) : 0;
}

function parseGameIds(value: unknown): string[] {
  if (!Array.isArray(value) || value.length !== COMPETITIVE_PICKS_PER_PLAYER) {
    throw new HttpsError("invalid-argument", "Exactly two games must be selected.");
  }
  const ids = value.map((item) => requireString(item, "gameId"));
  if (new Set(ids).size !== ids.length) {
    throw new HttpsError("invalid-argument", "Your two selected games must be different.");
  }
  return ids;
}

export const claimDailyGold = onCall(CALLABLE_OPTIONS, async (request) => {
  const uid = requireUid(request.auth?.uid);
  const key = dayKey();
  const walletRef = walletRefFor(uid);
  const mailRef = walletRef.collection("dailyGoldMail").doc(key);
  const ledgerRef = walletRef.collection("goldTransactions").doc(`daily_${key}`);

  return db.runTransaction(async (tx) => {
    const [walletSnap, mailSnap] = await Promise.all([tx.get(walletRef), tx.get(mailRef)]);
    if (mailSnap.exists && mailSnap.data()?.claimed === true) {
      throw new HttpsError("already-exists", "Daily GOLD already claimed.");
    }
    const current = intValue(walletSnap.data()?.gold);
    const next = current + DAILY_GOLD_GRANT;
    tx.set(walletRef, {
      uid,
      gold: next,
      heldGold: intValue(walletSnap.data()?.heldGold),
      updatedAt: FieldValue.serverTimestamp(),
      ...(walletSnap.exists ? {} : { createdAt: FieldValue.serverTimestamp() }),
    }, { merge: true });
    tx.set(mailRef, {
      amount: DAILY_GOLD_GRANT,
      dayKey: key,
      claimed: true,
      claimedAt: FieldValue.serverTimestamp(),
      createdAt: mailSnap.data()?.createdAt ?? FieldValue.serverTimestamp(),
    }, { merge: true });
    tx.set(ledgerRef, {
      currency: "gold",
      kind: "dailyGold",
      amount: DAILY_GOLD_GRANT,
      balanceAfter: next,
      createdAt: FieldValue.serverTimestamp(),
    });
    return { amount: DAILY_GOLD_GRANT, gold: next, dayKey: key };
  });
});

export const enterGoldWager = onCall(CALLABLE_OPTIONS, async (request) => {
  const uid = requireUid(request.auth?.uid);
  const wager = intValue(request.data?.wager);
  if (!isCompetitiveWager(wager)) {
    throw new HttpsError("invalid-argument", "Unsupported wager.");
  }

  const displayName = typeof request.data?.displayName === "string"
    ? request.data.displayName.trim().slice(0, 40)
    : "Player";
  const avatarId = typeof request.data?.avatarId === "string"
    ? request.data.avatarId.trim().slice(0, 80)
    : "default_01";

  const queue = db.collection("competitiveQueue");
  const matches = db.collection("competitiveMatches");
  const ticketRef = queue.doc(uid);
  const walletRef = walletRefFor(uid);
  const ledgerRef = walletRef.collection("goldTransactions").doc(`hold_${Date.now()}`);

  await db.runTransaction(async (tx) => {
    const [walletSnap, ticketSnap] = await Promise.all([tx.get(walletRef), tx.get(ticketRef)]);
    if (ticketSnap.exists) throw new HttpsError("already-exists", "Player already queued.");
    const gold = intValue(walletSnap.data()?.gold);
    const heldGold = intValue(walletSnap.data()?.heldGold);
    if (gold - heldGold < wager) throw new HttpsError("failed-precondition", "Not enough GOLD.");

    tx.set(walletRef, {
      uid,
      gold,
      heldGold: heldGold + wager,
      updatedAt: FieldValue.serverTimestamp(),
    }, { merge: true });
    tx.set(ticketRef, {
      uid,
      wager,
      displayName,
      avatarId,
      status: "searching",
      matchId: null,
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
      expiresAt: Timestamp.fromMillis(Date.now() + 120000),
    });
    tx.set(ledgerRef, {
      currency: "gold",
      kind: "wagerHold",
      amount: -wager,
      wager,
      createdAt: FieldValue.serverTimestamp(),
    });
  });

  const candidates = await queue
    .where("status", "==", "searching")
    .where("wager", "==", wager)
    .limit(20)
    .get();

  for (const candidate of candidates.docs) {
    if (candidate.id === uid) continue;
    const matchRef = matches.doc();

    try {
      const matchId = await db.runTransaction(async (tx) => {
        const [ownSnap, otherSnap] = await Promise.all([
          tx.get(ticketRef),
          tx.get(candidate.ref),
        ]);
        const own = ownSnap.data();
        const other = otherSnap.data();
        if (!own || !other) throw new Error("ticket_missing");
        if (own.status !== "searching" || other.status !== "searching") {
          throw new Error("ticket_claimed");
        }
        if (intValue(own.wager) !== wager || intValue(other.wager) !== wager) {
          throw new Error("wager_mismatch");
        }
        const otherUid = requireString(other.uid ?? candidate.id, "opponentUid");
        if (otherUid === uid) throw new Error("self_match");

        tx.create(matchRef, {
          playerAId: otherUid,
          playerAName: typeof other.displayName === "string" ? other.displayName : "Player",
          playerAAvatarId: typeof other.avatarId === "string" ? other.avatarId : "default_01",
          playerBId: uid,
          playerBName: displayName,
          playerBAvatarId: avatarId,
          wager,
          pot: wager * 2,
          status: "selectingGames",
          playerASelectedGames: [],
          playerBSelectedGames: [],
          readyA: false,
          readyB: false,
          seed: randomInt(0, 0x7fffffff),
          countdownStartedAt: null,
          startsAt: null,
          deadline: null,
          createdAt: FieldValue.serverTimestamp(),
          updatedAt: FieldValue.serverTimestamp(),
        });
        tx.update(ticketRef, {
          status: "matched",
          matchId: matchRef.id,
          updatedAt: FieldValue.serverTimestamp(),
        });
        tx.update(candidate.ref, {
          status: "matched",
          matchId: matchRef.id,
          updatedAt: FieldValue.serverTimestamp(),
        });
        return matchRef.id;
      });
      return { status: "matched", matchId, wager, pot: wager * 2 };
    } catch (error) {
      if (error instanceof HttpsError) throw error;
    }
  }

  return { status: "searching", matchId: null, wager, pot: wager * 2 };
});

export const leaveGoldWager = onCall(CALLABLE_OPTIONS, async (request) => {
  const uid = requireUid(request.auth?.uid);
  const ticketRef = db.collection("competitiveQueue").doc(uid);
  const walletRef = walletRefFor(uid);

  return db.runTransaction(async (tx) => {
    const [ticketSnap, walletSnap] = await Promise.all([tx.get(ticketRef), tx.get(walletRef)]);
    if (!ticketSnap.exists) return { released: 0 };
    const data = ticketSnap.data()!;
    if (data.status !== "searching") {
      throw new HttpsError("failed-precondition", "Matched wager cannot be cancelled here.");
    }
    const wager = intValue(data.wager);
    const held = intValue(walletSnap.data()?.heldGold);
    tx.set(walletRef, {
      heldGold: Math.max(0, held - wager),
      updatedAt: FieldValue.serverTimestamp(),
    }, { merge: true });
    tx.delete(ticketRef);
    return { released: wager };
  });
});

export const selectCompetitiveGames = onCall(CALLABLE_OPTIONS, async (request) => {
  const uid = requireUid(request.auth?.uid);
  const matchId = requireString(request.data?.matchId, "matchId");
  const gameIds = parseGameIds(request.data?.gameIds);
  const matchRef = db.collection("competitiveMatches").doc(matchId);

  await db.runTransaction(async (tx) => {
    const snap = await tx.get(matchRef);
    const data = snap.data();
    if (!data) throw new HttpsError("not-found", "Match not found.");
    if (data.status !== "selectingGames" && data.status !== "waitingReady") {
      throw new HttpsError("failed-precondition", "Game selection is closed.");
    }
    const playerAId = requireString(data.playerAId, "playerAId");
    const playerBId = requireString(data.playerBId, "playerBId");
    if (uid !== playerAId && uid !== playerBId) {
      throw new HttpsError("permission-denied", "Not a participant.");
    }
    const field = uid === playerAId ? "playerASelectedGames" : "playerBSelectedGames";
    tx.update(matchRef, {
      [field]: gameIds,
      readyA: uid === playerAId ? false : data.readyA === true,
      readyB: uid === playerBId ? false : data.readyB === true,
      status: "waitingReady",
      updatedAt: FieldValue.serverTimestamp(),
    });
  });

  return { ok: true };
});

export const markCompetitiveReady = onCall(CALLABLE_OPTIONS, async (request) => {
  const uid = requireUid(request.auth?.uid);
  const matchId = requireString(request.data?.matchId, "matchId");
  const matchRef = db.collection("competitiveMatches").doc(matchId);

  return db.runTransaction(async (tx) => {
    const snap = await tx.get(matchRef);
    const data = snap.data();
    if (!data) throw new HttpsError("not-found", "Match not found.");
    if (data.status !== "waitingReady") {
      throw new HttpsError("failed-precondition", "Match is not waiting for Ready.");
    }
    const playerAId = requireString(data.playerAId, "playerAId");
    const playerBId = requireString(data.playerBId, "playerBId");
    if (uid !== playerAId && uid !== playerBId) {
      throw new HttpsError("permission-denied", "Not a participant.");
    }
    const picksA = Array.isArray(data.playerASelectedGames) ? data.playerASelectedGames : [];
    const picksB = Array.isArray(data.playerBSelectedGames) ? data.playerBSelectedGames : [];
    if (picksA.length !== COMPETITIVE_PICKS_PER_PLAYER || picksB.length !== COMPETITIVE_PICKS_PER_PLAYER) {
      throw new HttpsError("failed-precondition", "Both players must select two games first.");
    }

    const readyA = uid === playerAId ? true : data.readyA === true;
    const readyB = uid === playerBId ? true : data.readyB === true;
    const update: Record<string, unknown> = {
      readyA,
      readyB,
      updatedAt: FieldValue.serverTimestamp(),
    };

    if (readyA && readyB) {
      const now = Date.now();
      const startsAt = Timestamp.fromMillis(now + 3000);
      update.status = "countdown";
      update.countdownStartedAt = FieldValue.serverTimestamp();
      update.startsAt = startsAt;
      update.deadline = Timestamp.fromMillis(startsAt.toMillis() + COMPETITIVE_DURATION_MS);
      update.gameOrder = [...picksA, ...picksB];
    }

    tx.update(matchRef, update);
    return {
      status: readyA && readyB ? "countdown" : "waitingReady",
      bothReady: readyA && readyB,
    };
  });
});
