import 'rank_tier.dart';

class SeasonRewardPolicy {
  const SeasonRewardPolicy._();

  // Persistent stars are identity/prestige rewards. They never affect gameplay
  // and cannot be purchased with coins or real money.
  static int starsForPeakTier(RankTier tier) {
    return switch (tier) {
      RankTier.bronze => 1,
      RankTier.silver => 2,
      RankTier.gold => 4,
      RankTier.platinum => 7,
      RankTier.diamond => 11,
      RankTier.master => 16,
      RankTier.grandmaster => 24,
      RankTier.legend => 35,
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
