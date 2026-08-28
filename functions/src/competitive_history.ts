import { getFirestore, Timestamp } from "firebase-admin/firestore";
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

export const getCompetitiveMatchHistory = onCall(CALLABLE_OPTIONS, async (request) => {
  const uid = requireUid(request.auth?.uid);
  const requestedLimit = intValue(request.data?.limit);
  const limit = Math.min(50, Math.max(1, requestedLimit || 20));
  const db = getFirestore();

  const snapshot = await db
    .collection("competitiveMatchHistory")
    .doc(uid)
    .collection("matches")
    .orderBy("completedAt", "desc")
    .limit(limit)
    .get();

  return {
    matches: snapshot.docs.map((doc) => {
      const data = doc.data();
      const completedAt = data.completedAt;
      return {
        matchId: doc.id,
        result: typeof data.result === "string" ? data.result : "tie",
        opponentUid: typeof data.opponentUid === "string" ? data.opponentUid : "",
        opponentName: typeof data.opponentName === "string" ? data.opponentName : "Player",
        opponentAvatarId: typeof data.opponentAvatarId === "string" ? data.opponentAvatarId : "default_01",
        wager: intValue(data.wager),
        pot: intValue(data.pot),
        goldDelta: intValue(data.goldDelta),
        coinsDelta: intValue(data.coinsDelta),
        rpDelta: intValue(data.rpDelta),
        myTotalScore: intValue(data.myTotalScore),
        opponentTotalScore: intValue(data.opponentTotalScore),
        gameOrder: Array.isArray(data.gameOrder)
          ? data.gameOrder.filter((value): value is string => typeof value === "string")
          : [],
        gameResults: Array.isArray(data.gameResults) ? data.gameResults : [],
        completedAtMs: completedAt instanceof Timestamp ? completedAt.toMillis() : null,
      };
    }),
  };
});
