import 'match_result_engine.dart';

class MatchGameReceipt {
  const MatchGameReceipt({
    required this.gameId,
    required this.gameVersion,
    required this.playerACompleted,
    required this.playerBCompleted,
    required this.playerAScore,
    required this.playerBScore,
    required this.playerAProgressStep,
    required this.playerBProgressStep,
    required this.progressStepCount,
    required this.playerAMistakes,
    required this.playerBMistakes,
    required this.playerADurationMs,
    required this.playerBDurationMs,
  });

  final String gameId;
  final int gameVersion;
  final bool? playerACompleted;
  final bool? playerBCompleted;
  final int? playerAScore;
  final int? playerBScore;
  final int? playerAProgressStep;
  final int? playerBProgressStep;
  final int progressStepCount;
  final int? playerAMistakes;
  final int? playerBMistakes;
  final int? playerADurationMs;
  final int? playerBDurationMs;

  Map<String, Object?> toMap() => {
        'gameId': gameId,
        'gameVersion': gameVersion,
        'playerACompleted': playerACompleted,
        'playerBCompleted': playerBCompleted,
        'playerAScore': playerAScore,
        'playerBScore': playerBScore,
        'playerAProgressStep': playerAProgressStep,
        'playerBProgressStep': playerBProgressStep,
        'progressStepCount': progressStepCount,
        'playerAMistakes': playerAMistakes,
        'playerBMistakes': playerBMistakes,
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
    required this.playerAAttemptedGames,
    required this.playerBAttemptedGames,
    required this.playerACompletedGames,
    required this.playerBCompletedGames,
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
      playerATotalScore: resolution.playerA.totalScore,
      playerBTotalScore: resolution.playerB.totalScore,
      playerATotalDurationMs: resolution.playerA.totalDuration.inMilliseconds,
      playerBTotalDurationMs: resolution.playerB.totalDuration.inMilliseconds,
      playerAAttemptedGames: resolution.playerA.attemptedGames,
      playerBAttemptedGames: resolution.playerB.attemptedGames,
      playerACompletedGames: resolution.playerA.completedGames,
      playerBCompletedGames: resolution.playerB.completedGames,
      games: List<MatchGameReceipt>.unmodifiable(
        resolution.games.map((game) {
          final a = game.playerA;
          final b = game.playerB;
          return MatchGameReceipt(
            gameId: game.gameId,
            gameVersion: game.gameVersion,
            playerACompleted: a?.completed,
            playerBCompleted: b?.completed,
            playerAScore: a?.score,
            playerBScore: b?.score,
            playerAProgressStep: a?.progressStep,
            playerBProgressStep: b?.progressStep,
            progressStepCount: a?.progressStepCount ?? b?.progressStepCount ?? 1,
            playerAMistakes: a?.mistakes,
            playerBMistakes: b?.mistakes,
            playerADurationMs: a?.duration.inMilliseconds,
            playerBDurationMs: b?.duration.inMilliseconds,
          );
        }),
      ),
    );
  }

  final String matchId;
  final String playerAId;
  final String playerBId;
  final String? winnerId;
  final String? loserId;
  final MatchResolutionReason reason;
  final int playerATotalScore;
  final int playerBTotalScore;
  final int playerATotalDurationMs;
  final int playerBTotalDurationMs;
  final int playerAAttemptedGames;
  final int playerBAttemptedGames;
  final int playerACompletedGames;
  final int playerBCompletedGames;
  final List<MatchGameReceipt> games;

  bool get decidedByTime => reason == MatchResolutionReason.timeTieBreaker;
  bool get isDoubleFail => reason == MatchResolutionReason.doubleFail;
  bool get isExactTie => reason == MatchResolutionReason.exactTie;

  int get timeDifferenceMs =>
      (playerATotalDurationMs - playerBTotalDurationMs).abs();

  Map<String, Object?> toMap() => {
        'schemaVersion': 2,
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
        'playerAAttemptedGames': playerAAttemptedGames,
        'playerBAttemptedGames': playerBAttemptedGames,
        'playerACompletedGames': playerACompletedGames,
        'playerBCompletedGames': playerBCompletedGames,
        'timeDifferenceMs': timeDifferenceMs,
        'games': games.map((game) => game.toMap()).toList(growable: false),
      };
}
