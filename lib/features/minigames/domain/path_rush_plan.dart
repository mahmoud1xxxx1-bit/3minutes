import '../../../core/random/deterministic_rng.dart';

class PathPoint {
  const PathPoint(this.x, this.y);
  final double x;
  final double y;
}

class PathAnimal {
  const PathAnimal({required this.id, required this.arName, required this.foodName, required this.foodEmoji, required this.wrong});
  final String id;
  final String arName;
  final String foodName;
  final String foodEmoji;
  final List<(String, String)> wrong;
}

class PathRushRound {
  const PathRushRound({required this.animal, required this.targets, required this.correctTarget, required this.endPermutation, required this.paths, required this.familyIndex});
  final PathAnimal animal;
  final List<(String, String)> targets;
  final int correctTarget;
  final List<int> endPermutation;
  final List<List<PathPoint>> paths;
  final int familyIndex;

  int pathForNumber(int number) {
    if (number == 1) return 2;
    if (number == 2) return 1;
    if (number == 3) return 0;
    throw ArgumentError.value(number, 'number');
  }

  bool isCorrectNumber(int number) => endPermutation[pathForNumber(number)] == correctTarget;
}

class PathRushPlan {
  const PathRushPlan({required this.rounds, required this.travelMs});
  static const int familyCount = 48;
  static const int roundCount = 3;
  final List<PathRushRound> rounds;
  final int travelMs;

  static const _animals = <PathAnimal>[
    PathAnimal(id: 'rabbit', arName: 'الأرنب', foodName: 'جزر', foodEmoji: '🥕', wrong: [('موز','🍌'),('سمك','🐟'),('لحم','🥩'),('جبن','🧀')]),
    PathAnimal(id: 'monkey', arName: 'القرد', foodName: 'موز', foodEmoji: '🍌', wrong: [('جزر','🥕'),('سمك','🐟'),('لحم','🥩'),('خيزران','🎋')]),
    PathAnimal(id: 'lion', arName: 'الأسد', foodName: 'لحم', foodEmoji: '🥩', wrong: [('موز','🍌'),('جزر','🥕'),('تفاح','🍎'),('خيزران','🎋')]),
    PathAnimal(id: 'panda', arName: 'الباندا', foodName: 'خيزران', foodEmoji: '🎋', wrong: [('سمك','🐟'),('لحم','🥩'),('جبن','🧀'),('موز','🍌')]),
    PathAnimal(id: 'cat', arName: 'القط', foodName: 'سمك', foodEmoji: '🐟', wrong: [('جزر','🥕'),('خيزران','🎋'),('تفاح','🍎'),('موز','🍌')]),
    PathAnimal(id: 'dog', arName: 'الكلب', foodName: 'عظمة', foodEmoji: '🦴', wrong: [('جزر','🥕'),('موز','🍌'),('تفاح','🍎'),('خيزران','🎋')]),
  ];

  // The twelve approved V5.3 route families, stored compactly as four interior X knots per lane.
  static const _knots = <List<List<double>>>[
    [[90,315,130,305],[330,120,310,135],[295,95,335,125]],
    [[150,330,205,92],[82,302,112,330],[300,120,315,82]],
    [[118,340,95,280],[348,150,298,120],[280,78,330,165]],
    [[245,350,155,78],[92,280,355,150],[320,110,250,95]],
    [[95,300,355,135],[330,125,280,80],[250,70,210,345]],
    [[180,320,130,350],[330,82,300,120],[250,150,340,75]],
    [[320,110,280,85],[100,350,150,300],[270,80,330,130]],
    [[150,330,110,300],[340,85,320,120],[285,120,350,90]],
    [[120,350,170,320],[330,100,280,75],[250,85,340,145]],
    [[300,140,350,100],[95,330,125,290],[260,75,300,150]],
    [[110,310,90,280],[340,130,325,110],[300,95,345,140]],
    [[180,350,120,300],[320,100,300,90],[250,80,330,150]],
  ];

  static PathRushPlan fromSeed({required int seed, required int difficulty}) {
    final travel = difficulty >= 2 ? 940 : difficulty == 1 ? 1120 : 1320;
    final rounds = <PathRushRound>[];
    for (var roundIndex = 0; roundIndex < roundCount; roundIndex++) {
      final roundSeed = (seed ^ ((roundIndex + 1) * 0x45d9f3b)) & 0xffffffff;
      final random = DeterministicRng(roundSeed);
      final animal = _animals[random.nextInt(_animals.length)];
      final wrong = List<(String,String)>.of(animal.wrong);
      random.shuffle(wrong);
      final targets = <(String,String)>[(animal.foodName, animal.foodEmoji), wrong[0], wrong[1]];
      random.shuffle(targets);
      final correctTarget = targets.indexWhere((x) => x.$1 == animal.foodName);
      final perm = <int>[0,1,2];
      random.shuffle(perm);
      final family = random.nextInt(familyCount);
      final paths = _buildPaths(family, perm);
      final round = PathRushRound(animal: animal, targets: List.unmodifiable(targets), correctTarget: correctTarget,
        endPermutation: List.unmodifiable(perm), paths: List.unmodifiable(paths), familyIndex: family);
      _validateRound(round);
      rounds.add(round);
    }
    return PathRushPlan(rounds: List.unmodifiable(rounds), travelMs: travel);
  }

  static List<List<PathPoint>> _buildPaths(int family, List<int> perm) {
    final baseIndex = family % 12;
    final mode = family ~/ 12;
    final mirror = mode == 1 || mode == 3;
    final wobble = mode == 2 || mode == 3;
    const starts = <double>[42,215,388];
    const ends = <double>[42,215,388];
    const ys = <double>[8,66,112,168,220,272];
    final result = <List<PathPoint>>[];
    for (var lane = 0; lane < 3; lane++) {
      final sourceLane = mirror ? 2 - lane : lane;
      final interior = _knots[baseIndex][sourceLane];
      final points = <PathPoint>[PathPoint(starts[lane], ys[0])];
      for (var i = 0; i < 4; i++) {
        var x = interior[i];
        if (mirror) x = 430 - x;
        if (wobble) x += ((i + lane).isEven ? 10 : -10);
        points.add(PathPoint(x.clamp(24, 406).toDouble(), ys[i + 1]));
      }
      points.add(PathPoint(ends[perm[lane]], ys[5]));
      result.add(List.unmodifiable(points));
    }
    return result;
  }

  static void _validateRound(PathRushRound round) {
    if (round.familyIndex < 0 || round.familyIndex >= familyCount) throw StateError('invalid path family');
    if (round.targets.length != 3 || round.correctTarget < 0 || round.correctTarget > 2) throw StateError('invalid targets');
    final sorted = List<int>.of(round.endPermutation)..sort();
    if (sorted.join(',') != '0,1,2') throw StateError('invalid endpoint permutation');
    const anchors = <double>[42,215,388];
    for (var lane = 0; lane < 3; lane++) {
      final path = round.paths[lane];
      if (path.length != 6 || path.first.x != anchors[lane] || path.first.y != 8) throw StateError('lane anchor mismatch');
      if (path.last.x != anchors[round.endPermutation[lane]] || path.last.y != 272) throw StateError('lane endpoint mismatch');
    }
    final correctNumbers = <int>[1,2,3].where(round.isCorrectNumber).toList();
    if (correctNumbers.length != 1) throw StateError('round must have exactly one correct answer');
  }
}
