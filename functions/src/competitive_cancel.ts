import { FieldValue, getFirestore } from "firebase-admin/firestore";
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

function requireMatchId(value: unknown): string {
  if (typeof value !== "string" || value.trim().length === 0) {
    throw new HttpsError("invalid-argument", "matchId is required.");
  }
  return value.trim();
}

function intValue(value: unknown): number {
  return Number.isFinite(Number(value)) ? Math.trunc(Number(value)) : 0;
}

export const cancelCompetitiveMatch = onCall(CALLABLE_OPTIONS, async (request) => {
  const callerUid = requireUid(request.auth?.uid);
  const matchId = requireMatchId(request.data?.matchId);
  const db = getFirestore();
  const matchRef = db.collection("competitiveMatches").doc(matchId);
  const cancellationRef = db.collection("competitiveCancellations").doc(matchId);

  return db.runTransaction(async (tx) => {
    const [matchSnap, cancellationSnap] = await Promise.all([
      tx.get(matchRef),
      tx.get(cancellationRef),
    ]);
    const match = matchSnap.data();
    if (!match) throw new HttpsError("not-found", "Match not found.");
    if (cancellationSnap.exists) {
      return cancellationSnap.data()?.payload ?? { matchId, cancelled: true };
    }

    const playerAId = String(match.playerAId ?? "");
    const playerBId = String(match.playerBId ?? "");
    if (callerUid !== playerAId && callerUid !== playerBId) {
      throw new HttpsError("permission-denied", "Not a participant.");
    }
    if (match.status !== "selectingGames" && match.status !== "waitingReady") {
      throw new HttpsError(
        "failed-precondition",
        "Only a match that has not started can be cancelled without forfeiting.",
      );
    }

    const wager = intValue(match.wager);
    const walletARef = db.collection("competitiveWallets").doc(playerAId);
    const walletBRef = db.collection("competitiveWallets").doc(playerBId);
    const ticketARef = db.collection("competitiveQueue").doc(playerAId);
    const ticketBRef = db.collection("competitiveQueue").doc(playerBId);
    const [walletASnap, walletBSnap] = await Promise.all([
      tx.get(walletARef),
      tx.get(walletBRef),
    ]);
    const heldA = intValue(walletASnap.data()?.heldGold);
    const heldB = intValue(walletBSnap.data()?.heldGold);

    tx.set(walletARef, {
      heldGold: Math.max(0, heldA - wager),
      updatedAt: FieldValue.serverTimestamp(),
    }, { merge: true });
    tx.set(walletBRef, {
      heldGold: Math.max(0, heldB - wager),
      updatedAt: FieldValue.serverTimestamp(),
    }, { merge: true });

    tx.set(walletARef.collection("goldTransactions").doc(`cancel_${matchId}`), {
      matchId,
      currency: "gold",
      kind: "wagerRelease",
      amount: 0,
      releasedHold: wager,
      createdAt: FieldValue.serverTimestamp(),
    });
    tx.set(walletBRef.collection("goldTransactions").doc(`cancel_${matchId}`), {
      matchId,
      currency: "gold",
      kind: "wagerRelease",
      amount: 0,
      releasedHold: wager,
      createdAt: FieldValue.serverTimestamp(),
    });

    tx.delete(ticketARef);
    tx.delete(ticketBRef);

    const payload = {
      matchId,
      cancelled: true,
      cancelledBy: callerUid,
      releasedA: Math.min(heldA, wager),
      releasedB: Math.min(heldB, wager),
    };
    tx.create(cancellationRef, {
      matchId,
      payload,
      createdAt: FieldValue.serverTimestamp(),
    });
    tx.update(matchRef, {
      status: "cancelled",
      cancelledBy: callerUid,
      cancelledAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });
    return payload;
  });
});
