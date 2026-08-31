export function validateEvidenceSequence(previousLength: number, currentLength: number): "ok" | "idempotent" | "invalid" {
  if (currentLength === previousLength) return "idempotent";
  if (currentLength === previousLength + 1) return "ok";
  return "invalid";
}

export function computeAuthoritativeTime(clientElapsedMs: number, startMs: number | null, nowMs: number, latencyBufferMs: number = 3000): number {
  if (startMs === null) return clientElapsedMs; // Cannot verify if countdown hasn't started
  const serverElapsed = nowMs - startMs;
  
  // Prevent under-reporting (Fake fast times)
  const minimumAllowedMs = Math.max(0, serverElapsed - latencyBufferMs);
  
  // Prevent over-reporting (Fake slow times, or extreme network delay)
  const maximumAllowedMs = serverElapsed + latencyBufferMs;

  if (clientElapsedMs < minimumAllowedMs) return minimumAllowedMs;
  if (clientElapsedMs > maximumAllowedMs) return maximumAllowedMs;
  
  return clientElapsedMs;
}

export function validateTechnicalCancelTime(startMs: number | null, nowMs: number, limitMs: number = 15000): boolean {
  if (startMs === null) return true; // Can cancel anytime before it officially starts
  const realElapsed = nowMs - startMs;
  return realElapsed <= limitMs;
}
