import { FieldValue, getFirestore } from "firebase-admin/firestore";
import { onDocumentWritten } from "firebase-functions/v2/firestore";

const REGION = "me-central2";
const db = getFirestore();

function intValue(value: unknown): number {
  return Number.isFinite(Number(value)) ? Math.trunc(Number(value)) : 0;
}

function identity(data: Record<string, unknown> | undefined) {
  return {
    displayName:
      typeof data?.gameName === "string" && data.gameName.trim().length > 0
        ? data.gameName.trim()
        : "Player",
    avatarId:
      typeof data?.avatarId === "string" && data.avatarId.trim().length > 0
        ? data.avatarId.trim()
        : "default_01",
  };
}

export const syncGoldLeaderboard = onDocumentWritten(
  { region: REGION, document: "competitiveWallets/{uid}" },
  async (event) => {
    const uid = event.params.uid;
    const wallet = event.data?.after.data();
    const entryRef = db
      .collection("competitiveLeaderboards")
      .doc("gold")
      .collection("entries")
      .doc(uid);

    if (!wallet) {
      await entryRef.delete();
      return;
    }

    const profile = (await db.collection("users").doc(uid).get()).data();
    await entryRef.set(
      {
        uid,
        ...identity(profile),
        value: intValue(wallet.gold),
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
  },
);

export const syncRpLeaderboard = onDocumentWritten(
  { region: REGION, document: "users/{uid}" },
  async (event) => {
    const uid = event.params.uid;
    const profile = event.data?.after.data();
    const entryRef = db
      .collection("competitiveLeaderboards")
      .doc("rp")
      .collection("entries")
      .doc(uid);

    if (!profile) {
      await entryRef.delete();
      return;
    }

    await entryRef.set(
      {
        uid,
        ...identity(profile),
        value: intValue(profile.rankPoints),
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
  },
);
