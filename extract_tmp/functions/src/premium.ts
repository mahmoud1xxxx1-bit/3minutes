import { createHash } from "node:crypto";

import { FieldValue, Timestamp, getFirestore } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import { GoogleAuth } from "google-auth-library";

import { cosmeticById } from "./catalog.js";
import { COLLECTIONS } from "./firestore.js";

const PACKAGE_NAME = "com.threeminutes.game";
const ANDROID_PUBLISHER_SCOPE = "https://www.googleapis.com/auth/androidpublisher";
const CALLABLE_OPTIONS = {
  region: "me-central2",
  enforceAppCheck: true,
  timeoutSeconds: 60,
} as const;

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

function receiptId(token: string): string {
  return createHash("sha256").update(token).digest("hex");
}

type ProductPurchaseV2 = {
  productLineItem?: Array<{ productId?: string }>;
  purchaseStateContext?: { purchaseState?: string };
  acknowledgementState?: string;
  orderId?: string;
  obfuscatedExternalAccountId?: string;
  regionCode?: string;
  purchaseCompletionTime?: string;
};

async function playClient() {
  const auth = new GoogleAuth({ scopes: [ANDROID_PUBLISHER_SCOPE] });
  return auth.getClient();
}

async function verifyWithGoogle(token: string): Promise<ProductPurchaseV2> {
  const client = await playClient();
  const encodedToken = encodeURIComponent(token);
  const url = `https://androidpublisher.googleapis.com/androidpublisher/v3/applications/${PACKAGE_NAME}/purchases/productsv2/tokens/${encodedToken}`;
  const response = await client.request<ProductPurchaseV2>({ url, method: "GET" });
  return response.data;
}

async function acknowledgeWithGoogle(options: {
  productId: string;
  purchaseToken: string;
}): Promise<void> {
  const client = await playClient();
  const productId = encodeURIComponent(options.productId);
  const token = encodeURIComponent(options.purchaseToken);
  const url = `https://androidpublisher.googleapis.com/androidpublisher/v3/applications/${PACKAGE_NAME}/purchases/products/${productId}/tokens/${token}:acknowledge`;
  await client.request({
    url,
    method: "POST",
    data: {},
  });
}

export const verifyPremiumPurchase = onCall(CALLABLE_OPTIONS, async (request) => {
  const uid = requireUid(request.auth?.uid);
  const cosmeticId = requireString(request.data?.cosmeticId, "cosmeticId");
  const productId = requireString(request.data?.productId, "productId");
  const purchaseToken = requireString(request.data?.purchaseToken, "purchaseToken");

  const cosmetic = cosmeticById(cosmeticId);
  if (!cosmetic || cosmetic.priceType !== "premium") {
    throw new HttpsError("failed-precondition", "Cosmetic is not a premium product.");
  }
  if (productId !== cosmetic.id) {
    throw new HttpsError("invalid-argument", "Product id does not match cosmetic id.");
  }

  let verified: ProductPurchaseV2;
  try {
    verified = await verifyWithGoogle(purchaseToken);
  } catch (error) {
    console.error("Google Play verification failed", error);
    throw new HttpsError("failed-precondition", "Google Play could not verify this purchase.");
  }

  if (verified.purchaseStateContext?.purchaseState !== "PURCHASED") {
    throw new HttpsError("failed-precondition", "Purchase is not completed.");
  }
  const productIds = new Set(
    (verified.productLineItem ?? [])
      .map((item) => item.productId)
      .filter((value): value is string => typeof value === "string"),
  );
  if (!productIds.has(productId)) {
    throw new HttpsError("permission-denied", "Verified purchase does not contain this product.");
  }

  const db = getFirestore();
  const tokenReceiptId = receiptId(purchaseToken);
  const receiptRef = db.collection(COLLECTIONS.purchaseReceipts).doc(tokenReceiptId);
  const inventoryRef = db.collection(COLLECTIONS.inventories).doc(uid);
  const now = new Date();

  const entitlement = await db.runTransaction(async (transaction) => {
    const [receiptSnap, inventorySnap] = await Promise.all([
      transaction.get(receiptRef),
      transaction.get(inventoryRef),
    ]);

    if (receiptSnap.exists) {
      const receipt = receiptSnap.data() ?? {};
      if (receipt.uid !== uid || receipt.cosmeticId !== cosmeticId) {
        throw new HttpsError(
          "permission-denied",
          "This Google Play purchase was already attached to another entitlement.",
        );
      }
      return { alreadyGranted: true };
    }

    const inventory = inventorySnap.data() ?? {};
    const owned = Array.isArray(inventory.ownedCosmeticIds)
      ? inventory.ownedCosmeticIds.filter(
          (value): value is string => typeof value === "string",
        )
      : [];
    const nextOwned = owned.includes(cosmeticId) ? owned : [...owned, cosmeticId];

    transaction.set(
      inventoryRef,
      {
        ownedCosmeticIds: nextOwned,
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
    transaction.create(receiptRef, {
      receiptId: tokenReceiptId,
      uid,
      cosmeticId,
      productId,
      platform: "googlePlay",
      orderId: verified.orderId ?? null,
      regionCode: verified.regionCode ?? null,
      purchaseCompletionTime: verified.purchaseCompletionTime ?? null,
      googleAcknowledgementState: verified.acknowledgementState ?? null,
      grantedAt: Timestamp.fromDate(now),
      createdAt: FieldValue.serverTimestamp(),
    });
    return { alreadyGranted: false };
  });

  if (verified.acknowledgementState !== "ACKNOWLEDGEMENT_STATE_ACKNOWLEDGED") {
    try {
      await acknowledgeWithGoogle({ productId, purchaseToken });
    } catch (error) {
      console.error("Google Play acknowledgement failed", error);
      throw new HttpsError(
        "unavailable",
        "Entitlement was saved but Google Play acknowledgement needs retry.",
      );
    }
  }

  await receiptRef.set(
    {
      acknowledgedAt: FieldValue.serverTimestamp(),
      acknowledgementComplete: true,
    },
    { merge: true },
  );

  return {
    ok: true,
    cosmeticId,
    productId,
    alreadyGranted: entitlement.alreadyGranted,
  };
});
