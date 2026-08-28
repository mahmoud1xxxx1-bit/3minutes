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

function requireMatchId(value: unknown): string {
  if (typeof value !== "string" || value.trim().length === 0) {
    throw new HttpsError("invalid-argument", "matchId is required.");
  }
  return value.trim();
}

export const forfeitCompetitiveMatch = onCall(CALLABLE_OPTIONS, async (request) => {
  const uid = requireUid(request.auth?.uid);
  const matchId = requireMatchId(request.data?.matchId);
  const db = getFirestore();
  const matchRef = db.collection("competitiveMatches").doc(matchId);

  return db.runTransaction(async (tx) => {
    const snap = await tx.get(matchRef);
    const match = snap.data();
    if (!match) throw new HttpsError("not-found", "Match not found.");

    const playerAId = String(match.playerAId ?? "");
    const playerBId = String(match.playerBId ?? "");
    if (uid !== playerAId && uid !== playerBId) {
      throw new HttpsError("permission-denied", "Not a participant.");
    }

    if (match.status === "awaitingSettlement" || match.status === "finished") {
      return {
        status: match.status,
        outcome: match.outcome ?? null,
        endReason: match.endReason ?? null,
      };
    }

    if (match.status !== "countdown" && match.status !== "playing") {
      throw new HttpsError("failed-precondition", "The match has not started.");
    }

    const startsAt = match.startsAt;
    if (!(startsAt instanceof Timestamp) || startsAt.toMillis() > Date.now()) {
      throw new HttpsError("failed-precondition", "Countdown is still active.");
    }

    const outcome = uid === playerAId ? "playerB" : "playerA";
    tx.update(matchRef, {
      status: "awaitingSettlement",
      outcome,
      endReason: "surrender",
      forfeitedBy: uid,
      endedAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });

    return { status: "awaitingSettlement", outcome, endReason: "surrender" };
  });
});
