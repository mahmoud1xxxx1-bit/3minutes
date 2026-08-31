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
    this.progressStep = 0,
    this.progressStepCount = 1,
  })  : assert(progressStep >= 0),
        assert(progressStepCount > 0),
        assert(progressStep <= progressStepCount);

  /// True only when the objective of this mini-game is fully completed.
  final bool completed;

  /// Official match points. Competitive games award 1000 only on full
  /// completion; failed attempts may remain at zero while progressStep records
  /// how far the player reached.
  final int score;
  final double accuracy;

  /// Diagnostic performance only. Mistakes/deaths do not silently subtract
  /// match points; they are preserved for the post-match report.
  final int mistakes;
  final Duration duration;

  /// Discrete, human-readable progress used only when the objective was not
  /// completed. Example: Level Devil uses 0..3 for its three rounds.
  final int progressStep;
  final int progressStepCount;

  double get progressFraction => progressStep / progressStepCount;
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
