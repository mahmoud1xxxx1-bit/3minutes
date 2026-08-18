import { randomUUID } from "node:crypto";

import { FieldValue, getFirestore } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";

import { cosmeticById } from "./catalog.js";
import { COLLECTIONS, intValue } from "./firestore.js";
import { tierFor, type RankTier } from "./policy.js";

const CALLABLE_OPTIONS = {
  region: "me-central2",
  enforceAppCheck: true,
  timeoutSeconds: 30,
} as const;

const RANK_TIERS: readonly RankTier[] = [
  "bronze",
  "silver",
  "gold",
  "platinum",
  "diamond",
  "master",
  "grandmaster",
  "legend",
];

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

function requireRankTier(value: unknown): RankTier {
  if (typeof value !== "string" || !RANK_TIERS.includes(value as RankTier)) {
    throw new HttpsError("invalid-argument", "A valid rankTier is required.");
  }
  return value as RankTier;
}

function storedPeakTier(value: unknown, rankPoints: number): RankTier {
  return typeof value === "string" && RANK_TIERS.includes(value as RankTier)
    ? (value as RankTier)
    : tierFor(Math.max(0, rankPoints));
}

// Historical rank emblems are earned through Ranked play, never purchased.
// The server verifies the requested showcase tier is no higher than the
// lifetime peak tier written by ranked settlement authority. Existing players
// created before peakRankTier existed fall back to their current server RP.
export const selectRankShowcase = onCall(CALLABLE_OPTIONS, async (request) => {
  const uid = requireUid(request.auth?.uid);
  const requestedTier = requireRankTier(request.data?.rankTier);
  const db = getFirestore();
  const userRef = db.collection(COLLECTIONS.users).doc(uid);
  const userSnap = await userRef.get();
  const user = userSnap.data();
  if (!user) {
    throw new HttpsError("failed-precondition", "Player profile does not exist.");
  }

  const peakTier = storedPeakTier(user.peakRankTier, intValue(user.rankPoints));
  if (RANK_TIERS.indexOf(requestedTier) > RANK_TIERS.indexOf(peakTier)) {
    throw new HttpsError(
      "failed-precondition",
      "This rank emblem has not been earned yet.",
    );
  }

  await userRef.update({
    peakRankTier: peakTier,
    showcaseRankTier: requestedTier,
    updatedAt: FieldValue.serverTimestamp(),
  });

  return { rankTier: requestedTier, peakRankTier: peakTier };
});

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
