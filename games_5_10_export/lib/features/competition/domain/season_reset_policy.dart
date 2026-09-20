import 'rank_tier.dart';

class SeasonResetPolicy {
  const SeasonResetPolicy._();

  // The reset is based on peak tier, not final-day tier. Strong players keep a
  // meaningful head start while every season still creates room to climb.
  static int startingRpForPeakTier(RankTier peakTier) {
    return switch (peakTier) {
      RankTier.bronze => 0,
      RankTier.silver => 250,
      RankTier.gold => 500,
      RankTier.platinum => 900,
      RankTier.diamond => 1400,
      RankTier.master => 2200,
      RankTier.grandmaster => 3500,
      RankTier.legend => 5000,
    };
  }
}
