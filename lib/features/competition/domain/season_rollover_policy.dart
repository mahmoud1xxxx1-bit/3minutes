import 'rank_tier.dart';
import 'season_reset_policy.dart';
import 'season_reward_policy.dart';

class SeasonRolloverPreview {
  const SeasonRolloverPreview({
    required this.peakTier,
    required this.starsAwarded,
    required this.nextPersistentStars,
    required this.nextSeasonStartingRp,
  });

  final RankTier peakTier;
  final int starsAwarded;
  final int nextPersistentStars;
  final int nextSeasonStartingRp;
}

class SeasonRolloverPolicy {
  const SeasonRolloverPolicy._();

  static SeasonRolloverPreview preview({
    required int currentPersistentStars,
    required RankTier peakTier,
  }) {
    final starsAwarded = SeasonRewardPolicy.starsForPeakTier(peakTier);
    return SeasonRolloverPreview(
      peakTier: peakTier,
      starsAwarded: starsAwarded,
      nextPersistentStars: SeasonRewardPolicy.nextPersistentStars(
        currentStars: currentPersistentStars,
        peakTier: peakTier,
      ),
      nextSeasonStartingRp:
          SeasonResetPolicy.startingRpForPeakTier(peakTier),
    );
  }
}
