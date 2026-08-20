import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/minigames/domain/find_differences_plan.dart';

void main() {
  test('Scene 01 exposes exactly twelve approved fixed variants', () {
    expect(FindDifferencesPlan.variantCount, 12);
    expect(FindDifferencesPlan.variants.length, 12);
    for (final variant in FindDifferencesPlan.variants) {
      expect(variant.length, 5);
      expect(variant.toSet().length, 5);
      for (final id in variant) {
        expect(FindDifferencesPlan.catalog.containsKey(id), isTrue, reason: id);
      }
    }
  });

  test('difficulty maps to approved 3 4 5 difference counts', () {
    expect(FindDifferencesPlan.fromSeed(seed: 123, difficulty: 0).differences.length, 3);
    expect(FindDifferencesPlan.fromSeed(seed: 123, difficulty: 1).differences.length, 4);
    expect(FindDifferencesPlan.fromSeed(seed: 123, difficulty: 2).differences.length, 5);
  });

  test('same seed produces identical variant and difference order', () {
    final a = FindDifferencesPlan.fromSeed(seed: 20260820, difficulty: 2);
    final b = FindDifferencesPlan.fromSeed(seed: 20260820, difficulty: 2);
    expect(a.variantIndex, b.variantIndex);
    expect(a.differences.map((d) => d.id), b.differences.map((d) => d.id));
  });

  test('every approved difference center hits itself and cannot score twice', () {
    for (final difference in FindDifferencesPlan.catalog.values) {
      expect(difference.contains(difference.centerX, difference.centerY), isTrue,
          reason: difference.id);
    }
    final plan = FindDifferencesPlan.fromSeed(seed: 20260820, difficulty: 2);
    final first = plan.differences.first;
    expect(plan.hitTest(first.centerX, first.centerY, const <String>{})?.id, first.id);
    expect(plan.hitTest(first.centerX, first.centerY, <String>{first.id}), isNull);
  });

  test('out of scene coordinates never count as a difference', () {
    final plan = FindDifferencesPlan.fromSeed(seed: 20260820, difficulty: 2);
    expect(plan.hitTest(-1, 100, const <String>{}), isNull);
    expect(plan.hitTest(801, 100, const <String>{}), isNull);
    expect(plan.hitTest(100, -1, const <String>{}), isNull);
    expect(plan.hitTest(100, 601, const <String>{}), isNull);
  });
}
