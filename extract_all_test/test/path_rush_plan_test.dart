import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/minigames/domain/path_rush_plan.dart';

void main() {
  test('Path Rush exposes 48 valid families and one correct number per round', () {
    final seen = <int>{};
    for (var seed = 0; seed < 20000 && seen.length < PathRushPlan.familyCount; seed++) {
      final plan = PathRushPlan.fromSeed(seed: seed, difficulty: seed % 3);
      expect(plan.rounds.length, PathRushPlan.roundCount);
      for (final round in plan.rounds) {
        seen.add(round.familyIndex);
        final correct = <int>[1, 2, 3].where(round.isCorrectNumber).toList();
        expect(correct.length, 1);
        expect(round.pathForNumber(1), 2);
        expect(round.pathForNumber(2), 1);
        expect(round.pathForNumber(3), 0);
        expect(round.targets[round.correctTarget].$1, round.animal.foodName);
      }
    }
    expect(seen.length, PathRushPlan.familyCount);
  });

  test('5000 Path Rush plans never produce an invalid answer or lane anchor', () {
    for (var seed = 0; seed < 5000; seed++) {
      final plan = PathRushPlan.fromSeed(seed: seed * 3571, difficulty: seed % 3);
      for (final round in plan.rounds) {
        final correct = <int>[1, 2, 3].where(round.isCorrectNumber).toList();
        expect(correct.length, 1);
        expect(round.paths[0].first.x, 42);
        expect(round.paths[1].first.x, 215);
        expect(round.paths[2].first.x, 388);
        final sorted = List<int>.of(round.endPermutation)..sort();
        expect(sorted, [0, 1, 2]);
      }
    }
  });
}
