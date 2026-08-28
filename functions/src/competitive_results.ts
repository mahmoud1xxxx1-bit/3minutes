import { FieldValue, getFirestore, Timestamp } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";

import { COMPETITIVE_GAME_COUNT } from "./competitive_policy.js";

const CALLABLE_OPTIONS = {
  region: "me-central2",
  enforceAppCheck: true,
  timeoutSeconds: 30,
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

function intValue(value: unknown, name: string, min = 0, max = 1_000_000_000): number {
  const parsed = Number(value);
  if (!Number.isFinite(parsed)) throw new HttpsError("invalid-argument", `${name} must be numeric.`);
  const result = Math.trunc(parsed);
  if (result < min || result > max) throw new HttpsError("invalid-argument", `${name} is out of range.`);
  return result;
}

function progressValue(value: unknown): number {
  const parsed = Number(value);
  if (!Number.isFinite(parsed)) return 0;
  return Math.max(0, Math.min(1, parsed));
}

function safeStats(value: unknown): Record<string, number> {
  if (!value || typeof value !== "object" || Array.isArray(value)) return {};
  const result: Record<string, number> = {};
  for (const [key, raw] of Object.entries(value as Record<string, unknown>).slice(0, 20)) {
    if (!/^[a-zA-Z0-9_]{1,40}$/.test(key)) continue;
    const number = Number(raw);
    if (Number.isFinite(number)) result[key] = Math.max(-1_000_000_000, Math.min(1_000_000_000, number));
  }
  return result;
}

function resultDocId(uid: string, gameIndex: number): string {
  return `${uid}_${gameIndex}`;
}

export const submitCompetitiveGameResult = onCall(CALLABLE_OPTIONS, async (request) => {
  const uid = requireUid(request.auth?.uid);
  const matchId = requireString(request.data?.matchId, "matchId");
  const gameId = requireString(request.data?.gameId, "gameId");
  const gameIndex = intValue(request.data?.gameIndex, "gameIndex", 0, COMPETITIVE_GAME_COUNT - 1);
  const normalizedScore = intValue(request.data?.normalizedScore, "normalizedScore");
  const rawScore = Number(request.data?.rawScore ?? normalizedScore);
  if (!Number.isFinite(rawScore)) throw new HttpsError("invalid-argument", "rawScore must be numeric.");
  const completed = request.data?.completed === true;
  const progress = progressValue(request.data?.progress);
  const elapsedMs = intValue(request.data?.elapsedMs ?? 0, "elapsedMs", 0, 180_000);
  const stats = safeStats(request.data?.stats);

  const db = getFirestore();
  const matchRef = db.collection("competitiveMatches").doc(matchId);
  const resultRef = matchRef.collection("gameResults").doc(resultDocId(uid, gameIndex));

  return db.runTransaction(async (tx) => {
    const [matchSnap, existingSnap] = await Promise.all([tx.get(matchRef), tx.get(resultRef)]);
    const match = matchSnap.data();
    if (!match) throw new HttpsError("not-found", "Match not found.");
    if (existingSnap.exists) return { accepted: true, duplicate: true };

    const playerAId = String(match.playerAId ?? "");
    const playerBId = String(match.playerBId ?? "");
    if (uid !== playerAId && uid !== playerBId) {
      throw new HttpsError("permission-denied", "Not a participant.");
    }
    if (match.status !== "countdown" && match.status !== "playing") {
      throw new HttpsError("failed-precondition", "Match is not accepting game results.");
    }

    const order = Array.isArray(match.gameOrder) ? match.gameOrder.map(String) : [];
    if (order.length !== COMPETITIVE_GAME_COUNT || order[gameIndex] !== gameId) {
      throw new HttpsError("failed-precondition", "Game is not assigned to this match slot.");
    }
    const startsAt = match.startsAt;
    if (!(startsAt instanceof Timestamp) || Date.now() + 1000 < startsAt.toMillis()) {
      throw new HttpsError("failed-precondition", "Match has not started yet.");
    }

    tx.create(resultRef, {
      uid,
      gameId,
      gameIndex,
      rawScore,
      normalizedScore,
      completed,
      progress,
      elapsedMs,
      stats,
      submittedAt: FieldValue.serverTimestamp(),
    });
    if (match.status === "countdown") {
      tx.update(matchRef, { status: "playing", updatedAt: FieldValue.serverTimestamp() });
    }
    return { accepted: true, duplicate: false };
  });
});

export const finalizeCompetitiveResults = onCall(CALLABLE_OPTIONS, async (request) => {
  const uid = requireUid(request.auth?.uid);
  const matchId = requireString(request.data?.matchId, "matchId");
  const db = getFirestore();
  const matchRef = db.collection("competitiveMatches").doc(matchId);
  const matchSnap = await matchRef.get();
  const match = matchSnap.data();
  if (!match) throw new HttpsError("not-found", "Match not found.");

  const playerAId = String(match.playerAId ?? "");
  const playerBId = String(match.playerBId ?? "");
  if (uid !== playerAId && uid !== playerBId) {
    throw new HttpsError("permission-denied", "Not a participant.");
  }
  if (match.status === "awaitingSettlement" || match.status === "finished") {
    return { status: match.status, outcome: match.outcome ?? null };
  }
  if (match.status !== "countdown" && match.status !== "playing") {
    throw new HttpsError("failed-precondition", "Match cannot be finalized now.");
  }

  const order = Array.isArray(match.gameOrder) ? match.gameOrder.map(String) : [];
  if (order.length !== COMPETITIVE_GAME_COUNT) throw new HttpsError("data-loss", "Invalid game order.");

  const resultsSnap = await matchRef.collection("gameResults").get();
  const byKey = new Map<string, FirebaseFirestore.DocumentData>();
  for (const doc of resultsSnap.docs) {
    const data = doc.data();
    byKey.set(`${String(data.uid)}_${Number(data.gameIndex)}`, data);
  }

  const expectedCount = COMPETITIVE_GAME_COUNT * 2;
  const deadline = match.deadline;
  const deadlinePassed = deadline instanceof Timestamp && Date.now() >= deadline.toMillis();
  if (byKey.size < expectedCount && !deadlinePassed) {
    throw new HttpsError("failed-precondition", "Both players have not finished all game slots yet.");
  }

  let totalA = 0;
  let totalB = 0;
  const gameResults = order.map((gameId, gameIndex) => {
    const a = byKey.get(`${playerAId}_${gameIndex}`);
    const b = byKey.get(`${playerBId}_${gameIndex}`);
    const scoreA = a ? Number(a.normalizedScore ?? 0) : 0;
    const scoreB = b ? Number(b.normalizedScore ?? 0) : 0;
    totalA += scoreA;
    totalB += scoreB;
    return {
      gameId,
      gameIndex,
      playerAScore: scoreA,
      playerBScore: scoreB,
      winner: scoreA === scoreB ? "tie" : scoreA > scoreB ? "playerA" : "playerB",
      playerACompleted: a?.completed === true,
      playerBCompleted: b?.completed === true,
    };
  });
  const outcome = totalA === totalB ? "tie" : totalA > totalB ? "playerA" : "playerB";

  await db.runTransaction(async (tx) => {
    const freshSnap = await tx.get(matchRef);
    const fresh = freshSnap.data();
    if (!fresh) throw new HttpsError("not-found", "Match not found.");
    if (fresh.status === "awaitingSettlement" || fresh.status === "finished") return;
    if (fresh.status !== "countdown" && fresh.status !== "playing") {
      throw new HttpsError("failed-precondition", "Match state changed before finalization.");
    }
    tx.update(matchRef, {
      status: "awaitingSettlement",
      outcome,
      totalScoreA: totalA,
      totalScoreB: totalB,
      gameResults,
      resultFinalizedAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });
  });

  return { status: "awaitingSettlement", outcome, totalScoreA: totalA, totalScoreB: totalB, gameResults };
});
