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
  const PathRushRound({required this.animal, required this.targets, required this.correctTarget, required this.endPermutation, required this.paths});
  final PathAnimal animal;
  final List<(String, String)> targets;
  final int correctTarget;
  final List<int> endPermutation;
  final List<List<PathPoint>> paths;

  int pathForNumber(int number) {
    return 4 - number; 
  }

  bool isCorrectNumber(int number) => endPermutation[pathForNumber(number)] == correctTarget;
}

class PathRushPlan {
  const PathRushPlan({required this.rounds, required this.travelMs});
  static const int roundCount = 3;
  final List<PathRushRound> rounds;
  final int travelMs;

  static const _animals = <PathAnimal>[
    PathAnimal(id: 'rabbit', arName: 'أرنب', foodName: 'جزر', foodEmoji: '🥕', wrong: [('موز','🍌'),('عظم','🦴'),('لحم','🥩'),('عشب','🌿')]),
    PathAnimal(id: 'monkey', arName: 'قرد', foodName: 'موز', foodEmoji: '🍌', wrong: [('جزر','🥕'),('عظم','🦴'),('لحم','🥩'),('خيزران','🎍')]),
    PathAnimal(id: 'lion', arName: 'أسد', foodName: 'لحم', foodEmoji: '🥩', wrong: [('موز','🍌'),('جزر','🥕'),('تفاح','🍎'),('خيزران','🎍')]),
    PathAnimal(id: 'panda', arName: 'باندا', foodName: 'خيزران', foodEmoji: '🎍', wrong: [('عظم','🦴'),('لحم','🥩'),('عشب','🌿'),('موز','🍌')]),
    PathAnimal(id: 'cat', arName: 'قط', foodName: 'عظم', foodEmoji: '🦴', wrong: [('جزر','🥕'),('خيزران','🎍'),('تفاح','🍎'),('موز','🍌')]),
    PathAnimal(id: 'dog', arName: 'كلب', foodName: 'عظمة', foodEmoji: '🦴', wrong: [('جزر','🥕'),('موز','🍌'),('تفاح','🍎'),('خيزران','🎍')]),
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
      
      final targets = <(String,String)>[(animal.foodName, animal.foodEmoji), wrong[0], wrong[1], wrong[2]];
      random.shuffle(targets);
      
      final correctTarget = targets.indexWhere((x) => x.$1 == animal.foodName);
      
      final perm = <int>[0,1,2,3];
      random.shuffle(perm);
      
      final paths = _buildPaths(random, perm);
      final round = PathRushRound(animal: animal, targets: List.unmodifiable(targets), correctTarget: correctTarget, endPermutation: List.unmodifiable(perm), paths: List.unmodifiable(paths));
      rounds.add(round);
    }
    return PathRushPlan(rounds: List.unmodifiable(rounds), travelMs: travel);
  }

  static List<List<PathPoint>> _buildPaths(DeterministicRng random, List<int> perm) {
    const starts = <double>[42, 157, 272, 388];
    const ends = <double>[42, 157, 272, 388];
    const ys = <double>[8, 45, 82, 120, 160, 200, 235, 272];
    
    final result = <List<PathPoint>>[];
    for (var lane = 0; lane < 4; lane++) {
      final points = <PathPoint>[PathPoint(starts[lane], ys[0])];
      for (var i = 0; i < 6; i++) {
        double r = random.nextInt(1000) / 1000.0;
        double x = 24.0 + r * 382.0;
        points.add(PathPoint(x, ys[i + 1]));
      }
      points.add(PathPoint(ends[perm[lane]], ys[7]));
      result.add(List.unmodifiable(points));
    }
    return result;
  }
}
