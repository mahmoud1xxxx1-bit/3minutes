export function validateEvidenceSequence(previousLength: number, currentLength: number, maxGames: number = 10): "ok" | "idempotent" | "invalid" {
  if (currentLength === previousLength) return "idempotent";
  if (currentLength > previousLength && currentLength <= maxGames) return "ok"; // Allow batch submissions for reconnect
  return "invalid";
}

export function computeServerAuthoritativeElapsed(startMs: number | null, nowMs: number, completedGames: number, transitionAllowanceMs: number = 2500): number {
  if (startMs === null) return 0;
  const serverTotalElapsed = nowMs - startMs;
  const totalTransitionTime = completedGames * transitionAllowanceMs;
  return Math.max(0, serverTotalElapsed - totalTransitionTime);
}

export function isSystemFailure(matchRegistryVersion: number | null, serverRegistryVersion: number): boolean {
  if (matchRegistryVersion === null) return false;
  return matchRegistryVersion !== serverRegistryVersion;
}
