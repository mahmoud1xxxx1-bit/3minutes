import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/match/domain/competitive_match_rules.dart';

void main() {
  test('competitive rules keep the approved wager tiers', () {
    expect(CompetitiveMatchRules.wagerTiers, <int>[180, 500, 1000]);
    expect(CompetitiveMatchRules.matchDuration, const Duration(minutes: 3));
    expect(CompetitiveMatchRules.picksPerPlayer, 2);
    expect(CompetitiveMatchRules.gamesPerMatch, 4);
    expect(CompetitiveMatchRules.dailyGoldGrant, 1000);
  });

  test('pot contains equal stakes from both players', () {
    expect(CompetitiveMatchRules.potFor(180), 360);
    expect(CompetitiveMatchRules.potFor(500), 1000);
    expect(CompetitiveMatchRules.potFor(1000), 2000);
  });

  test('unsupported wager is rejected', () {
    expect(() => CompetitiveMatchRules.potFor(250), throwsArgumentError);
  });
}
