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
  });

  final String uid;
  final String seasonId;
  final int rankPoints;
  final RankTier peakTier;
  final int wins;
  final int losses;
  final int gamesPlayed;
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
