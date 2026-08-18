class MatchProgress {
  const MatchProgress({
    required this.completedGames,
    required this.totalScore,
    required this.accuracyTotal,
    required this.mistakes,
    required this.elapsedMs,
    this.completedAt,
  });

  const MatchProgress.empty()
      : completedGames = 0,
        totalScore = 0,
        accuracyTotal = 0,
        mistakes = 0,
        elapsedMs = 0,
        completedAt = null;

  final int completedGames;
  final int totalScore;
  final double accuracyTotal;
  final int mistakes;
  final int elapsedMs;
  final DateTime? completedAt;

  double get averageAccuracy =>
      completedGames == 0 ? 0 : accuracyTotal / completedGames;

  MatchProgress copyWith({
    int? completedGames,
    int? totalScore,
    double? accuracyTotal,
    int? mistakes,
    int? elapsedMs,
    DateTime? completedAt,
  }) {
    return MatchProgress(
      completedGames: completedGames ?? this.completedGames,
      totalScore: totalScore ?? this.totalScore,
      accuracyTotal: accuracyTotal ?? this.accuracyTotal,
      mistakes: mistakes ?? this.mistakes,
      elapsedMs: elapsedMs ?? this.elapsedMs,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
