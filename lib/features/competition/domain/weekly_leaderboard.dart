enum WeeklyBoardKind { rp, gold }

class WeeklyLeaderboardEntry {
  const WeeklyLeaderboardEntry({
    required this.uid,
    required this.gameName,
    required this.avatarId,
    required this.score,
    required this.matches,
    required this.active,
    this.finalStanding,
    this.rewardGold,
    this.rewardStars,
  });

  final String uid;
  final String gameName;
  final String avatarId;
  final int score;
  final int matches;
  final bool active;
  final int? finalStanding;
  final int? rewardGold;
  final int? rewardStars;
}

class WeeklyLeaderboardPolicy {
  const WeeklyLeaderboardPolicy._();

  static const Duration week = Duration(days: 7);

  static String weekId(DateTime value) {
    final utcMs = value.toUtc().millisecondsSinceEpoch;
    return 'week_${utcMs ~/ week.inMilliseconds}';
  }

  static List<int> displayStandings(Iterable<WeeklyLeaderboardEntry> entries) {
    var position = 0;
    var standing = 0;
    int? previousScore;
    final result = <int>[];
    for (final entry in entries) {
      position += 1;
      if (previousScore == null || previousScore != entry.score) {
        standing = position;
      }
      result.add(standing);
      previousScore = entry.score;
    }
    return List<int>.unmodifiable(result);
  }

  static ({int gold, int stars}) rewardFor(
    WeeklyBoardKind board,
    int standing, {
    required bool active,
  }) {
    if (!active) return (gold: 0, stars: 0);
    if (board == WeeklyBoardKind.rp) {
      return switch (standing) {
        1 => (gold: 3000, stars: 0),
        2 => (gold: 2000, stars: 0),
        3 => (gold: 1500, stars: 0),
        _ => (gold: 300, stars: 0),
      };
    }
    return switch (standing) {
      1 => (gold: 3000, stars: 5),
      2 => (gold: 2500, stars: 1),
      3 => (gold: 2000, stars: 0),
      _ => (gold: 300, stars: 0),
    };
  }
}
