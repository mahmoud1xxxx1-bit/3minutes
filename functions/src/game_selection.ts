import { FieldValue, getFirestore } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";

import { AUTHORITY_VERSION, COLLECTIONS, boolValue, intValue, stringValue, timestampMillis } from "./firestore.js";
import { APPROVED_GAMES, MATCH_GAME_COUNT, REGISTRY_VERSION, validateLockedGameIds } from "./registry.js";
import { seasonAcceptsNewRankedMatch } from "./season_boundary.js";

const OPTIONS = {
  region: "me-central2",
  enforceAppCheck: true,
  timeoutSeconds: 30,
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

function parsePicks(value: unknown): string[] {
  if (!Array.isArray(value) || value.length !== 2) {
    throw new HttpsError("invalid-argument", "Each player must choose exactly two games.");
  }
  const ids = value.map((raw) => typeof raw === "string" ? raw.trim() : "");
  if (ids.some((id) => id.length === 0) || new Set(ids).size !== 2) {
    throw new HttpsError("invalid-argument", "Game picks must be two different valid ids.");
  }
  const approved = new Set(APPROVED_GAMES.map((game) => game.id));
  if (ids.some((id) => !approved.has(id))) {
    throw new HttpsError("invalid-argument", "One or more selected games are not approved.");
  }
  return ids;
}

function stringArray(value: unknown): string[] {
  if (!Array.isArray(value)) return [];
  return value.filter((item): item is string => typeof item === "string");
}

export const submitRankedGameSelection = onCall(OPTIONS, async (request) => {
  const uid = requireUid(request.auth?.uid);
  const matchId = requireMatchId(request.data?.matchId);
  const picks = parsePicks(request.data?.gameIds);
  const db = getFirestore();
  const ref = db.collection(COLLECTIONS.matches).doc(matchId);

  return db.runTransaction(async (transaction) => {
    const snapshot = await transaction.get(ref);
    const match = snapshot.data();
    if (!match) throw new HttpsError("not-found", "Match not found.");
    if (intValue(match.authorityVersion) !== AUTHORITY_VERSION || intValue(match.registryVersion) !== REGISTRY_VERSION) {
      throw new HttpsError("failed-precondition", "Match contract version mismatch.");
    }
    if (match.status !== "waitingReady" || match.countdownStartedAt != null) {
      throw new HttpsError("failed-precondition", "Game selection is already closed.");
    }

    const playerAId = stringValue(match.playerAId);
    const playerBId = stringValue(match.playerBId);
    if (uid !== playerAId && uid !== playerBId) {
      throw new HttpsError("permission-denied", "Not a participant.");
    }

    const ownField = uid === playerAId ? "playerAGameIds" : "playerBGameIds";
    const otherField = uid === playerAId ? "playerBGameIds" : "playerAGameIds";
    const existingOwn = stringArray(match[ownField]);
    if (existingOwn.length === 2) {
      if (existingOwn[0] === picks[0] && existingOwn[1] === picks[1]) {
        return { ok: true, lockedGameIds: stringArray(match.lockedGameIds) };
      }
      throw new HttpsError("failed-precondition", "Your two game choices are already locked.");
    }

    const other = stringArray(match[otherField]);
    if (picks.some((id) => other.includes(id))) {
      throw new HttpsError("already-exists", "The opponent already selected one of these games.");
    }

    const update: Record<string, unknown> = {
      [ownField]: picks,
      updatedAt: FieldValue.serverTimestamp(),
    };
    const a = uid === playerAId ? picks : other;
    const b = uid === playerBId ? picks : other;
    if (a.length === 2 && b.length === 2) {
      const locked = [...a, ...b];
      if (!validateLockedGameIds(locked) || locked.length !== MATCH_GAME_COUNT) {
        throw new HttpsError("failed-precondition", "The four-game set is invalid.");
      }
      update.lockedGameIds = locked;
      update.gameSelectionLockedAt = FieldValue.serverTimestamp();
    }
    transaction.update(ref, update);
    return { ok: true, lockedGameIds: update.lockedGameIds ?? [] };
  });
});

export const markRankedReadyV2 = onCall(OPTIONS, async (request) => {
  const uid = requireUid(request.auth?.uid);
  const matchId = requireMatchId(request.data?.matchId);
  const db = getFirestore();
  const ref = db.collection(COLLECTIONS.matches).doc(matchId);

  await db.runTransaction(async (transaction) => {
    const snapshot = await transaction.get(ref);
    const match = snapshot.data();
    if (!match) throw new HttpsError("not-found", "Match not found.");
    if (intValue(match.authorityVersion) !== AUTHORITY_VERSION || intValue(match.registryVersion) !== REGISTRY_VERSION) {
      throw new HttpsError("failed-precondition", "Match contract version mismatch.");
    }
    if (match.status !== "waitingReady") return;

    const playerAId = stringValue(match.playerAId);
    const playerBId = stringValue(match.playerBId);
    if (uid !== playerAId && uid !== playerBId) {
      throw new HttpsError("permission-denied", "Not a participant.");
    }
    const lockedGameIds = stringArray(match.lockedGameIds);
    if (!validateLockedGameIds(lockedGameIds)) {
      throw new HttpsError("failed-precondition", "Both players must choose two games before Ready.");
    }

    const nextReadyA = uid === playerAId ? true : boolValue(match.readyA);
    const nextReadyB = uid === playerBId ? true : boolValue(match.readyB);
    const update: Record<string, unknown> = {
      readyA: nextReadyA,
      readyB: nextReadyB,
      updatedAt: FieldValue.serverTimestamp(),
    };

    if (nextReadyA && nextReadyB && match.countdownStartedAt == null) {
      const seasonId = stringValue(match.seasonId);
      if (!seasonId) throw new HttpsError("failed-precondition", "Ranked match has no season binding.");
      const season = (await transaction.get(db.collection(COLLECTIONS.seasons).doc(seasonId))).data();
      const startsAtMs = season ? timestampMillis(season.startsAt) : null;
      const endsAtMs = season ? timestampMillis(season.endsAt) : null;
      if (!season || !seasonAcceptsNewRankedMatch({ active: season.active === true, startsAtMs, endsAtMs, nowMs: Date.now() })) {
        throw new HttpsError("failed-precondition", "Ranked season is not accepting matches.");
      }
      update.countdownStartedAt = FieldValue.serverTimestamp();
      update.status = "countdown";
    }
    transaction.update(ref, update);
  });

  return { ok: true };
});
