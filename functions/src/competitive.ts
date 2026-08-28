import { onCall, HttpsError } from "firebase-functions/v2/https";
import { getFirestore, FieldValue, Timestamp } from "firebase-admin/firestore";

const WAGERS = new Set([180, 500, 1000]);
const DAILY_GOLD = 1000;
const db = getFirestore();

function requireUid(request: { auth?: { uid: string } | null }): string {
  const uid = request.auth?.uid;
  if (!uid) throw new HttpsError("unauthenticated", "Authentication required.");
  return uid;
}

function dayKey(now = new Date()): string {
  return now.toISOString().slice(0, 10);
}

export const claimDailyGold = onCall(async (request) => {
  const uid = requireUid(request);
  const key = dayKey();
  const playerRef = db.collection("players").doc(uid);
  const mailRef = playerRef.collection("dailyGoldMail").doc(key);
  const ledgerRef = playerRef.collection("goldTransactions").doc(`daily_${key}`);

  return db.runTransaction(async (tx) => {
    const [playerSnap, mailSnap] = await Promise.all([tx.get(playerRef), tx.get(mailRef)]);
    if (mailSnap.exists && mailSnap.data()?.claimed === true) {
      throw new HttpsError("already-exists", "Daily GOLD already claimed.");
    }
    const current = Number(playerSnap.data()?.gold ?? 0);
    const next = current + DAILY_GOLD;
    tx.set(playerRef, { gold: next, updatedAt: FieldValue.serverTimestamp() }, { merge: true });
    tx.set(mailRef, {
      amount: DAILY_GOLD,
      dayKey: key,
      claimed: true,
      claimedAt: FieldValue.serverTimestamp(),
      createdAt: mailSnap.data()?.createdAt ?? FieldValue.serverTimestamp(),
    }, { merge: true });
    tx.set(ledgerRef, {
      currency: "gold",
      kind: "dailyGold",
      amount: DAILY_GOLD,
      balanceAfter: next,
      createdAt: FieldValue.serverTimestamp(),
    });
    return { amount: DAILY_GOLD, gold: next, dayKey: key };
  });
});

export const enterGoldWager = onCall(async (request) => {
  const uid = requireUid(request);
  const wager = Math.trunc(Number(request.data?.wager));
  if (!WAGERS.has(wager)) throw new HttpsError("invalid-argument", "Unsupported wager.");

  const ticketRef = db.collection("competitiveQueue").doc(uid);
  const playerRef = db.collection("players").doc(uid);
  const ledgerRef = playerRef.collection("goldTransactions").doc(`hold_${Date.now()}`);

  return db.runTransaction(async (tx) => {
    const [playerSnap, ticketSnap] = await Promise.all([tx.get(playerRef), tx.get(ticketRef)]);
    if (ticketSnap.exists) throw new HttpsError("already-exists", "Player already queued.");
    const gold = Math.trunc(Number(playerSnap.data()?.gold ?? 0));
    const heldGold = Math.trunc(Number(playerSnap.data()?.heldGold ?? 0));
    if (gold - heldGold < wager) throw new HttpsError("failed-precondition", "Not enough GOLD.");
    tx.set(playerRef, { heldGold: heldGold + wager, updatedAt: FieldValue.serverTimestamp() }, { merge: true });
    tx.set(ticketRef, {
      uid,
      wager,
      status: "searching",
      createdAt: FieldValue.serverTimestamp(),
      expiresAt: Timestamp.fromMillis(Date.now() + 120000),
    });
    tx.set(ledgerRef, {
      currency: "gold",
      kind: "wagerHold",
      amount: -wager,
      wager,
      createdAt: FieldValue.serverTimestamp(),
    });
    return { wager, pot: wager * 2 };
  });
});

export const leaveGoldWager = onCall(async (request) => {
  const uid = requireUid(request);
  const ticketRef = db.collection("competitiveQueue").doc(uid);
  const playerRef = db.collection("players").doc(uid);

  return db.runTransaction(async (tx) => {
    const [ticketSnap, playerSnap] = await Promise.all([tx.get(ticketRef), tx.get(playerRef)]);
    if (!ticketSnap.exists) return { released: 0 };
    const data = ticketSnap.data()!;
    if (data.status !== "searching") throw new HttpsError("failed-precondition", "Matched wager cannot be cancelled here.");
    const wager = Math.trunc(Number(data.wager ?? 0));
    const held = Math.trunc(Number(playerSnap.data()?.heldGold ?? 0));
    tx.set(playerRef, { heldGold: Math.max(0, held - wager), updatedAt: FieldValue.serverTimestamp() }, { merge: true });
    tx.delete(ticketRef);
    return { released: wager };
  });
});
