import 'match_result_engine.dart';

class MatchGameReceipt {
  const MatchGameReceipt({
    required this.gameId,
    required this.gameVersion,
    required this.playerARawScore,
    required this.playerBRawScore,
    required this.playerANormalizedScore,
    required this.playerBNormalizedScore,
    required this.playerADurationMs,
    required this.playerBDurationMs,
  });

  final String gameId;
  final int gameVersion;
  final int playerARawScore;
  final int playerBRawScore;
  final int playerANormalizedScore;
  final int playerBNormalizedScore;
  final int playerADurationMs;
  final int playerBDurationMs;

  Map<String, Object> toMap() => {
        'gameId': gameId,
        'gameVersion': gameVersion,
        'playerARawScore': playerARawScore,
        'playerBRawScore': playerBRawScore,
        'playerANormalizedScore': playerANormalizedScore,
        'playerBNormalizedScore': playerBNormalizedScore,
        'playerADurationMs': playerADurationMs,
        'playerBDurationMs': playerBDurationMs,
      };
}

class MatchResultReceipt {
  const MatchResultReceipt({
    required this.matchId,
    required this.playerAId,
    required this.playerBId,
    required this.winnerId,
    required this.loserId,
    required this.reason,
    required this.playerATotalScore,
    required this.playerBTotalScore,
    required this.playerATotalDurationMs,
    required this.playerBTotalDurationMs,
    required this.games,
  });

  factory MatchResultReceipt.fromResolution(MatchResolution resolution) {
    return MatchResultReceipt(
      matchId: resolution.matchId,
      playerAId: resolution.playerA.playerId,
      playerBId: resolution.playerB.playerId,
      winnerId: resolution.winnerId,
      loserId: resolution.loserId,
      reason: resolution.reason,
      playerATotalScore: resolution.playerA.totalNormalizedScore,
      playerBTotalScore: resolution.playerB.totalNormalizedScore,
      playerATotalDurationMs: resolution.playerA.totalDuration.inMilliseconds,
      playerBTotalDurationMs: resolution.playerB.totalDuration.inMilliseconds,
      games: List.unmodifiable(
        resolution.games.map(
          (game) => MatchGameReceipt(
            gameId: game.gameId,
            gameVersion: game.gameVersion,
            playerARawScore: game.playerARawScore,
            playerBRawScore: game.playerBRawScore,
            playerANormalizedScore: game.playerANormalizedScore,
            playerBNormalizedScore: game.playerBNormalizedScore,
            playerADurationMs: game.playerADuration.inMilliseconds,
            playerBDurationMs: game.playerBDuration.inMilliseconds,
          ),
        ),
      ),
    );
  }

  final String matchId;
  final String playerAId;
  final String playerBId;
  final String winnerId;
  final String loserId;
  final MatchResolutionReason reason;
  final int playerATotalScore;
  final int playerBTotalScore;
  final int playerATotalDurationMs;
  final int playerBTotalDurationMs;
  final List<MatchGameReceipt> games;

  bool get decidedByTime => reason == MatchResolutionReason.timeTieBreaker;

  int get timeDifferenceMs =>
      (playerATotalDurationMs - playerBTotalDurationMs).abs();

  Map<String, Object> toMap() => {
        'schemaVersion': 1,
        'matchId': matchId,
        'playerAId': playerAId,
        'playerBId': playerBId,
        'winnerId': winnerId,
        'loserId': loserId,
        'reason': reason.name,
        'playerATotalScore': playerATotalScore,
        'playerBTotalScore': playerBTotalScore,
        'playerATotalDurationMs': playerATotalDurationMs,
        'playerBTotalDurationMs': playerBTotalDurationMs,
        'timeDifferenceMs': timeDifferenceMs,
        'games': games.map((game) => game.toMap()).toList(growable: false),
      };
}
