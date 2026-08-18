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

/// Permanent prestige earned by reaching Legendary in distinct seasons.
///
/// A player can only earn one Legendary completion per season, even if their
/// RP drops below Legendary and they climb back into it multiple times during
/// that same season. The season history is therefore the source of truth.
class LegendaryPrestigePolicy {
  const LegendaryPrestigePolicy._();

  static int count(Iterable<SeasonHistoryEntry> history) {
    final legendarySeasonIds = <String>{};
    for (final entry in history) {
      if (!SeasonHistoryPolicy.isValid(entry)) continue;
      if (entry.peakTier != RankTier.legend) continue;
      legendarySeasonIds.add(entry.seasonId.trim());
    }
    return legendarySeasonIds.length;
  }

  static LegendaryPrestigeLevel levelFor(int legendarySeasons) {
    final safeCount = legendarySeasons < 0 ? 0 : legendarySeasons;
    if (safeCount >= 10) return LegendaryPrestigeLevel.legacy;
    if (safeCount >= 5) return LegendaryPrestigeLevel.aura;
    if (safeCount >= 3) return LegendaryPrestigeLevel.crowned;
    if (safeCount >= 2) return LegendaryPrestigeLevel.doubleHalo;
    if (safeCount >= 1) return LegendaryPrestigeLevel.legendary;
    return LegendaryPrestigeLevel.none;
  }
}

enum LegendaryPrestigeLevel {
  none,
  legendary,
  doubleHalo,
  crowned,
  aura,
  legacy;
}
