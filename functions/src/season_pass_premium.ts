import { createHash } from "node:crypto";

import { FieldValue, Timestamp, getFirestore } from "firebase-admin/firestore";
import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import { GoogleAuth } from "google-auth-library";

import { COLLECTIONS, intValue, stringValue } from "./firestore.js";

export const PREMIUM_SEASON_PASS_PRODUCT_ID = "premium_season_pass_30d";
export const PREMIUM_SEASON_PASS_BASE_PLAN_ID = "prepaid-30d";
export const PREMIUM_SEASON_PASS_USD = 30;
export const PREMIUM_SEASON_PASS_STAR_LEVELS = [6, 12, 18, 24, 30] as const;

const PACKAGE_NAME = "com.threeminutes.game";
const ANDROID_PUBLISHER_SCOPE = "https://www.googleapis.com/auth/androidpublisher";
const CALLABLE_OPTIONS = {
  region: "me-central2",
  enforceAppCheck: true,
  timeoutSeconds: 60,
} as const;

export function premiumSeasonPassStarsForLevel(level: number): number {
  return PREMIUM_SEASON_PASS_STAR_LEVELS.includes(
    Math.trunc(level) as (typeof PREMIUM_SEASON_PASS_STAR_LEVELS)[number],
  )
    ? 1
    : 0;
}

function requireUid(uid: string | undefined): string {
  if (!uid) throw new HttpsError("unauthenticated", "Sign-in is required.");
  return uid;
}

function requireString(value: unknown, name: string): string {
  if (typeof value !== "string" || value.trim().length === 0) {
    throw new HttpsError("invalid-argument", `${name} is required.`);
  }
  return value.trim();
}

function tokenReceiptId(token: string): string {
  return `seasonpass_${createHash("sha256").update(token).digest("hex")}`;
}

type SubscriptionLineItem = {
  productId?: string;
  expiryTime?: string;
  prepaidPlan?: { allowExtendAfterTime?: string };
  offerDetails?: { basePlanId?: string; offerId?: string };
};

type SubscriptionPurchaseV2 = {
  subscriptionState?: string;
  acknowledgementState?: string;
  latestOrderId?: string;
  regionCode?: string;
  startTime?: string;
  lineItems?: SubscriptionLineItem[];
};

async function playClient() {
  const auth = new GoogleAuth({ scopes: [ANDROID_PUBLISHER_SCOPE] });
  return auth.getClient();
}

async function verifySubscription(token: string): Promise<SubscriptionPurchaseV2> {
  const client = await playClient();
  const encodedToken = encodeURIComponent(token);
  const url = `https://androidpublisher.googleapis.com/androidpublisher/v3/applications/${PACKAGE_NAME}/purchases/subscriptionsv2/tokens/${encodedToken}`;
  const response = await client.request<SubscriptionPurchaseV2>({ url, method: "GET" });
  return response.data;
}

async function acknowledgeSubscription(token: string): Promise<void> {
  const client = await playClient();
  const productId = encodeURIComponent(PREMIUM_SEASON_PASS_PRODUCT_ID);
  const purchaseToken = encodeURIComponent(token);
  const url = `https://androidpublisher.googleapis.com/androidpublisher/v3/applications/${PACKAGE_NAME}/purchases/subscriptions/${productId}/tokens/${purchaseToken}:acknowledge`;
  await client.request({ url, method: "POST", data: {} });
}

