import 'leaderboard_entry.dart';

class LeaderboardPolicy {
  const LeaderboardPolicy._();

  static int compare(LeaderboardEntry a, LeaderboardEntry b) {
    final rp = b.rankPoints.compareTo(a.rankPoints);
    if (rp != 0) return rp;

    final wins = b.wins.compareTo(a.wins);
    if (wins != 0) return wins;

    final losses = a.losses.compareTo(b.losses);
    if (losses != 0) return losses;

    return a.uid.compareTo(b.uid);
  }

  static List<LeaderboardEntry> sorted(Iterable<LeaderboardEntry> entries) {
    final result = List<LeaderboardEntry>.of(entries);
    result.sort(compare);
    return List<LeaderboardEntry>.unmodifiable(result);
  }
}
