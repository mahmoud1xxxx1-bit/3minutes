enum AchievementMetric {
  wins,
  matches,
  winStreak,
  rankReached,
  seasonsCompleted,
  friendMatches,
  sixPlayerWins,
  prestigeStars,
}

class AchievementDefinition {
  const AchievementDefinition({
    required this.id,
    required this.metric,
    required this.target,
    this.coinReward = 0,
    this.titleId,
    this.badgeCosmeticId,
  });

  final String id;
  final AchievementMetric metric;
  final int target;
  final int coinReward;
  final String? titleId;
  final String? badgeCosmeticId;
}

class PlayerAchievement {
  const PlayerAchievement({
    required this.achievementId,
    required this.progress,
    required this.completed,
    this.completedAt,
    this.rewardClaimedAt,
  });

  final String achievementId;
  final int progress;
  final bool completed;
  final DateTime? completedAt;
  final DateTime? rewardClaimedAt;
}

class AchievementPolicy {
  const AchievementPolicy._();

  static PlayerAchievement advance({
    required AchievementDefinition definition,
    required PlayerAchievement current,
    required int newProgress,
    required DateTime now,
  }) {
    final safeProgress = newProgress < current.progress ? current.progress : newProgress;
    final completed = current.completed || safeProgress >= definition.target;
    return PlayerAchievement(
      achievementId: current.achievementId,
      progress: safeProgress,
      completed: completed,
      completedAt: current.completedAt ?? (completed ? now : null),
      rewardClaimedAt: current.rewardClaimedAt,
    );
  }
}
