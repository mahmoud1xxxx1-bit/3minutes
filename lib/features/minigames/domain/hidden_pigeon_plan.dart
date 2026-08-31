import 'dart:math';

import '../../../core/random/deterministic_rng.dart';

class HiddenPigeonRound {
  final String imageAsset;
  final List<Point<double>> pigeons;

  const HiddenPigeonRound({
    required this.imageAsset,
    required this.pigeons,
  });
}

class HiddenPigeonPlan {
  final int seed;
  final List<HiddenPigeonRound> rounds;

  const HiddenPigeonPlan({required this.seed, required this.rounds});

  static HiddenPigeonPlan fromSeed(int seed, int difficulty) {
    final rng = DeterministicRng(seed);

    // Three deterministic rounds. The asset name stays stable for a given
    // round so the competitive contract can replay the same plan later.
    final rounds = <HiddenPigeonRound>[];

    for (int i = 0; i < 3; i++) {
      final imageAsset = 'assets/hidden_pigeon/round_${i + 1}.jpg';

      final pigeons = <Point<double>>[];
      while (pigeons.length < 10) {
        final x = 0.05 + (rng.nextInt(1000000) / 1000000.0) * 0.9;
        final y = 0.05 + (rng.nextInt(1000000) / 1000000.0) * 0.9;
        final newPoint = Point(x, y);

        var overlap = false;
        for (final p in pigeons) {
          if (newPoint.distanceTo(p) < 0.1) {
            overlap = true;
            break;
          }
        }

        if (!overlap) pigeons.add(newPoint);
      }

      rounds.add(HiddenPigeonRound(imageAsset: imageAsset, pigeons: pigeons));
    }

    return HiddenPigeonPlan(seed: seed, rounds: rounds);
  }
}
