class MiniGameConfig {
  const MiniGameConfig({
    required this.seed,
    required this.difficulty,
  });

  final int seed;
  final int difficulty;
}

class MiniGameResult {
  const MiniGameResult({
    required this.completed,
    required this.score,
    required this.accuracy,
    required this.mistakes,
    required this.duration,
  });

  final bool completed;
  final int score;
  final double accuracy;
  final int mistakes;
  final Duration duration;
}

class MiniGameDescriptor {
  const MiniGameDescriptor({
    required this.id,
    required this.title,
  });

  final String id;
  final String title;
}
