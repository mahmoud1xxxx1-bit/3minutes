import type { MiniGameEvidence } from "./registry.js";

export type MatchDecisionReason =
  | "score"
  | "progress"
  | "timeTieBreaker"
  | "doubleFail"
  | "exactTie";

export interface MatchGameReceipt {
  gameId: string;
  gameVersion: number;
  gameIndex: number;
  gameSeed: number;
  playerACompleted: boolean;
  playerBCompleted: boolean;
  playerAProgressStep: number;
  playerAProgressStepCount: number;
  playerBProgressStep: number;
  playerBProgressStepCount: number;
  playerAScore: number;
  playerBScore: number;
  playerADurationMs: number;
  playerBDurationMs: number;
  playerAAccuracy: number;
  playerBAccuracy: number;
  playerAMistakes: number;
  playerBMistakes: number;
  progressWinner: "playerA" | "playerB" | "tie";
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
  playerACompletedGames: number;
  playerBCompletedGames: number;
  playerAProgressWins: number;
  playerBProgressWins: number;
  scoreDifference: number;
  timeDifferenceMs: number;
  games: MatchGameReceipt[];
}

function sum(values: MiniGameEvidence[], key: "score" | "durationMs"): number {
  return values.reduce((total, item) => total + item[key], 0);
}

function compareDiscreteProgress(
  a: MiniGameEvidence,
  b: MiniGameEvidence,
): "playerA" | "playerB" | "tie" {
  if (a.completed !== b.completed) return a.completed ? "playerA" : "playerB";
  if (a.completed && b.completed) return "tie";

  // Compare a/b progress without floating-point rounding.
  const left = a.progressStep * b.progressStepCount;
  const right = b.progressStep * a.progressStepCount;
  if (left > right) return "playerA";
  if (right > left) return "playerB";
  return "tie";
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

  let playerAProgressWins = 0;
  let playerBProgressWins = 0;
  const games = evidenceA.map((a, index) => {
    const b = evidenceB[index];
    if (!b || a.gameIndex !== index || b.gameIndex !== index) {
      throw new Error(`invalid evidence index ${index}`);
    }
    if (
      a.gameId !== b.gameId ||
      a.gameVersion !== b.gameVersion ||
      a.gameSeed !== b.gameSeed
    ) {
      throw new Error(`players do not share the same locked game/version at index ${index}`);
    }
    const progressWinner = compareDiscreteProgress(a, b);
    if (progressWinner === "playerA") playerAProgressWins += 1;
    if (progressWinner === "playerB") playerBProgressWins += 1;
    return {
      gameId: a.gameId,
      gameVersion: a.gameVersion,
      gameIndex: index,
      gameSeed: a.gameSeed,
      playerACompleted: a.completed,
      playerBCompleted: b.completed,
      playerAProgressStep: a.progressStep,
      playerAProgressStepCount: a.progressStepCount,
      playerBProgressStep: b.progressStep,
      playerBProgressStepCount: b.progressStepCount,
      playerAScore: a.score,
      playerBScore: b.score,
      playerADurationMs: a.durationMs,
      playerBDurationMs: b.durationMs,
      playerAAccuracy: a.accuracy,
      playerBAccuracy: b.accuracy,
      playerAMistakes: a.mistakes,
      playerBMistakes: b.mistakes,
      progressWinner,
    };
  });

  const playerATotalScore = sum(evidenceA, "score");
  const playerBTotalScore = sum(evidenceB, "score");
  const playerATotalDurationMs = sum(evidenceA, "durationMs");
  const playerBTotalDurationMs = sum(evidenceB, "durationMs");
  const playerACompletedGames = evidenceA.filter((item) => item.completed).length;
  const playerBCompletedGames = evidenceB.filter((item) => item.completed).length;
  const bothClearedEverything =
    playerACompletedGames === evidenceA.length && playerBCompletedGames === evidenceB.length;

  let winnerId: string | null = null;
  let loserId: string | null = null;
  let reason: MatchDecisionReason;

  if (playerATotalScore !== playerBTotalScore) {
    const aWins = playerATotalScore > playerBTotalScore;
    winnerId = aWins ? playerAId : playerBId;
    loserId = aWins ? playerBId : playerAId;
    reason = "score";
  } else if (!bothClearedEverything && playerAProgressWins !== playerBProgressWins) {
    const aWins = playerAProgressWins > playerBProgressWins;
    winnerId = aWins ? playerAId : playerBId;
    loserId = aWins ? playerBId : playerAId;
    reason = "progress";
  } else if (!bothClearedEverything) {
    // Equal completed objectives and equal discrete progress means both failed
    // at the same competitive position. Gold penalty/refund is phase 2.
    reason = "doubleFail";
  } else if (playerATotalDurationMs !== playerBTotalDurationMs) {
    const aWins = playerATotalDurationMs < playerBTotalDurationMs;
    winnerId = aWins ? playerAId : playerBId;
    loserId = aWins ? playerBId : playerAId;
    reason = "timeTieBreaker";
  } else {
    reason = "exactTie";
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
    playerACompletedGames,
    playerBCompletedGames,
    playerAProgressWins,
    playerBProgressWins,
    scoreDifference: Math.abs(playerATotalScore - playerBTotalScore),
    timeDifferenceMs: Math.abs(playerATotalDurationMs - playerBTotalDurationMs),
    games,
  };
}
