enum CoinTransactionReason {
  matchReward,
  firstWinReward,
  levelReward,
  dailyMissionReward,
  weeklyMissionReward,
  achievementReward,
  seasonPassReward,
  purchase,
  seasonReward,
  premiumCoinPack,
  adminGrant,
  reversal,
}

class CoinTransaction {
  const CoinTransaction({
    required this.id,
    required this.uid,
    required this.delta,
    required this.reason,
    required this.referenceId,
    required this.createdAt,
  });

  final String id;
  final String uid;
  final int delta;
  final CoinTransactionReason reason;
  final String referenceId;
  final DateTime createdAt;

  bool get isCredit => delta > 0;
  bool get isDebit => delta < 0;
}

class CoinBalancePolicy {
  const CoinBalancePolicy._();

  static int apply({required int balance, required int delta}) {
    final safeBalance = balance < 0 ? 0 : balance;
    final next = safeBalance + delta;
    if (next < 0) {
      throw StateError('Coin balance cannot become negative.');
    }
    return next;
  }
}
