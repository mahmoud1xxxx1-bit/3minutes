import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/minigames/domain/mole_strike_plan.dart';

void main() {
  test('Mole Strike V6 catalog contains exactly 48 valid families', () {
    expect(MoleStrikePlan.familyCount, 48);
    expect(
      MoleStrikePlan.routeCount * MoleStrikePlan.tempoCount,
      MoleStrikePlan.familyCount,
    );
    expect(MoleStrikePlan.goal, 12);
    expect(MoleStrikePlan.validateCatalog, returnsNormally);
  });

  test('same seed and difficulty generate exactly the same plan', () {
    for (var difficulty = 0; difficulty <= 2; difficulty++) {
      const seeds = [0, 1, 7, 48, 20260818, 0x7fffffff, -1];
      for (final seed in seeds) {
        final first = MoleStrikePlan.fromSeed(
          seed: seed,
          difficulty: difficulty,
        );
        final second = MoleStrikePlan.fromSeed(
          seed: seed,
          difficulty: difficulty,
        );

        expect(first.familyIndex, second.familyIndex);
        expect(first.waves.length, second.waves.length);
        for (var index = 0; index < 80; index++) {
          final a = first.waves[index];
          final b = second.waves[index];
          expect(a.realHole, b.realHole);
          expect(a.decoyHole, b.decoyHole);
          expect(a.visibleMs, b.visibleMs);
          expect(a.decoyLagMs, b.decoyLagMs);
          expect(a.gapMs, b.gapMs);
        }
      }
    }
  });

  test('3000 generated plans never contain an invalid target or decoy', () {
    final seenFamilies = <int>{};

    for (var difficulty = 0; difficulty <= 2; difficulty++) {
      for (var seed = 0; seed < 1000; seed++) {
        final plan = MoleStrikePlan.fromSeed(
          seed: seed,
          difficulty: difficulty,
        );
        seenFamilies.add(plan.familyIndex);

        expect(plan.waves.length, MoleStrikePlan.generatedWaveCount);
        var previousReal = -1;
        for (final wave in plan.waves) {
          expect(wave.realHole, inInclusiveRange(0, 8));
          expect(wave.realHole, isNot(previousReal));
          expect(wave.visibleMs, greaterThanOrEqualTo(300));
          expect(wave.gapMs, inInclusiveRange(70, 700));
          expect(wave.decoyLagMs, greaterThanOrEqualTo(0));

          final decoy = wave.decoyHole;
          if (decoy != null) {
            expect(decoy, inInclusiveRange(0, 8));
            expect(decoy, isNot(wave.realHole));
            expect(wave.decoyLagMs, greaterThan(0));
          } else {
            expect(wave.decoyLagMs, 0);
          }
          previousReal = wave.realHole;
        }
      }
    }

    expect(seenFamilies.length, MoleStrikePlan.familyCount);
  });
}
