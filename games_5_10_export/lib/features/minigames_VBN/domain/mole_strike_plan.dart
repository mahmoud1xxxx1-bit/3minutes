import '../../../core/random/deterministic_rng.dart';

class MoleStrikeWave {
  const MoleStrikeWave({
    required this.realHole,
    required this.decoyHole,
    required this.visibleMs,
    required this.decoyLagMs,
    required this.gapMs,
  });

  final int realHole;
  final int? decoyHole;
  final int visibleMs;
  final int decoyLagMs;
  final int gapMs;
}

class MoleStrikePlan {
  const MoleStrikePlan({
    required this.familyIndex,
    required this.waves,
  });

  static const int goal = 12;
  static const int familyCount = 48;
  static const int routeCount = 8;
  static const int tempoCount = 6;
  static const int generatedWaveCount = 180;

  final int familyIndex;
  final List<MoleStrikeWave> waves;

  static const List<List<int>> _routes = [
    [0, 1, 2, 5, 8, 7, 6, 3, 4],
    [2, 1, 0, 3, 6, 7, 8, 5, 4],
    [0, 1, 2, 5, 4, 3, 6, 7, 8],
    [6, 3, 0, 1, 4, 7, 8, 5, 2],
    [4, 0, 8, 2, 6, 1, 7, 3, 5],
    [0, 8, 2, 6, 4, 1, 7, 5, 3],
    [0, 4, 8, 2, 4, 6, 1, 4, 7],
    [1, 5, 7, 3, 0, 2, 8, 6, 4],
  ];

  // Multipliers are stored as integer percentages to keep generation
  // cross-platform deterministic and free from floating-point drift.
  static const List<List<int>> _tempos = [
    [98, 104, 100], // steady: gap, visibility, pair chance
    [82, 101, 108], // burst
    [92, 106, 104], // pulse
    [100, 104, 114], // decoy
    [86, 98, 110], // rush
    [96, 108, 106], // wave
  ];

  factory MoleStrikePlan.fromSeed({
    required int seed,
    required int difficulty,
  }) {
    validateCatalog();

    final level = difficulty <= 0 ? 0 : (difficulty >= 2 ? 2 : 1);
    final random = DeterministicRng(seed);
    final familyIndex = random.nextInt(familyCount);
    final route = _routes[familyIndex % routeCount];
    final tempo = _tempos[familyIndex ~/ routeCount];

    const baseVisible = [1030, 820, 660];
    const baseGap = [320, 230, 155];
    const basePairPermille = [440, 700, 860];
    const baseLag = [95, 72, 55];

    final visibleMs = _scale(baseVisible[level], tempo[1]);
    final gapBase = _scale(baseGap[level], tempo[0]);
    final pairPermille = _clamp(
      _scale(basePairPermille[level], tempo[2]),
      0,
      940,
    );
    final routeOffset = random.nextInt(route.length);

    final waves = <MoleStrikeWave>[];
    var lastReal = -1;

    for (var step = 0; step < generatedWaveCount; step++) {
      var realHole = -1;
      for (var attempt = 0; attempt < route.length * 2; attempt++) {
        final candidate = route[(routeOffset + step + attempt) % route.length];
        if (candidate != lastReal) {
          realHole = candidate;
          break;
        }
      }
      if (realHole < 0) {
        throw StateError('Mole Strike could not select a valid real hole.');
      }

      int? decoyHole;
      if (random.nextInt(1000) < pairPermille) {
        final start = random.nextInt(9);
        for (var attempt = 0; attempt < 9; attempt++) {
          final candidate = (start + attempt) % 9;
          if (candidate != realHole) {
            decoyHole = candidate;
            break;
          }
        }
      }

      var gapMs = gapBase + random.nextInt(level == 0 ? 170 : 120);
      final tempoIndex = familyIndex ~/ routeCount;
      if ((tempoIndex == 1 || tempoIndex == 4) && step % 4 == 3) {
        gapMs = _scale(gapMs, tempoIndex == 1 ? 60 : 66);
      } else if (tempoIndex == 2 && step % 3 == 2) {
        gapMs = _scale(gapMs, 72);
      } else if (tempoIndex == 5) {
        gapMs = _scale(gapMs, step % 6 < 3 ? 108 : 72);
      }

      final lagJitter = random.nextInt(level == 0 ? 36 : 26);
      final wave = MoleStrikeWave(
        realHole: realHole,
        decoyHole: decoyHole,
        visibleMs: visibleMs,
        decoyLagMs: decoyHole == null ? 0 : baseLag[level] + lagJitter,
        gapMs: _clamp(gapMs, 70, 700),
      );
      _validateWave(wave, lastReal: lastReal);
      waves.add(wave);
      lastReal = realHole;
    }

    return MoleStrikePlan(
      familyIndex: familyIndex,
      waves: List<MoleStrikeWave>.unmodifiable(waves),
    );
  }

  static int _scale(int value, int percent) => (value * percent) ~/ 100;

  static int _clamp(int value, int minimum, int maximum) {
    if (value < minimum) return minimum;
    if (value > maximum) return maximum;
    return value;
  }

  static void _validateWave(MoleStrikeWave wave, {required int lastReal}) {
    if (wave.realHole < 0 || wave.realHole > 8) {
      throw StateError('Mole Strike real hole is outside the 3x3 grid.');
    }
    if (lastReal == wave.realHole) {
      throw StateError('Mole Strike repeated the real hole consecutively.');
    }
    final decoy = wave.decoyHole;
    if (decoy != null && (decoy < 0 || decoy > 8 || decoy == wave.realHole)) {
      throw StateError('Mole Strike generated an invalid decoy hole.');
    }
    if (wave.visibleMs < 300 || wave.gapMs < 50 || wave.decoyLagMs < 0) {
      throw StateError('Mole Strike generated an invalid timing value.');
    }
  }

  static void validateCatalog() {
    if (_routes.length != routeCount ||
        _tempos.length != tempoCount ||
        routeCount * tempoCount != familyCount) {
      throw StateError('Mole Strike family catalog must contain 48 families.');
    }

    for (var routeIndex = 0; routeIndex < _routes.length; routeIndex++) {
      final route = _routes[routeIndex];
      if (route.length < 9) {
        throw StateError('Mole Strike route $routeIndex is too short.');
      }
      for (var index = 0; index < route.length; index++) {
        final hole = route[index];
        if (hole < 0 || hole > 8) {
          throw StateError('Mole Strike route $routeIndex contains invalid hole.');
        }
        if (index > 0 && route[index - 1] == hole) {
          throw StateError('Mole Strike route $routeIndex repeats a hole.');
        }
      }
    }
  }
}
