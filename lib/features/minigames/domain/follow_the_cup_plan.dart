import '../../../core/random/deterministic_rng.dart';

class CupSwap {
  const CupSwap(this.a, this.b);
  final int a;
  final int b;

  @override
  bool operator ==(Object other) => other is CupSwap && other.a == a && other.b == b;
  @override
  int get hashCode => Object.hash(a, b);
}

class CupRoundPlan {
  const CupRoundPlan({required this.startCup, required this.swaps});
  final int startCup;
  final List<CupSwap> swaps;
}

class FollowTheCupPlan {
  const FollowTheCupPlan({
    required this.familyIndex,
    required this.cupCount,
    required this.moveMs,
    required this.pauseMs,
    required this.rounds,
  });

  static const int familyCount = 48;
  static const int roundCount = 5;

  final int familyIndex;
  final int cupCount;
  final int moveMs;
  final int pauseMs;
  final List<CupRoundPlan> rounds;

  static FollowTheCupPlan fromSeed({required int seed, required int difficulty}) {
    final random = DeterministicRng(seed);
    final family = random.nextInt(familyCount);
    final routeType = family % 8;
    final tempoType = family ~/ 8;
    final hard = difficulty == 1;
    final expert = difficulty >= 2;
    final cups = hard || expert ? 4 : 3;
    final baseMove = expert ? 325 : hard ? 405 : 500;
    final basePause = expert ? 50 : hard ? 70 : 90;
    const tempoMove = <double>[1.00, .94, 1.05, .90, .98, .86];
    const tempoPause = <double>[1.00, .82, 1.08, .72, .92, .66];
    final moveMs = (baseMove * tempoMove[tempoType]).round();
    final pauseMs = (basePause * tempoPause[tempoType]).round();
    final minMoves = expert ? 7 : hard ? 5 : 3;
    final maxMoves = expert ? 8 : hard ? 6 : 4;
    final rounds = <CupRoundPlan>[];

    for (var round = 0; round < roundCount; round++) {
      final start = random.nextInt(cups);
      final count = minMoves + random.nextInt(maxMoves - minMoves + 1);
      final swaps = <CupSwap>[];
      CupSwap? previous;
      for (var step = 0; step < count; step++) {
        var swap = _swapFor(routeType, step, cups, random);
        if (previous != null && _samePair(previous, swap) && cups > 2) {
          final a = (swap.a + 1) % (cups - 1);
          swap = CupSwap(a, a + 1);
        }
        swaps.add(swap);
        previous = swap;
      }
      rounds.add(CupRoundPlan(startCup: start, swaps: List.unmodifiable(swaps)));
    }

    final plan = FollowTheCupPlan(
      familyIndex: family,
      cupCount: cups,
      moveMs: moveMs,
      pauseMs: pauseMs,
      rounds: List.unmodifiable(rounds),
    );
    plan.validate();
    return plan;
  }

  static CupSwap _swapFor(int type, int step, int cups, DeterministicRng random) {
    switch (type) {
      case 0: // clean chain
        final a = random.nextInt(cups - 1);
        return CupSwap(a, a + 1);
      case 1: // cross sweep
        if (cups == 4) return step.isEven ? const CupSwap(0, 3) : const CupSwap(1, 2);
        return step.isEven ? const CupSwap(0, 2) : const CupSwap(0, 1);
      case 2: // zigzag
        final raw = step % (cups - 1);
        final a = step.isEven ? raw : (cups - 2) - raw;
        return CupSwap(a, a + 1);
      case 3: // edge return
        final a = step.isEven ? 0 : cups - 2;
        return CupSwap(a, a + 1);
      case 4: // rhythm break
        if (step % 3 == 2 && cups > 2) return CupSwap(0, cups - 1);
        final a = random.nextInt(cups - 1);
        return CupSwap(a, a + 1);
      case 5: // reverse tail
        if (step % 4 == 3) return CupSwap(0, cups - 1);
        final a = random.nextInt(cups - 1);
        return CupSwap(a, a + 1);
      case 6: // center pressure
        if (cups == 4) return step.isEven ? const CupSwap(1, 2) : const CupSwap(0, 1);
        return step.isEven ? const CupSwap(0, 1) : const CupSwap(1, 2);
      default: // wide alternation
        if (step.isEven) return CupSwap(0, cups - 1);
        final a = random.nextInt(cups - 1);
        return CupSwap(a, a + 1);
    }
  }

  static bool _samePair(CupSwap a, CupSwap b) {
    final a0 = a.a < a.b ? a.a : a.b;
    final a1 = a.a < a.b ? a.b : a.a;
    final b0 = b.a < b.b ? b.a : b.b;
    final b1 = b.a < b.b ? b.b : b.a;
    return a0 == b0 && a1 == b1;
  }

  int finalPositionFor(CupRoundPlan round, int cupId) {
    final positions = List<int>.generate(cupCount, (index) => index);
    for (final swap in round.swaps) {
      for (var id = 0; id < positions.length; id++) {
        if (positions[id] == swap.a) {
          positions[id] = swap.b;
        } else if (positions[id] == swap.b) {
          positions[id] = swap.a;
        }
      }
    }
    return positions[cupId];
  }

  void validate() {
    if (familyIndex < 0 || familyIndex >= familyCount) throw StateError('invalid family');
    if (rounds.length != roundCount) throw StateError('Follow the Cup must have 5 rounds');
    if (cupCount != 3 && cupCount != 4) throw StateError('invalid cup count');
    for (final round in rounds) {
      if (round.startCup < 0 || round.startCup >= cupCount) throw StateError('invalid target cup');
      for (final swap in round.swaps) {
        if (swap.a < 0 || swap.b < 0 || swap.a >= cupCount || swap.b >= cupCount || swap.a == swap.b) {
          throw StateError('invalid cup swap');
        }
      }
      final end = finalPositionFor(round, round.startCup);
      if (end < 0 || end >= cupCount) throw StateError('unsolvable cup round');
    }
  }
}
