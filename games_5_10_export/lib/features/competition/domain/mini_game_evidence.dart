class MiniGameEvidence {
  const MiniGameEvidence({
    required this.gameId,
    required this.gameIndex,
    required this.gameSeed,
    required this.score,
    required this.accuracy,
    required this.mistakes,
    required this.durationMs,
  });

  final String gameId;
  final int gameIndex;
  final int gameSeed;
  final int score;
  final double accuracy;
  final int mistakes;
  final int durationMs;

  Map<String, Object> toMap() => {
        'gameId': gameId,
        'gameIndex': gameIndex,
        'gameSeed': gameSeed,
        'score': score,
        'accuracy': accuracy,
        'mistakes': mistakes,
        'durationMs': durationMs,
      };

  factory MiniGameEvidence.fromMap(Map<Object?, Object?> map) {
    return MiniGameEvidence(
      gameId: map['gameId'] as String? ?? '',
      gameIndex: (map['gameIndex'] as num?)?.toInt() ?? -1,
      gameSeed: (map['gameSeed'] as num?)?.toInt() ?? 0,
      score: (map['score'] as num?)?.toInt() ?? 0,
      accuracy: (map['accuracy'] as num?)?.toDouble() ?? 0,
      mistakes: (map['mistakes'] as num?)?.toInt() ?? 0,
      durationMs: (map['durationMs'] as num?)?.toInt() ?? 0,
    );
  }
}
