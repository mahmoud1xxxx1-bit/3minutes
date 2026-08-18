import { randomUUID } from "node:crypto";

import { FieldValue, getFirestore } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";

import { cosmeticById } from "./catalog.js";
import { COLLECTIONS, intValue } from "./firestore.js";

const CALLABLE_OPTIONS = {
  region: "me-central2",
  enforceAppCheck: true,
  timeoutSeconds: 30,
} as const;

function requireUid(uid: string | undefined): string {
  if (!uid) throw new HttpsError("unauthenticated", "Sign-in is required.");
  return uid;
}

function requireCosmeticId(value: unknown): string {
  if (typeof value !== "string" || value.trim().length === 0) {
    throw new HttpsError("invalid-argument", "cosmeticId is required.");
  }
  return value.trim();
}

// Prestige Stars are permanent account history. Unlocking a prestige cosmetic
// checks the lifetime star threshold but never subtracts stars.
export const unlockPrestigeCosmetic = onCall(CALLABLE_OPTIONS, async (request) => {
  const uid = requireUid(request.auth?.uid);
  const cosmeticId = requireCosmeticId(request.data?.cosmeticId);
  const cosmetic = cosmeticById(cosmeticId);
  if (!cosmetic || cosmetic.priceType !== "prestigeStars") {
    throw new HttpsError("failed-precondition", "This is not a prestige cosmetic.");
  }

  const db = getFirestore();
  const userRef = db.collection(COLLECTIONS.users).doc(uid);
  const inventoryRef = db.collection(COLLECTIONS.inventories).doc(uid);
  const receiptId = randomUUID();
  const receiptRef = db.collection(COLLECTIONS.purchaseReceipts).doc(receiptId);

  return db.runTransaction(async (transaction) => {
    const [userSnap, inventorySnap] = await Promise.all([
      transaction.get(userRef),
      transaction.get(inventoryRef),
    ]);
    const user = userSnap.data();
    if (!user) throw new HttpsError("failed-precondition", "Player profile does not exist.");

    const lifetimeStars = Math.max(0, intValue(user.stars));
    if (lifetimeStars < cosmetic.starPrice) {
      throw new HttpsError(
        "failed-precondition",
        `Requires ${cosmetic.starPrice} permanent prestige stars.`,
      );
    }

    const inventory = inventorySnap.data() ?? {};
    const owned = Array.isArray(inventory.ownedCosmeticIds)
      ? inventory.ownedCosmeticIds.filter(
          (value): value is string => typeof value === "string",
        )
      : [];
    if (owned.includes(cosmeticId)) {
      return {
        cosmeticId,
        requiredStars: cosmetic.starPrice,
        lifetimeStars,
        alreadyOwned: true,
      };
    }

    transaction.set(
      inventoryRef,
      {
        ownedCosmeticIds: [...owned, cosmeticId],
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
    transaction.create(receiptRef, {
      receiptId,
      uid,
      cosmeticId,
      unlockType: "prestigeThreshold",
      requiredStars: cosmetic.starPrice,
      lifetimeStarsAtUnlock: lifetimeStars,
      starsSpent: 0,
      createdAt: FieldValue.serverTimestamp(),
    });

    return {
      cosmeticId,
      requiredStars: cosmetic.starPrice,
      lifetimeStars,
      alreadyOwned: false,
    };
  });
});
