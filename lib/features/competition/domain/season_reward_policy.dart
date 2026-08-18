import 'rank_tier.dart';

class SeasonRewardPolicy {
  const SeasonRewardPolicy._();

  // Persistent stars are identity rewards. They never affect gameplay.
  static int starsForPeakTier(RankTier tier) {
    return switch (tier) {
      RankTier.bronze => 0,
      RankTier.silver => 1,
      RankTier.gold => 2,
      RankTier.platinum => 3,
      RankTier.diamond => 5,
      RankTier.master => 8,
    };
  }

  static int nextPersistentStars({
    required int currentStars,
    required RankTier peakTier,
  }) {
    final safeCurrent = currentStars < 0 ? 0 : currentStars;
    return safeCurrent + starsForPeakTier(peakTier);
  }
}
