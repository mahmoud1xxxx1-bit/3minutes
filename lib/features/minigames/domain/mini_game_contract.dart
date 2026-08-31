enum MiniGameCategory {
  reaction,
  logic,
  memory,
  precision,
}

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
    required this.category,
    this.version = 1,
  }) : assert(version > 0);

  /// Stable identifier. Once released it must never be reused for a different
  /// game because match receipts and server evidence refer to it permanently.
  final String id;
  final String title;
  final MiniGameCategory category;

  /// Contract version of this mini-game. Existing callers default to v1, so
  /// adding versioning does not break the current production catalog.
  final int version;
}
