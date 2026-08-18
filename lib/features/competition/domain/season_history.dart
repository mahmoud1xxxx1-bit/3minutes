import 'rank_tier.dart';

class SeasonHistoryEntry {
  const SeasonHistoryEntry({
    required this.seasonId,
    required this.seasonNumber,
    required this.peakTier,
    required this.finalRankPoints,
    required this.finalStanding,
    required this.wins,
    required this.losses,
    required this.ties,
    required this.gamesPlayed,
    required this.starsAwarded,
    required this.closedAt,
  });

  final String seasonId;
  final int seasonNumber;
  final RankTier peakTier;
  final int finalRankPoints;
  final int? finalStanding;
  final int wins;
  final int losses;
  final int ties;
  final int gamesPlayed;
  final int starsAwarded;
  final DateTime closedAt;
}

class SeasonHistoryPolicy {
  const SeasonHistoryPolicy._();

  static bool isValid(SeasonHistoryEntry entry) {
    if (entry.seasonId.trim().isEmpty || entry.seasonNumber < 1) return false;
    if (entry.finalRankPoints < 0 || entry.starsAwarded < 0) return false;
    if (entry.wins < 0 || entry.losses < 0 || entry.ties < 0) return false;
    if (entry.gamesPlayed < entry.wins + entry.losses + entry.ties) return false;
    if (entry.finalStanding != null && entry.finalStanding! < 1) return false;
    return true;
  }
}
