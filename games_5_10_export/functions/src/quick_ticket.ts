import { getFirestore } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";

import { COLLECTIONS, stringValue } from "./firestore.js";

const OPTIONS = {
  region: "me-central2",
  enforceAppCheck: true,
  timeoutSeconds: 15,
} as const;

export const getQuickTicket = onCall(OPTIONS, async (request) => {
  const uid = request.auth?.uid;
  if (!uid) throw new HttpsError("unauthenticated", "Sign-in is required.");

  const snapshot = await getFirestore()
    .collection(COLLECTIONS.quickMatchmaking)
    .doc(uid)
    .get();
  if (!snapshot.exists) return { exists: false };

  const data = snapshot.data() ?? {};
  const status = stringValue(data.status);
  if (status !== "waiting" && status !== "matched") {
    return { exists: false };
  }
  const matchId = status === "matched" ? stringValue(data.matchId) : "";
  return {
    exists: true,
    status,
    matchId: matchId || null,
  };
});
