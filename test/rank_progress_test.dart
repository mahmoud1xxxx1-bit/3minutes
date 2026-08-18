import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/competition/domain/rank_progress.dart';
import 'package:game/features/competition/domain/rank_tier.dart';

void main() {
  test('rank progress reports next tier distance', () {
    final progress = RankProgressPolicy.forRp(850);

    expect(progress.tier, RankTier.silver);
    expect(progress.tierStartRp, 500);
    expect(progress.nextTierStartRp, 1200);
    expect(progress.rpIntoTier, 350);
    expect(progress.rpToNextTier, 350);
    expect(progress.fraction, 0.5);
  });

  test('grandmaster reports distance to legend', () {
    final progress = RankProgressPolicy.forRp(8500);

    expect(progress.tier, RankTier.grandmaster);
    expect(progress.tierStartRp, 7000);
    expect(progress.nextTierStartRp, 10000);
    expect(progress.rpToNextTier, 1500);
    expect(progress.fraction, 0.5);
  });

  test('legend tier is complete and has no next threshold', () {
    final progress = RankProgressPolicy.forRp(12000);

    expect(progress.tier, RankTier.legend);
    expect(progress.isMaxTier, isTrue);
    expect(progress.rpToNextTier, isNull);
    expect(progress.fraction, 1);
  });
}
