import { randomUUID } from "node:crypto";

import { FieldValue, Timestamp, getFirestore } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";

import { cosmeticById, equippedField } from "./catalog.js";
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

export const purchaseCosmetic = onCall(CALLABLE_OPTIONS, async (request) => {
  const uid = requireUid(request.auth?.uid);
  const cosmeticId = requireCosmeticId(request.data?.cosmeticId);
  const cosmetic = cosmeticById(cosmeticId);
  if (!cosmetic) throw new HttpsError("not-found", "Unknown cosmetic.");
  if (cosmetic.priceType !== "coins") {
    throw new HttpsError(
      "failed-precondition",
      "This cosmetic cannot be purchased with the coin purchase flow.",
    );
  }

  const db = getFirestore();
  const inventoryRef = db.collection(COLLECTIONS.inventories).doc(uid);
  const transactionId = randomUUID();
  const ledgerRef = db.collection(COLLECTIONS.coinTransactions).doc(transactionId);
  const purchasedAt = new Date();

  return db.runTransaction(async (transaction) => {
    const snapshot = await transaction.get(inventoryRef);
    const inventory = snapshot.data() ?? {};
    const coins = Math.max(0, intValue(inventory.coins));
    const owned = Array.isArray(inventory.ownedCosmeticIds)
      ? inventory.ownedCosmeticIds.filter(
          (value): value is string => typeof value === "string",
        )
      : [];

    if (owned.includes(cosmeticId)) {
      throw new HttpsError("already-exists", "Cosmetic is already owned.");
    }
    if (coins < cosmetic.coinPrice) {
      throw new HttpsError("failed-precondition", "Insufficient coins.");
    }

    const remainingCoins = coins - cosmetic.coinPrice;
    const nextOwned = [...owned, cosmeticId];
    transaction.set(
      inventoryRef,
      {
        coins: remainingCoins,
        ownedCosmeticIds: nextOwned,
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
    transaction.create(ledgerRef, {
      transactionId,
      uid,
      cosmeticId,
      reason: "purchase",
      amount: -cosmetic.coinPrice,
      balanceAfter: remainingCoins,
      createdAt: Timestamp.fromDate(purchasedAt),
    });

    return {
      transactionId,
      uid,
      cosmeticId,
      coinPrice: cosmetic.coinPrice,
      remainingCoins,
      purchasedAt: purchasedAt.toISOString(),
    };
  });
});

export const equipCosmetic = onCall(CALLABLE_OPTIONS, async (request) => {
  const uid = requireUid(request.auth?.uid);
  const cosmeticId = requireCosmeticId(request.data?.cosmeticId);
  const cosmetic = cosmeticById(cosmeticId);
  if (!cosmetic) throw new HttpsError("not-found", "Unknown cosmetic.");

  const db = getFirestore();
  const inventoryRef = db.collection(COLLECTIONS.inventories).doc(uid);
  const userRef = db.collection(COLLECTIONS.users).doc(uid);

  return db.runTransaction(async (transaction) => {
    const [inventorySnap, userSnap] = await Promise.all([
      transaction.get(inventoryRef),
      transaction.get(userRef),
    ]);
    if (!userSnap.exists) {
      throw new HttpsError("failed-precondition", "Player profile does not exist.");
    }

    const inventory = inventorySnap.data() ?? {};
    const owned = Array.isArray(inventory.ownedCosmeticIds)
      ? inventory.ownedCosmeticIds.filter(
          (value): value is string => typeof value === "string",
        )
      : [];

    const alreadyOwned = owned.includes(cosmeticId);
    const mayClaimForFree = cosmetic.priceType === "free";
    if (!alreadyOwned && !mayClaimForFree) {
      throw new HttpsError("permission-denied", "Cosmetic is not owned.");
    }

    const nextOwned = alreadyOwned ? owned : [...owned, cosmeticId];
    const field = equippedField(cosmetic.slot);
    transaction.set(
      inventoryRef,
      {
        ownedCosmeticIds: nextOwned,
        [field]: cosmeticId,
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );

    // Public loadout is a display-only mirror written exclusively by server
    // authority after ownership verification. Clients can read it to render
    // cosmetics in profiles, rooms and matches, but Firestore rules prevent
    // them from writing or forging it directly.
    transaction.update(userRef, {
      [`cosmeticLoadout.${field}`]: cosmeticId,
      ...(cosmetic.slot === "avatar" ? { avatarId: cosmeticId } : {}),
      updatedAt: FieldValue.serverTimestamp(),
    });

    return {
      coins: Math.max(0, intValue(inventory.coins)),
      ownedCosmeticIds: nextOwned,
      equippedField: field,
      cosmeticId,
      grantedFree: !alreadyOwned && mayClaimForFree,
    };
  });
});
