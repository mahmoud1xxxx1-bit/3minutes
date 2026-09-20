import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/competition/domain/rank_tier.dart';
import 'package:game/features/competition/domain/season_rollover_policy.dart';

void main() {
  test('rollover awards permanent stars and soft resets rp', () {
    final preview = SeasonRolloverPolicy.preview(
      currentPersistentStars: 20,
      peakTier: RankTier.diamond,
    );

    expect(preview.starsAwarded, 11);
    expect(preview.nextPersistentStars, 31);
    expect(preview.nextSeasonStartingRp, 1400);
  });

  test('master retains a stronger head start than diamond', () {
    final diamond = SeasonRolloverPolicy.preview(
      currentPersistentStars: 0,
      peakTier: RankTier.diamond,
    );
    final master = SeasonRolloverPolicy.preview(
      currentPersistentStars: 0,
      peakTier: RankTier.master,
    );

    expect(diamond.nextSeasonStartingRp, 1400);
    expect(master.nextSeasonStartingRp, 2200);
    expect(master.nextSeasonStartingRp, greaterThan(diamond.nextSeasonStartingRp));
  });
}