export const verifyPremiumSeasonPass = onCall(CALLABLE_OPTIONS, async (request) => {
  const uid = requireUid(request.auth?.uid);
  const seasonId = requireString(request.data?.seasonId, "seasonId");
  const productId = requireString(request.data?.productId, "productId");
  const purchaseToken = requireString(request.data?.purchaseToken, "purchaseToken");
  if (productId !== PREMIUM_SEASON_PASS_PRODUCT_ID) {
    throw new HttpsError("invalid-argument", "Unexpected Premium Season Pass product.");
  }

  let verified: SubscriptionPurchaseV2;
  try {
    verified = await verifySubscription(purchaseToken);
  } catch (error) {
    console.error("Premium Season Pass verification failed", error);
    throw new HttpsError("failed-precondition", "Google Play could not verify this subscription.");
  }

  if (verified.subscriptionState !== "SUBSCRIPTION_STATE_ACTIVE") {
    throw new HttpsError("failed-precondition", "Premium Season Pass subscription is not active.");
  }

  const now = new Date();
  const lineItem = (verified.lineItems ?? []).find((item) =>
    item.productId === PREMIUM_SEASON_PASS_PRODUCT_ID &&
    item.prepaidPlan !== undefined &&
    item.offerDetails?.basePlanId === PREMIUM_SEASON_PASS_BASE_PLAN_ID,
  );
  if (!lineItem?.expiryTime) {
    throw new HttpsError("permission-denied", "Verified purchase is not the approved 30-day prepaid plan.");
  }
  const expiry = new Date(lineItem.expiryTime);
  if (!Number.isFinite(expiry.getTime()) || expiry.getTime() <= now.getTime()) {
    throw new HttpsError("failed-precondition", "Premium Season Pass entitlement has expired.");
  }

  const db = getFirestore();
  const seasonRef = db.collection(COLLECTIONS.seasons).doc(seasonId);
  const passRef = db.collection(COLLECTIONS.seasonPass).doc(uid);
  const receiptRef = db.collection(COLLECTIONS.purchaseReceipts).doc(tokenReceiptId(purchaseToken));

  await db.runTransaction(async (transaction) => {
    const [seasonSnap, passSnap, receiptSnap] = await Promise.all([
      transaction.get(seasonRef),
      transaction.get(passRef),
      transaction.get(receiptRef),
    ]);
    const season = seasonSnap.data();
    if (!seasonSnap.exists || season?.active !== true) {
      throw new HttpsError("failed-precondition", "Season is not active.");
    }
    const startsAt = season?.startsAt instanceof Timestamp ? season.startsAt.toMillis() : null;
    const endsAt = season?.endsAt instanceof Timestamp ? season.endsAt.toMillis() : null;
    if (startsAt === null || endsAt === null || now.getTime() < startsAt || now.getTime() >= endsAt) {
      throw new HttpsError("failed-precondition", "Premium Season Pass can only unlock the live season.");
    }

    if (receiptSnap.exists) {
      const receipt = receiptSnap.data() ?? {};
      if (receipt.uid !== uid || receipt.productId !== PREMIUM_SEASON_PASS_PRODUCT_ID) {
        throw new HttpsError(
          "permission-denied",
          "This Google Play subscription token belongs to another entitlement.",
        );
      }
    }

    const pass = passSnap.data() ?? {};
    const sameSeason = stringValue(pass.seasonId) === seasonId;
    const seasonXp = sameSeason ? Math.max(0, intValue(pass.seasonXp)) : 0;
    const claimedFreeLevels = sameSeason && Array.isArray(pass.claimedFreeLevels)
      ? pass.claimedFreeLevels
      : [];
    const claimedPremiumLevels = sameSeason && Array.isArray(pass.claimedPremiumLevels)
      ? pass.claimedPremiumLevels
      : [];

    transaction.set(
      passRef,
      {
        seasonId,
        seasonXp,
        claimedFreeLevels,
        claimedPremiumLevels,
        premiumUnlocked: true,
        premiumProductId: PREMIUM_SEASON_PASS_PRODUCT_ID,
        premiumBasePlanId: PREMIUM_SEASON_PASS_BASE_PLAN_ID,
        premiumVerifiedAt: FieldValue.serverTimestamp(),
        premiumSubscriptionExpiryAt: Timestamp.fromDate(expiry),
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );

    transaction.set(
      receiptRef,
      {
        receiptId: receiptRef.id,
        uid,
        productId: PREMIUM_SEASON_PASS_PRODUCT_ID,
        basePlanId: PREMIUM_SEASON_PASS_BASE_PLAN_ID,
        platform: "googlePlaySubscription",
        latestOrderId: verified.latestOrderId ?? null,
        regionCode: verified.regionCode ?? null,
        startTime: verified.startTime ?? null,
        expiryTime: lineItem.expiryTime,
        subscriptionState: verified.subscriptionState,
        googleAcknowledgementState: verified.acknowledgementState ?? null,
        seasonIdsUnlocked: FieldValue.arrayUnion(seasonId),
        verifiedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
  });

  if (verified.acknowledgementState !== "ACKNOWLEDGEMENT_STATE_ACKNOWLEDGED") {
    try {
      await acknowledgeSubscription(purchaseToken);
    } catch (error) {
      console.error("Premium Season Pass acknowledgement failed", error);
      throw new HttpsError(
        "unavailable",
        "Premium access was saved, but Google Play acknowledgement needs retry.",
      );
    }
  }

  await receiptRef.set(
    {
      acknowledgementComplete: true,
      acknowledgedAt: FieldValue.serverTimestamp(),
    },
    { merge: true },
  );

  return {
    ok: true,
    seasonId,
    productId: PREMIUM_SEASON_PASS_PRODUCT_ID,
    basePlanId: PREMIUM_SEASON_PASS_BASE_PLAN_ID,
    expiresAt: expiry.toISOString(),
  };
});

export const onPremiumSeasonPassReward = onDocumentCreated(
  {
    document: `${COLLECTIONS.coinTransactions}/{transactionId}`,
    region: "me-central2",
  },
  async (event) => {
    const reward = event.data?.data();
    if (!reward || reward.reason !== "seasonPassReward" || reward.track !== "premium") return;

    const uid = stringValue(reward.uid);
    const seasonId = stringValue(reward.seasonId);
    const level = intValue(reward.level);
    const stars = premiumSeasonPassStarsForLevel(level);
    if (!uid || !seasonId || stars <= 0) return;

    const db = getFirestore();
    const passRef = db.collection(COLLECTIONS.seasonPass).doc(uid);
    const userRef = db.collection(COLLECTIONS.users).doc(uid);
    const starRef = db.collection(COLLECTIONS.prestigeStarTransactions)
      .doc(`premiumPass_${seasonId}_${level}_${uid}`);

    await db.runTransaction(async (transaction) => {
      const [passSnap, userSnap, starSnap] = await Promise.all([
        transaction.get(passRef),
        transaction.get(userRef),
        transaction.get(starRef),
      ]);
      if (starSnap.exists) return;
      const pass = passSnap.data() ?? {};
      const claimed = Array.isArray(pass.claimedPremiumLevels)
        ? pass.claimedPremiumLevels.filter((value): value is number => typeof value === "number")
        : [];
      if (
        stringValue(pass.seasonId) !== seasonId ||
        pass.premiumUnlocked !== true ||
        !claimed.includes(level)
      ) {
        throw new Error("Premium Season Pass star source is inconsistent with authoritative pass state.");
      }
      if (!userSnap.exists) throw new Error("Premium Season Pass player profile is missing.");

      transaction.update(userRef, {
        stars: FieldValue.increment(stars),
        updatedAt: FieldValue.serverTimestamp(),
      });
      transaction.create(starRef, {
        transactionId: starRef.id,
        uid,
        seasonId,
        level,
        amount: stars,
        reason: "premiumSeasonPassMilestone",
        sourceCoinTransactionId: event.params.transactionId,
        createdAt: FieldValue.serverTimestamp(),
      });
    });
  },
);
