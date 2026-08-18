import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/competition/domain/rank_progress.dart';
import 'package:game/features/competition/domain/rank_tier.dart';

void main() {
  test('rank progress reports next tier distance', () {
    final progress = RankProgressPolicy.forRp(750);

    expect(progress.tier, RankTier.silver);
    expect(progress.tierStartRp, 500);
    expect(progress.nextTierStartRp, 1000);
    expect(progress.rpIntoTier, 250);
    expect(progress.rpToNextTier, 250);
    expect(progress.fraction, 0.5);
  });

  test('master tier is complete and has no next threshold', () {
    final progress = RankProgressPolicy.forRp(4000);

    expect(progress.tier, RankTier.master);
    expect(progress.isMaxTier, isTrue);
    expect(progress.rpToNextTier, isNull);
    expect(progress.fraction, 1);
  });
}
