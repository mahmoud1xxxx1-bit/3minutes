/// Stable boundary between the 3 Minutes platform and every embedded game.
///
/// Games own gameplay only. The platform owns match timing, wagers, Coins,
/// GOLD, RP, settlement, ranking and final result presentation.
abstract interface class ThreeMinutesGame {
  String get gameId;
  String get displayName;

  Future<GameRunResult> play(GameRunContext context);
}

class GameRunContext {
  const GameRunContext({
    required this.matchId,
    required this.playerId,
    required this.gameId,
    required this.gameIndex,
    required this.totalGames,
    required this.matchDeadline,
  });

  final String matchId;
  final String playerId;
  final String gameId;
  final int gameIndex;
  final int totalGames;
  final DateTime matchDeadline;

  Duration get remaining => matchDeadline.difference(DateTime.now());
}

class GameRunResult {
  const GameRunResult({
    required this.gameId,
    required this.rawScore,
    required this.completed,
    required this.elapsed,
    this.progress = 1,
    this.stats = const <String, num>{},
  });

  final String gameId;
  final num rawScore;
  final bool completed;
  final Duration elapsed;
  final double progress;
  final Map<String, num> stats;
}

/// Converts game-specific scoring into the comparable score owned by the
/// platform. Each future ZIP game can provide its own adapter without
/// changing matchmaking or settlement code.
abstract interface class GameScoreAdapter {
  String get gameId;
  int normalize(GameRunResult result);
}
