class SettlementIdempotency {
  const SettlementIdempotency._();

  static String keyForMatch(String matchId) {
    final cleaned = matchId.trim();
    if (cleaned.isEmpty) {
      throw ArgumentError('matchId must not be empty.');
    }
    return cleaned;
  }

  static bool canCreate({required bool settlementAlreadyExists}) =>
      !settlementAlreadyExists;
}
