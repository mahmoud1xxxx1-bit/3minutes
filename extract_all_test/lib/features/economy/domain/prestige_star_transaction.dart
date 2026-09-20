enum PrestigeStarTransactionReason {
  seasonPeakReward,
  reversal,
  adminCorrection,
}

class PrestigeStarTransaction {
  const PrestigeStarTransaction({
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
  final PrestigeStarTransactionReason reason;
  final String referenceId;
  final DateTime createdAt;
}

class PrestigeStarBalancePolicy {
  const PrestigeStarBalancePolicy._();

  static int apply({required int balance, required int delta}) {
    final safeBalance = balance < 0 ? 0 : balance;
    final next = safeBalance + delta;
    if (next < 0) {
      throw StateError('Prestige stars cannot become negative.');
    }
    return next;
  }

  static String seasonTransactionId({
    required String uid,
    required String seasonId,
  }) {
    return 'season:$seasonId:$uid';
  }
}
