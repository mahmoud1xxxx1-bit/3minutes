import 'rank_tier.dart';

class SeasonResetPolicy {
  const SeasonResetPolicy._();

  // Initial launch-tuning values. The server applies these exactly once during
  // season rollover based on the player's peak tier from the closing season.
  static int startingRpForPeakTier(RankTier peakTier) {
    return switch (peakTier) {
      RankTier.bronze => 0,
      RankTier.silver => 250,
      RankTier.gold => 500,
      RankTier.platinum => 800,
      RankTier.diamond => 1100,
      RankTier.master => 1400,
    };
  }
}
