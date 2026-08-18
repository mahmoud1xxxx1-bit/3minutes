enum MissionCadence {
  daily,
  weekly,
}

enum MissionMetric {
  matchesPlayed,
  wins,
  friendMatches,
}

class MissionDefinition {
  const MissionDefinition({
    required this.id,
    required this.cadence,
    required this.metric,
    required this.target,
    required this.coinReward,
    required this.seasonXpReward,
  });

  final String id;
  final MissionCadence cadence;
  final MissionMetric metric;
  final int target;
  final int coinReward;
  final int seasonXpReward;
}

class PlayerMissionState {
  const PlayerMissionState({
    required this.missionId,
    required this.windowId,
    required this.progress,
    required this.completed,
    this.claimedAt,
  });

  final String missionId;
  final String windowId;
  final int progress;
  final bool completed;
  final DateTime? claimedAt;
}

class MissionPolicy {
  const MissionPolicy._();

  static PlayerMissionState advance({
    required MissionDefinition definition,
    required PlayerMissionState current,
    required int delta,
  }) {
    if (delta <= 0 || current.completed) return current;
    final rawProgress = current.progress + delta;
    final nextProgress = rawProgress > definition.target
        ? definition.target
        : rawProgress;
    return PlayerMissionState(
      missionId: current.missionId,
      windowId: current.windowId,
      progress: nextProgress,
      completed: nextProgress >= definition.target,
      claimedAt: current.claimedAt,
    );
  }
}
