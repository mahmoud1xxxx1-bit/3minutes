import '../../match/domain/competitive_match_rules.dart';

class DailyGoldMail {
  const DailyGoldMail({
    required this.id,
    required this.dayKey,
    required this.createdAt,
    required this.claimed,
    this.claimedAt,
    this.amount = CompetitiveMatchRules.dailyGoldGrant,
  });

  final String id;
  final String dayKey;
  final DateTime createdAt;
  final bool claimed;
  final DateTime? claimedAt;
  final int amount;
}

abstract interface class DailyGoldMailBackend {
  Stream<DailyGoldMail?> watchToday(String uid);
  Future<void> claimToday(String uid);
}
