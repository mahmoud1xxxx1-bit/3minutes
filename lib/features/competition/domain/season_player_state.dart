import 'rank_tier.dart';

class SeasonPlayerState {
  const SeasonPlayerState({
    required this.uid,
    required this.seasonId,
    required this.rankPoints,
    required this.peakTier,
    required this.wins,
    required this.losses,
    required this.gamesPlayed,
    this.ties = 0,
    this.seasonXp = 0,
    this.finalStanding,
  });

  final String uid;
  final String seasonId;
  final int rankPoints;
  final RankTier peakTier;
  final int wins;
  final int losses;
  final int ties;
  final int gamesPlayed;
  final int seasonXp;
  final int? finalStanding;

  double get winRate => gamesPlayed <= 0 ? 0 : wins / gamesPlayed;
}

class SeasonPeakTierPolicy {
  const SeasonPeakTierPolicy._();

  static RankTier nextPeak({
    required RankTier currentPeak,
    required int nextRankPoints,
  }) {
    final nextTier = RankPolicy.tierFor(nextRankPoints);
    return nextTier.index > currentPeak.index ? nextTier : currentPeak;
  }
}
