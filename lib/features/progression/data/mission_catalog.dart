import '../domain/mission.dart';

class MissionCatalog {
  const MissionCatalog._();

  static const definitions = <MissionDefinition>[
    MissionDefinition(id: 'daily_play_3', cadence: MissionCadence.daily, metric: MissionMetric.matchesPlayed, target: 3, coinReward: 60, seasonXpReward: 80),
    MissionDefinition(id: 'daily_win_1', cadence: MissionCadence.daily, metric: MissionMetric.wins, target: 1, coinReward: 75, seasonXpReward: 100),
    MissionDefinition(id: 'daily_friend_1', cadence: MissionCadence.daily, metric: MissionMetric.friendMatches, target: 1, coinReward: 50, seasonXpReward: 70),
    MissionDefinition(id: 'weekly_play_30', cadence: MissionCadence.weekly, metric: MissionMetric.matchesPlayed, target: 30, coinReward: 450, seasonXpReward: 700),
    MissionDefinition(id: 'weekly_win_15', cadence: MissionCadence.weekly, metric: MissionMetric.wins, target: 15, coinReward: 600, seasonXpReward: 900),
    MissionDefinition(id: 'weekly_friend_5', cadence: MissionCadence.weekly, metric: MissionMetric.friendMatches, target: 5, coinReward: 350, seasonXpReward: 550),
  ];
}
