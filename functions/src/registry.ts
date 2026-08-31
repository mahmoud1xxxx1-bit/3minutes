export const REGISTRY_VERSION = 7;
export const MATCH_GAME_COUNT = 4;
export const MATCH_DURATION_MS = 180000;

export type GameCategory = "reaction" | "logic" | "memory" | "precision";

export interface GameDescriptor {
  id: string;
  category: GameCategory;
  version: number;
}

export interface MiniGameEvidence {
  gameId: string;
  gameVersion: number;
  gameIndex: number;
  gameSeed: number;
  score: number;
  accuracy: number;
  mistakes: number;
  durationMs: number;
}

// MUST stay equivalent in ordering/category/version semantics to
// lib/features/minigames/data/game_registry.dart for REGISTRY_VERSION 7.
export const APPROVED_GAMES: ReadonlyArray<GameDescriptor> = [
  { id: "find_differences", category: "precision", version: 1 },
  { id: "follow_the_cup", category: "memory", version: 1 },
  { id: "key_escape", category: "logic", version: 1 },
  { id: "level_devil", category: "reaction", version: 1 },
  { id: "mirror_control", category: "precision", version: 1 },
  { id: "mole_strike", category: "reaction", version: 1 },
  { id: "ninja_slice", category: "reaction", version: 1 },
  { id: "onet_connect", category: "logic", version: 1 },
  { id: "path_rush", category: "logic", version: 1 },
  { id: "traffic_loop", category: "logic", version: 1 },
  { id: "hidden_pigeon", category: "precision", version: 1 },
];

const CATEGORIES: ReadonlyArray<GameCategory> = ["reaction", "logic", "memory", "precision"];
const SEED_MIX = 0x45d9f3b;
export const MAX_SCORE_PER_GAME = 1000;

class DeterministicRng {
  private state: number;
  constructor(seed: number) { this.state = seed >>> 0; }
  nextUint32(): number {
    this.state = (Math.imul(1664525, this.state) + 1013904223) >>> 0;
    return this.state;
  }
  nextInt(max: number): number {
    if (!Number.isInteger(max) || max <= 0) throw new Error("max must be a positive integer");
    return this.nextUint32() % max;
  }
  shuffle<T>(values: T[]): void {
    for (let index = values.length - 1; index > 0; index -= 1) {
      const other = this.nextInt(index + 1);
      [values[index], values[other]] = [values[other]!, values[index]!];
    }
  }
}

export function descriptorFor(gameId: string): GameDescriptor | undefined {
  return APPROVED_GAMES.find((game) => game.id === gameId);
}

export function validateLockedGameIds(value: unknown): value is string[] {
  if (!Array.isArray(value) || value.length !== MATCH_GAME_COUNT) return false;
  if (value.some((id) => typeof id !== "string" || !descriptorFor(id))) return false;
  return new Set(value).size === MATCH_GAME_COUNT;
}

export function gameSequence(seed: number, count: number): GameDescriptor[] {
  if (!Number.isInteger(count) || count < 1 || count > APPROVED_GAMES.length) {
    throw new Error("count must fit the approved registry");
  }
  const random = new DeterministicRng(seed);
  if (count < CATEGORIES.length) {
    const shuffled = [...APPROVED_GAMES];
    random.shuffle(shuffled);
    return shuffled.slice(0, count);
  }
  const selected: GameDescriptor[] = [];
  const remaining = [...APPROVED_GAMES];
  for (const category of CATEGORIES) {
    const categoryGames = remaining.filter((game) => game.category === category);
    random.shuffle(categoryGames);
    if (categoryGames.length === 0) throw new Error(`registry is missing ${category}`);
    const pick = categoryGames[0]!;
    selected.push(pick);
    const removeAt = remaining.findIndex((game) => game.id === pick.id);
    remaining.splice(removeAt, 1);
  }
  random.shuffle(remaining);
  selected.push(...remaining.slice(0, count - selected.length));
  random.shuffle(selected);
  return selected;
}

export function gameSeed(matchSeed: number, gameIndex: number): number {
  return (matchSeed ^ Math.imul(gameIndex + 1, SEED_MIX)) | 0;
}

function finiteNumber(value: unknown): value is number {
  return typeof value === "number" && Number.isFinite(value);
}

export function parseEvidence(value: unknown): MiniGameEvidence[] {
  if (!Array.isArray(value)) throw new Error("evidence must be an array");
  return value.map((raw, index) => {
    if (raw === null || typeof raw !== "object") throw new Error(`evidence[${index}] must be an object`);
    const item = raw as Record<string, unknown>;
    const gameId = item.gameId;
    const gameVersion = item.gameVersion;
    const gameIndex = item.gameIndex;
    const evidenceSeed = item.gameSeed;
    const score = item.score;
    const accuracy = item.accuracy;
    const mistakes = item.mistakes;
    const durationMs = item.durationMs;
    if (typeof gameId !== "string" || gameId.length === 0) throw new Error(`evidence[${index}].gameId is invalid`);
    if (!finiteNumber(gameVersion) || !Number.isInteger(gameVersion) || gameVersion < 1) throw new Error(`evidence[${index}].gameVersion is invalid`);
    if (!finiteNumber(gameIndex) || !Number.isInteger(gameIndex)) throw new Error(`evidence[${index}].gameIndex is invalid`);
    if (!finiteNumber(evidenceSeed) || !Number.isInteger(evidenceSeed)) throw new Error(`evidence[${index}].gameSeed is invalid`);
    if (!finiteNumber(score) || !Number.isInteger(score)) throw new Error(`evidence[${index}].score is invalid`);
    if (!finiteNumber(accuracy)) throw new Error(`evidence[${index}].accuracy is invalid`);
    if (!finiteNumber(mistakes) || !Number.isInteger(mistakes)) throw new Error(`evidence[${index}].mistakes is invalid`);
    if (!finiteNumber(durationMs) || !Number.isInteger(durationMs)) throw new Error(`evidence[${index}].durationMs is invalid`);
    return { gameId, gameVersion, gameIndex, gameSeed: evidenceSeed, score, accuracy, mistakes, durationMs };
  });
}

export function validateEvidence(options: {
  matchSeed: number;
  gameCount: number;
  completedGames: number;
  evidence: MiniGameEvidence[];
  lockedGameIds?: string[];
}): boolean {
  const { matchSeed, gameCount, completedGames, evidence, lockedGameIds } = options;
  if (gameCount !== MATCH_GAME_COUNT) return false;
  if (completedGames < 0 || completedGames > gameCount) return false;
  if (evidence.length !== completedGames) return false;
  const expected = lockedGameIds == null
    ? gameSequence(matchSeed, gameCount)
    : validateLockedGameIds(lockedGameIds)
      ? lockedGameIds.map((id) => descriptorFor(id)!)
      : [];
  if (expected.length !== gameCount) return false;
  let totalDuration = 0;
  for (let index = 0; index < evidence.length; index += 1) {
    const item = evidence[index]!;
    const game = expected[index];
    if (!game) return false;
    if (item.gameIndex !== index) return false;
    if (item.gameId !== game.id) return false;
    if (item.gameVersion !== game.version) return false;
    if (item.gameSeed !== gameSeed(matchSeed, index)) return false;
    if (item.score < 0 || item.score > MAX_SCORE_PER_GAME) return false;
    if (item.accuracy < 0 || item.accuracy > 1) return false;
    if (item.mistakes < 0) return false;
    if (item.durationMs < 0 || item.durationMs > MATCH_DURATION_MS) return false;
    totalDuration += item.durationMs;
    if (totalDuration > MATCH_DURATION_MS) return false;
  }
  return true;
}
