import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/competition/domain/rank_tier.dart';
import 'package:game/features/competition/domain/season_rollover_policy.dart';

void main() {
  test('rollover awards permanent stars and soft resets rp', () {
    final preview = SeasonRolloverPolicy.preview(
      currentPersistentStars: 20,
      peakTier: RankTier.diamond,
    );

    expect(preview.starsAwarded, 5);
    expect(preview.nextPersistentStars, 25);
    expect(preview.nextSeasonStartingRp, 1100);
  });
}
