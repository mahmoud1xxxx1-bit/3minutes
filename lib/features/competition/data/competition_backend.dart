import '../domain/leaderboard_entry.dart';
import '../domain/season.dart';
import '../domain/season_history.dart';

abstract class CompetitionBackend {
  Stream<Season?> watchCurrentSeason();

  Future<List<LeaderboardEntry>> loadLeaderboard({int limit = 100});

  Stream<LeaderboardEntry?> watchPlayerCompetition(String uid);

  Future<List<SeasonHistoryEntry>> loadSeasonHistory(
    String uid, {
    int limit = 12,
  });
}
