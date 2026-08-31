import type { MiniGameEvidence } from "./registry.js";

export type MatchDecisionReason = "score" | "timeTieBreaker" | "exactTie";

export interface MatchGameReceipt {
  gameId: string;
  gameIndex: number;
  gameSeed: number;
  playerAScore: number;
  playerBScore: number;
  playerADurationMs: number;
  playerBDurationMs: number;
  playerAAccuracy: number;
  playerBAccuracy: number;
  playerAMistakes: number;
  playerBMistakes: number;
}

export interface MatchReceipt {
  schemaVersion: 1;
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
  if (evidenceA.length === 0 || evidenceA.length !== evidenceB.length) {
    throw new Error("match receipt requires equal non-empty evidence chains");
  }

  const games = evidenceA.map((a, index) => {
    const b = evidenceB[index];
    if (!b || a.gameIndex !== index || b.gameIndex !== index) {
      throw new Error(`invalid evidence index ${index}`);
    }
    if (a.gameId !== b.gameId || a.gameSeed !== b.gameSeed) {
      throw new Error(`players do not share the same locked game at index ${index}`);
    }
    return {
      gameId: a.gameId,
      gameIndex: index,
      gameSeed: a.gameSeed,
      playerAScore: a.score,
      playerBScore: b.score,
      playerADurationMs: a.durationMs,
      playerBDurationMs: b.durationMs,
      playerAAccuracy: a.accuracy,
      playerBAccuracy: b.accuracy,
      playerAMistakes: a.mistakes,
      playerBMistakes: b.mistakes,
    };
  });

  const playerATotalScore = sum(evidenceA, "score");
  const playerBTotalScore = sum(evidenceB, "score");
  const playerATotalDurationMs = sum(evidenceA, "durationMs");
  const playerBTotalDurationMs = sum(evidenceB, "durationMs");

  let winnerId: string | null = null;
  let loserId: string | null = null;
  let reason: MatchDecisionReason;

  if (playerATotalScore !== playerBTotalScore) {
    const aWins = playerATotalScore > playerBTotalScore;
    winnerId = aWins ? playerAId : playerBId;
    loserId = aWins ? playerBId : playerAId;
    reason = "score";
  } else if (playerATotalDurationMs !== playerBTotalDurationMs) {
    const aWins = playerATotalDurationMs < playerBTotalDurationMs;
    winnerId = aWins ? playerAId : playerBId;
    loserId = aWins ? playerBId : playerAId;
    reason = "timeTieBreaker";
  } else {
    reason = "exactTie";
  }

  return {
    schemaVersion: 1,
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
    scoreDifference: Math.abs(playerATotalScore - playerBTotalScore),
    timeDifferenceMs: Math.abs(playerATotalDurationMs - playerBTotalDurationMs),
    games,
  };
}
