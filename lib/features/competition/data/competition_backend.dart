import '../domain/leaderboard_entry.dart';
import '../domain/season.dart';
import '../domain/season_history.dart';
import '../domain/weekly_leaderboard_entry.dart';

abstract class CompetitionBackend {
  Stream<Season?> watchCurrentSeason();

  Future<List<LeaderboardEntry>> loadLeaderboard({int limit = 100});

  Future<List<WeeklyLeaderboardEntry>> loadWeeklyLeaderboard(
    WeeklyLeaderboardKind kind, {
    int limit = 100,
  });

  Stream<LeaderboardEntry?> watchPlayerCompetition(String uid);

  Future<List<SeasonHistoryEntry>> loadSeasonHistory(
    String uid, {
    int limit = 12,
  });
}
