class MiniGameEvidence {
  const MiniGameEvidence({
    required this.gameId,
    required this.gameVersion,
    required this.gameIndex,
    required this.gameSeed,
    required this.completed,
    required this.progressStep,
    required this.progressStepCount,
    required this.score,
    required this.accuracy,
    required this.mistakes,
    required this.durationMs,
  });

  final String gameId;
  final int gameVersion;
  final int gameIndex;
  final int gameSeed;
  final bool completed;
  final int progressStep;
  final int progressStepCount;
  final int score;
  final double accuracy;
  final int mistakes;
  final int durationMs;

  Map<String, Object> toMap() => {
        'gameId': gameId,
        'gameVersion': gameVersion,
        'gameIndex': gameIndex,
        'gameSeed': gameSeed,
        'completed': completed,
        'progressStep': progressStep,
        'progressStepCount': progressStepCount,
        'score': score,
        'accuracy': accuracy,
        'mistakes': mistakes,
        'durationMs': durationMs,
      };

  factory MiniGameEvidence.fromMap(Map<Object?, Object?> map) {
    return MiniGameEvidence(
      gameId: map['gameId'] as String? ?? '',
      gameVersion: (map['gameVersion'] as num?)?.toInt() ?? 1,
      gameIndex: (map['gameIndex'] as num?)?.toInt() ?? -1,
      gameSeed: (map['gameSeed'] as num?)?.toInt() ?? 0,
      completed: map['completed'] as bool? ?? false,
      progressStep: (map['progressStep'] as num?)?.toInt() ?? 0,
      progressStepCount: (map['progressStepCount'] as num?)?.toInt() ?? 1,
      score: (map['score'] as num?)?.toInt() ?? 0,
      accuracy: (map['accuracy'] as num?)?.toDouble() ?? 0,
      mistakes: (map['mistakes'] as num?)?.toInt() ?? 0,
      durationMs: (map['durationMs'] as num?)?.toInt() ?? 0,
    );
  }
}
