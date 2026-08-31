enum WeeklyLeaderboardKind { rp, gold }

class WeeklyLeaderboardEntry {
  const WeeklyLeaderboardEntry({
    required this.uid,
    required this.gameName,
    required this.avatarId,
    required this.score,
    required this.active,
    required this.activityCount,
  });

  final String uid;
  final String gameName;
  final String avatarId;
  final int score;
  final bool active;
  final int activityCount;
}
