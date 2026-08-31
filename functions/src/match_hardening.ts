export function validateEvidenceSequence(previousLength: number, currentLength: number): "ok" | "idempotent" | "invalid" {
  if (currentLength === previousLength) return "idempotent";
  if (currentLength === previousLength + 1) return "ok";
  return "invalid";
}

export function validateTimeManipulation(elapsedMs: number, startMs: number | null, nowMs: number, bufferMs: number = 10000): boolean {
  if (startMs === null) return true; // Match hasn't started yet, countdown not recorded
  const realElapsed = nowMs - startMs;
  return elapsedMs <= realElapsed + bufferMs;
}

export function validateTechnicalCancelTime(startMs: number | null, nowMs: number, limitMs: number = 15000): boolean {
  if (startMs === null) return true; // Can cancel anytime before it officially starts
  const realElapsed = nowMs - startMs;
  return realElapsed <= limitMs;
}
