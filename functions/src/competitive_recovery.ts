import { FieldValue, getFirestore, Timestamp } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";

const CALLABLE_OPTIONS = {
  region: "me-central2",
  enforceAppCheck: true,
  timeoutSeconds: 30,
} as const;

function requireUid(uid: string | undefined): string {
  if (!uid) throw new HttpsError("unauthenticated", "Sign-in is required.");
  return uid;
}

function intValue(value: unknown): number {
  return Number.isFinite(Number(value)) ? Math.trunc(Number(value)) : 0;
}

export const recoverCompetitiveQueue = onCall(CALLABLE_OPTIONS, async (request) => {
  const uid = requireUid(request.auth?.uid);
  const db = getFirestore();
  const ticketRef = db.collection("competitiveQueue").doc(uid);
  const walletRef = db.collection("competitiveWallets").doc(uid);

  return db.runTransaction(async (tx) => {
    const [ticketSnap, walletSnap] = await Promise.all([
      tx.get(ticketRef),
      tx.get(walletRef),
    ]);
    if (!ticketSnap.exists) return { status: "none", released: 0, matchId: null };

    const ticket = ticketSnap.data()!;
    const status = typeof ticket.status === "string" ? ticket.status : "unknown";
    const matchId = typeof ticket.matchId === "string" ? ticket.matchId : null;

    if (status === "searching") {
      const expiry = ticket.expiresAt;
      const expired = expiry instanceof Timestamp && expiry.toMillis() <= Date.now();
      if (!expired) {
        return { status: "searching", released: 0, matchId: null };
      }

      const wager = intValue(ticket.wager);
      const held = intValue(walletSnap.data()?.heldGold);
      const released = Math.min(held, wager);
      tx.set(walletRef, {
        heldGold: Math.max(0, held - wager),
        updatedAt: FieldValue.serverTimestamp(),
      }, { merge: true });
      tx.set(walletRef.collection("goldTransactions").doc(`expired_${ticketSnap.id}_${Date.now()}`), {
        currency: "gold",
        kind: "wagerRelease",
        amount: 0,
        releasedHold: released,
        reason: "queueExpired",
        createdAt: FieldValue.serverTimestamp(),
      });
      tx.delete(ticketRef);
      return { status: "expired", released, matchId: null };
    }

    if (status === "matched" && matchId != null) {
      return {
        status: "matched",
        released: 0,
        matchId,
        wager: intValue(ticket.wager),
      };
    }

    tx.delete(ticketRef);
    return { status: "cleaned", released: 0, matchId: null };
  });
});
