import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/competition/domain/rank_tier.dart';
import 'package:game/features/competition/domain/season_player_state.dart';

void main() {
  test('peak tier only moves upward during a season', () {
    expect(
      SeasonPeakTierPolicy.nextPeak(
        currentPeak: RankTier.gold,
        nextRankPoints: 2400,
      ),
      RankTier.diamond,
    );

    expect(
      SeasonPeakTierPolicy.nextPeak(
        currentPeak: RankTier.diamond,
        nextRankPoints: 800,
      ),
      RankTier.diamond,
    );
  });
}
