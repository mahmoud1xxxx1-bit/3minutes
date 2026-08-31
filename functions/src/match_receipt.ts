import type { MiniGameEvidence } from "./registry.js";

export type MatchDecisionReason =
  | "score"
  | "gameProgress"
  | "timeTieBreaker"
  | "doubleFail"
  | "exactTie";

export interface MatchGameReceipt {
  gameId: string;
  gameVersion: number;
  gameIndex: number;
  gameSeed: number;
  playerA: MiniGameEvidence | null;
  playerB: MiniGameEvidence | null;
}

export interface MatchReceipt {
  schemaVersion: 2;
  matchId: string;
  playerAId: string;
  playerBId: string;
  winnerId: string | null;
  loserId: string | null;
  reason: MatchDecisionReason;
  playerATotalScore: number;
  playerBTotalScore: number;
  playerATotalDurationMs: number;
  playerBTotalDurationMs: number;
  playerAAttemptedGames: number;
  playerBAttemptedGames: number;
  playerACompletedGames: number;
  playerBCompletedGames: number;
  scoreDifference: number;
  timeDifferenceMs: number;
  games: MatchGameReceipt[];
}

function sum(values: MiniGameEvidence[], key: "score" | "durationMs"): number {
  return values.reduce((total, item) => total + item[key], 0);
}

export function buildMatchReceipt(options: {
  matchId: string;
  playerAId: string;
  playerBId: string;
  evidenceA: MiniGameEvidence[];
  evidenceB: MiniGameEvidence[];
}): MatchReceipt {
  const { matchId, playerAId, playerBId, evidenceA, evidenceB } = options;
  if (!matchId || !playerAId || !playerBId || playerAId === playerBId) {
    throw new Error("invalid match receipt identity");
  }
  if (evidenceA.length === 0 && evidenceB.length === 0) {
    throw new Error("match receipt requires at least one submitted game result");
  }

  const maxGames = Math.max(evidenceA.length, evidenceB.length);
  const games: MatchGameReceipt[] = [];
  for (let index = 0; index < maxGames; index += 1) {
    const a = evidenceA[index] ?? null;
    const b = evidenceB[index] ?? null;
    const source = a ?? b;
    if (!source) throw new Error(`missing evidence at index ${index}`);
    if (source.gameIndex !== index) throw new Error(`invalid evidence index ${index}`);
    if (a && a.gameIndex !== index) throw new Error(`invalid player A evidence index ${index}`);
    if (b && b.gameIndex !== index) throw new Error(`invalid player B evidence index ${index}`);
    if (
      a && b &&
      (a.gameId !== b.gameId || a.gameVersion !== b.gameVersion || a.gameSeed !== b.gameSeed)
    ) {
      throw new Error(`players do not share the same locked game/version at index ${index}`);
    }
    games.push({
      gameId: source.gameId,
      gameVersion: source.gameVersion,
      gameIndex: index,
      gameSeed: source.gameSeed,
      playerA: a,
      playerB: b,
    });
  }

  const playerATotalScore = sum(evidenceA, "score");
  const playerBTotalScore = sum(evidenceB, "score");
  const playerATotalDurationMs = sum(evidenceA, "durationMs");
  const playerBTotalDurationMs = sum(evidenceB, "durationMs");
  const playerAAttemptedGames = evidenceA.length;
  const playerBAttemptedGames = evidenceB.length;
  const playerACompletedGames = evidenceA.filter((item) => item.completed).length;
  const playerBCompletedGames = evidenceB.filter((item) => item.completed).length;
  const bothClearedAllFour =
    evidenceA.length === 4 &&
    evidenceB.length === 4 &&
    evidenceA.every((item) => item.completed) &&
    evidenceB.every((item) => item.completed);

  let winnerId: string | null = null;
  let loserId: string | null = null;
  let reason: MatchDecisionReason;

  // Rule 1: every successfully completed mini-game is exactly 1000 points.
  if (playerATotalScore !== playerBTotalScore) {
    const aWins = playerATotalScore > playerBTotalScore;
    winnerId = aWins ? playerAId : playerBId;
    loserId = aWins ? playerBId : playerAId;
    reason = "score";
  // Rule 2: if points are equal when time expires, the player who reached a
  // later game in the locked four-game sequence is ahead.
  } else if (playerAAttemptedGames !== playerBAttemptedGames) {
    const aWins = playerAAttemptedGames > playerBAttemptedGames;
    winnerId = aWins ? playerAId : playerBId;
    loserId = aWins ? playerBId : playerAId;
    reason = "gameProgress";
  // Rule 3: time is used only when both players correctly clear all 4 games.
  } else if (bothClearedAllFour && playerATotalDurationMs !== playerBTotalDurationMs) {
    const aWins = playerATotalDurationMs < playerBTotalDurationMs;
    winnerId = aWins ? playerAId : playerBId;
    loserId = aWins ? playerBId : playerAId;
    reason = "timeTieBreaker";
  } else if (bothClearedAllFour) {
    reason = "exactTie";
  } else {
    // Same official points + same game position + at least one failed objective.
    // Phase 2 applies the approved 50% wager-return / 50% failure penalty.
    reason = "doubleFail";
  }

  return {
    schemaVersion: 2,
    matchId,
    playerAId,
    playerBId,
    winnerId,
    loserId,
    reason,
    playerATotalScore,
    playerBTotalScore,
    playerATotalDurationMs,
    playerBTotalDurationMs,
    playerAAttemptedGames,
    playerBAttemptedGames,
    playerACompletedGames,
    playerBCompletedGames,
    scoreDifference: Math.abs(playerATotalScore - playerBTotalScore),
    timeDifferenceMs: Math.abs(playerATotalDurationMs - playerBTotalDurationMs),
    games,
  };
}
