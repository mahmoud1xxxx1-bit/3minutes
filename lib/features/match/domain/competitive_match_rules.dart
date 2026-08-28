class CompetitiveMatchRules {
  const CompetitiveMatchRules._();

  static const Duration matchDuration = Duration(minutes: 3);
  static const int picksPerPlayer = 2;
  static const int gamesPerMatch = 4;
  static const int dailyGoldGrant = 1000;
  static const List<int> wagerTiers = <int>[180, 500, 1000];

  static bool isValidWager(int gold) => wagerTiers.contains(gold);

  /// Both players stake the same GOLD amount. Settlement is platform-owned.
  static int potFor(int wager) {
    if (!isValidWager(wager)) {
      throw ArgumentError.value(wager, 'wager', 'Unsupported GOLD wager');
    }
    return wager * 2;
  }
}

enum CompetitiveMatchEndReason {
  completed,
  timeExpired,
  surrender,
  disconnectForfeit,
  cancelled,
}

/// Coins and GOLD remain separate economies. GOLD is the stake currency;
/// Coins and RP are additional platform rewards determined after settlement.
class CompetitiveReward {
  const CompetitiveReward({
    required this.gold,
    required this.coins,
    required this.rp,
  });

  final int gold;
  final int coins;
  final int rp;
}
