import { HttpsError } from "firebase-functions/v2/https";

export type CompetitiveGameScorePolicy = Readonly<{
  gameId: string;
  minNormalizedScore: number;
  maxNormalizedScore: number;
  maxRawScoreAbs?: number;
}>;

// Intentionally empty until the approved ZIP games are integrated.
// Every production game must be registered here as well as in the Flutter
// GameIntegrationCatalog. This prevents a modified client from inventing an
// arbitrary game id or an unbounded normalized score.
const POLICIES = new Map<string, CompetitiveGameScorePolicy>([
  // ["example_game", { gameId: "example_game", minNormalizedScore: 0, maxNormalizedScore: 1000 }],
]);

export function registeredCompetitiveGameIds(): readonly string[] {
  return [...POLICIES.keys()];
}

export function requireCompetitiveGamePolicy(gameId: string): CompetitiveGameScorePolicy {
  const policy = POLICIES.get(gameId);
  if (!policy) {
    throw new HttpsError("failed-precondition", "Game is not registered for competitive scoring.");
  }
  return policy;
}

export function validateCompetitiveGameScore(
  gameId: string,
  normalizedScore: number,
  rawScore: number,
): void {
  const policy = requireCompetitiveGamePolicy(gameId);
  if (
    normalizedScore < policy.minNormalizedScore ||
    normalizedScore > policy.maxNormalizedScore
  ) {
    throw new HttpsError("invalid-argument", "Normalized score is outside the registered game policy.");
  }

  const rawLimit = policy.maxRawScoreAbs;
  if (rawLimit != null && Math.abs(rawScore) > rawLimit) {
    throw new HttpsError("invalid-argument", "Raw score is outside the registered game policy.");
  }
}
