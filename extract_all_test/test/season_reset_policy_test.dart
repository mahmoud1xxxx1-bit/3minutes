import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/competition/domain/rank_tier.dart';
import 'package:game/features/competition/domain/season_reset_policy.dart';

void main() {
  test('higher peak tiers retain a higher next-season starting point', () {
    final starts = RankTier.values
        .map(SeasonResetPolicy.startingRpForPeakTier)
        .toList();

    for (var i = 1; i < starts.length; i++) {
      expect(starts[i], greaterThan(starts[i - 1]));
    }
    expect(starts.first, 0);
    expect(starts.last, 5000);
  });
}
