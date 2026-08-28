import { FieldValue, getFirestore } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";

import { competitiveReward } from "./competitive_policy.js";
import { applyRp, resultForPlayer } from "./policy.js";

const CALLABLE_OPTIONS = {
  region: "me-central2",
  enforceAppCheck: true,
  timeoutSeconds: 60,
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

export const settleCompetitiveMatch = onCall(CALLABLE_OPTIONS, async (request) => {
  const callerUid = requireUid(request.auth?.uid);
  const matchId = requireMatchId(request.data?.matchId);
  const db = getFirestore();
  const matchRef = db.collection("competitiveMatches").doc(matchId);
  const settlementRef = db.collection("competitiveSettlements").doc(matchId);

  return db.runTransaction(async (tx) => {
    const [matchSnap, settlementSnap] = await Promise.all([
      tx.get(matchRef),
      tx.get(settlementRef),
    ]);
    const match = matchSnap.data();
    if (!match) throw new HttpsError("not-found", "Match not found.");
    if (settlementSnap.exists) return settlementSnap.data()?.payload ?? {};

    const playerAId = String(match.playerAId ?? "");
    const playerBId = String(match.playerBId ?? "");
    if (callerUid !== playerAId && callerUid !== playerBId) {
      throw new HttpsError("permission-denied", "Not a participant.");
    }
    if (!playerAId || !playerBId || playerAId === playerBId) {
      throw new HttpsError("data-loss", "Invalid match participants.");
    }
    if (match.status !== "awaitingSettlement") {
      throw new HttpsError("failed-precondition", "Trusted result is not finalized yet.");
    }

    const outcome = match.outcome;
    if (outcome !== "playerA" && outcome !== "playerB" && outcome !== "tie") {
      throw new HttpsError("data-loss", "Trusted outcome is missing.");
    }
    const wager = intValue(match.wager);
    const resultA = resultForPlayer(outcome, "playerA");
    const resultB = resultForPlayer(outcome, "playerB");
    const rewardA = competitiveReward(resultA, wager);
    const rewardB = competitiveReward(resultB, wager);

    const userARef = db.collection("users").doc(playerAId);
    const userBRef = db.collection("users").doc(playerBId);
    const inventoryARef = db.collection("inventories").doc(playerAId);
    const inventoryBRef = db.collection("inventories").doc(playerBId);
    const walletARef = db.collection("competitiveWallets").doc(playerAId);
    const walletBRef = db.collection("competitiveWallets").doc(playerBId);

    const [userASnap, userBSnap, inventoryASnap, inventoryBSnap, walletASnap, walletBSnap] =
      await Promise.all([
        tx.get(userARef),
        tx.get(userBRef),
        tx.get(inventoryARef),
        tx.get(inventoryBRef),
        tx.get(walletARef),
        tx.get(walletBRef),
      ]);

    if (!userASnap.exists || !userBSnap.exists) {
      throw new HttpsError("failed-precondition", "Both profiles must exist.");
    }

    const walletA = walletASnap.data() ?? {};
    const walletB = walletBSnap.data() ?? {};
    const goldA = intValue(walletA.gold);
    const goldB = intValue(walletB.gold);
    const heldA = intValue(walletA.heldGold);
    const heldB = intValue(walletB.heldGold);
    if (heldA < wager || heldB < wager) {
      throw new HttpsError("data-loss", "Wager escrow is incomplete.");
    }

    const nextGoldA = Math.max(0, goldA + rewardA.goldDelta);
    const nextGoldB = Math.max(0, goldB + rewardB.goldDelta);
    const nextHeldA = heldA - wager;
    const nextHeldB = heldB - wager;

    const profileA = userASnap.data()!;
    const profileB = userBSnap.data()!;
    const currentRpA = intValue(profileA.rankPoints);
    const currentRpB = intValue(profileB.rankPoints);
    const nextRpA = applyRp(currentRpA, rewardA.rpDelta);
    const nextRpB = applyRp(currentRpB, rewardB.rpDelta);

    const inventoryA = inventoryASnap.data() ?? {};
    const inventoryB = inventoryBSnap.data() ?? {};
    const nextCoinsA = Math.max(0, intValue(inventoryA.coins)) + rewardA.coinsDelta;
    const nextCoinsB = Math.max(0, intValue(inventoryB.coins)) + rewardB.coinsDelta;

    tx.set(walletARef, {
      uid: playerAId,
      gold: nextGoldA,
      heldGold: nextHeldA,
      updatedAt: FieldValue.serverTimestamp(),
    }, { merge: true });
    tx.set(walletBRef, {
      uid: playerBId,
      gold: nextGoldB,
      heldGold: nextHeldB,
      updatedAt: FieldValue.serverTimestamp(),
    }, { merge: true });

    tx.set(walletARef.collection("goldTransactions").doc(`settle_${matchId}`), {
      matchId,
      currency: "gold",
      kind: resultA === "win" ? "wagerWin" : resultA === "loss" ? "wagerLoss" : "wagerRelease",
      amount: rewardA.goldDelta,
      balanceAfter: nextGoldA,
      createdAt: FieldValue.serverTimestamp(),
    });
    tx.set(walletBRef.collection("goldTransactions").doc(`settle_${matchId}`), {
      matchId,
      currency: "gold",
      kind: resultB === "win" ? "wagerWin" : resultB === "loss" ? "wagerLoss" : "wagerRelease",
      amount: rewardB.goldDelta,
      balanceAfter: nextGoldB,
      createdAt: FieldValue.serverTimestamp(),
    });

    tx.set(inventoryARef, { coins: nextCoinsA, updatedAt: FieldValue.serverTimestamp() }, { merge: true });
    tx.set(inventoryBRef, { coins: nextCoinsB, updatedAt: FieldValue.serverTimestamp() }, { merge: true });
    tx.update(userARef, {
      rankPoints: nextRpA,
      wins: intValue(profileA.wins) + (resultA === "win" ? 1 : 0),
      losses: intValue(profileA.losses) + (resultA === "loss" ? 1 : 0),
      ties: intValue(profileA.ties) + (resultA === "tie" ? 1 : 0),
      gamesPlayed: intValue(profileA.gamesPlayed) + 1,
      updatedAt: FieldValue.serverTimestamp(),
    });
    tx.update(userBRef, {
      rankPoints: nextRpB,
      wins: intValue(profileB.wins) + (resultB === "win" ? 1 : 0),
      losses: intValue(profileB.losses) + (resultB === "loss" ? 1 : 0),
      ties: intValue(profileB.ties) + (resultB === "tie" ? 1 : 0),
      gamesPlayed: intValue(profileB.gamesPlayed) + 1,
      updatedAt: FieldValue.serverTimestamp(),
    });

    const rpBoardARef = db.collection("competitiveLeaderboards").doc("rp").collection("entries").doc(playerAId);
    const rpBoardBRef = db.collection("competitiveLeaderboards").doc("rp").collection("entries").doc(playerBId);
    const goldBoardARef = db.collection("competitiveLeaderboards").doc("gold").collection("entries").doc(playerAId);
    const goldBoardBRef = db.collection("competitiveLeaderboards").doc("gold").collection("entries").doc(playerBId);

    tx.set(rpBoardARef, { uid: playerAId, value: nextRpA, updatedAt: FieldValue.serverTimestamp() }, { merge: true });
    tx.set(rpBoardBRef, { uid: playerBId, value: nextRpB, updatedAt: FieldValue.serverTimestamp() }, { merge: true });
    tx.set(goldBoardARef, { uid: playerAId, value: nextGoldA, updatedAt: FieldValue.serverTimestamp() }, { merge: true });
    tx.set(goldBoardBRef, { uid: playerBId, value: nextGoldB, updatedAt: FieldValue.serverTimestamp() }, { merge: true });

    const payload = {
      matchId,
      outcome,
      wager,
      playerA: { uid: playerAId, goldDelta: rewardA.goldDelta, coinsDelta: rewardA.coinsDelta, rpDelta: nextRpA - currentRpA },
      playerB: { uid: playerBId, goldDelta: rewardB.goldDelta, coinsDelta: rewardB.coinsDelta, rpDelta: nextRpB - currentRpB },
    };

    tx.create(settlementRef, {
      matchId,
      payload,
      createdAt: FieldValue.serverTimestamp(),
    });
    tx.update(matchRef, {
      status: "finished",
      settledAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });

    return payload;
  });
});
