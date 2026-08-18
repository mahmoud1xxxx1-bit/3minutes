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
}
