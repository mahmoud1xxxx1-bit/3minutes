import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/minigames/domain/follow_the_cup_plan.dart';

void main() {
  test('Follow the Cup has exactly 48 valid deterministic families', () {
    final seen = <int>{};
    for (var seed = 0; seed < 20000 && seen.length < FollowTheCupPlan.familyCount; seed++) {
      final a = FollowTheCupPlan.fromSeed(seed: seed, difficulty: seed % 3);
      final b = FollowTheCupPlan.fromSeed(seed: seed, difficulty: seed % 3);
      seen.add(a.familyIndex);
      expect(a.familyIndex, b.familyIndex);
      expect(a.cupCount, b.cupCount);
      expect(a.moveMs, b.moveMs);
      expect(a.pauseMs, b.pauseMs);
      expect(a.rounds.length, FollowTheCupPlan.roundCount);
      for (var r = 0; r < a.rounds.length; r++) {
        expect(a.rounds[r].startCup, b.rounds[r].startCup);
        expect(a.rounds[r].swaps, b.rounds[r].swaps);
        final end = a.finalPositionFor(a.rounds[r], a.rounds[r].startCup);
        expect(end, inInclusiveRange(0, a.cupCount - 1));
      }
    }
    expect(seen.length, FollowTheCupPlan.familyCount);
  });

  test('3000 Follow the Cup plans never contain an invalid swap', () {
    for (var seed = 0; seed < 3000; seed++) {
      final plan = FollowTheCupPlan.fromSeed(seed: seed * 7919, difficulty: seed % 3);
      plan.validate();
      for (final round in plan.rounds) {
        expect(round.swaps, isNotEmpty);
        for (final swap in round.swaps) {
          expect(swap.a, inInclusiveRange(0, plan.cupCount - 1));
          expect(swap.b, inInclusiveRange(0, plan.cupCount - 1));
          expect(swap.a, isNot(equals(swap.b)));
        }
      }
    }
  });
}
