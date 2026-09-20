import '../domain/achievement.dart';

class AchievementCatalog {
  const AchievementCatalog._();

  static const definitions = <AchievementDefinition>[
    AchievementDefinition(id: 'first_win', metric: AchievementMetric.wins, target: 1, coinReward: 100, titleId: 'title_first_win'),
    AchievementDefinition(id: 'wins_10', metric: AchievementMetric.wins, target: 10, coinReward: 250),
    AchievementDefinition(id: 'wins_100', metric: AchievementMetric.wins, target: 100, coinReward: 1000, titleId: 'title_centurion'),
    AchievementDefinition(id: 'wins_500', metric: AchievementMetric.wins, target: 500, coinReward: 3000, titleId: 'title_veteran'),
    AchievementDefinition(id: 'matches_1000', metric: AchievementMetric.matches, target: 1000, coinReward: 5000, titleId: 'title_marathon'),
    AchievementDefinition(id: 'streak_10', metric: AchievementMetric.winStreak, target: 10, coinReward: 1500, titleId: 'title_unstoppable'),
    AchievementDefinition(id: 'friend_matches_50', metric: AchievementMetric.friendMatches, target: 50, coinReward: 750),
    AchievementDefinition(id: 'six_player_wins_10', metric: AchievementMetric.sixPlayerWins, target: 10, coinReward: 1200),
    AchievementDefinition(id: 'seasons_10', metric: AchievementMetric.seasonsCompleted, target: 10, coinReward: 4000, titleId: 'title_seasoned'),
    AchievementDefinition(id: 'prestige_100', metric: AchievementMetric.prestigeStars, target: 100, coinReward: 3000, titleId: 'title_prestige'),
  ];

  static AchievementDefinition? byId(String id) {
    for (final definition in definitions) {
      if (definition.id == id) return definition;
    }
    return null;
  }
}
