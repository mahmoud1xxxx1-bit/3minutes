import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/competition/domain/leaderboard_entry.dart';
import 'package:game/features/competition/domain/rank_tier.dart';
import 'package:game/features/competition/domain/season_reset_policy.dart';
import 'package:game/features/competition/domain/season_reward_policy.dart';

void main() {
  test('season entry keeps ties separate and counts them as played matches', () {
    const entry = LeaderboardEntry(
      uid: 'player',
      gameName: 'Player',
      avatarId: 'avatar_free_vanguard',
      rankPoints: 1300,
      stars: 7,
      wins: 4,
      losses: 3,
      ties: 2,
      peakTier: RankTier.diamond,
    );

    expect(entry.gamesPlayed, 9);
    expect(entry.tier, RankTier.gold);
    expect(entry.effectivePeakTier, RankTier.diamond);
  });

  test('season close projection is based on peak tier, not current tier', () {
    const currentRp = 1300;
    final currentTier = RankPolicy.tierFor(currentRp);
    const peakTier = RankTier.diamond;

    expect(currentTier, RankTier.gold);
    expect(SeasonRewardPolicy.starsForPeakTier(peakTier), 11);
    expect(SeasonResetPolicy.startingRpForPeakTier(peakTier), 1400);
    expect(
      SeasonRewardPolicy.starsForPeakTier(peakTier),
      greaterThan(SeasonRewardPolicy.starsForPeakTier(currentTier)),
    );
  });
}
