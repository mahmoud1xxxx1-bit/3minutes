import '../../minigames/domain/mini_game_contract.dart';
import '../../minigames/domain/mini_game_registry.dart';

enum MatchResolutionReason {
  score,
  gameProgress,
  timeTieBreaker,
  doubleFail,
  exactTie,
}

class MatchGameSubmission {
  const MatchGameSubmission({
    required this.gameId,
    required this.gameVersion,
    required this.result,
  });

  final String gameId;
  final int gameVersion;
  final MiniGameResult result;
}

class ResolvedGameResult {
  const ResolvedGameResult({
    required this.gameId,
    required this.gameVersion,
    required this.playerA,
    required this.playerB,
  });

  final String gameId;
  final int gameVersion;
  final MiniGameResult? playerA;
  final MiniGameResult? playerB;
}

class PlayerMatchSummary {
  const PlayerMatchSummary({
    required this.playerId,
    required this.totalScore,
    required this.totalDuration,
    required this.attemptedGames,
    required this.completedGames,
  });

  final String playerId;
  final int totalScore;
  final Duration totalDuration;
  final int attemptedGames;
  final int completedGames;
}

class MatchResolution {
  const MatchResolution({
    required this.matchId,
    required this.playerA,
    required this.playerB,
    required this.games,
    required this.winnerId,
    required this.loserId,
    required this.reason,
  });

  final String matchId;
  final PlayerMatchSummary playerA;
  final PlayerMatchSummary playerB;
  final List<ResolvedGameResult> games;
  final String? winnerId;
  final String? loserId;
  final MatchResolutionReason reason;

  bool get hasWinner => winnerId != null;

  Duration get timeDifference {
    final delta = playerA.totalDuration - playerB.totalDuration;
    return delta.isNegative ? -delta : delta;
  }
}

/// Client-side mirror of the authoritative match-resolution policy.
///
/// Official rules:
/// 1. A fully completed mini-game is exactly 1000 points; a failed objective is 0.
/// 2. Higher total points win.
/// 3. If points tie at timeout, the player who reached a later game in the
///    locked four-game sequence wins.
/// 4. Time breaks a tie only when both players completed all four games.
/// 5. Same score + same game position with an incomplete objective is double-fail.
/// 6. Exact full-clear score + time equality remains a true tie; never random.
class MatchResultEngine {
  const MatchResultEngine({this.requiredGameCount = 4});

  final int requiredGameCount;

  MatchResolution resolve({
    required String matchId,
    required String playerAId,
    required String playerBId,
    required List<String> gameOrder,
    required List<MatchGameSubmission> playerASubmissions,
    required List<MatchGameSubmission> playerBSubmissions,
    required MiniGameRegistry registry,
  }) {
    if (matchId.isEmpty) throw StateError('matchId cannot be empty.');
    if (playerAId.isEmpty || playerBId.isEmpty || playerAId == playerBId) {
      throw StateError('A match requires two different player ids.');
    }

    final manifests = registry.requireMatchGames(
      gameOrder,
      requiredCount: requiredGameCount,
    );
    _validateSubmissionPrefix(playerASubmissions, gameOrder, 'A');
    _validateSubmissionPrefix(playerBSubmissions, gameOrder, 'B');

    final aByIndex = playerASubmissions;
    final bByIndex = playerBSubmissions;
    final resolvedGames = <ResolvedGameResult>[];

    var aTotalScore = 0;
    var bTotalScore = 0;
    var aTotalDuration = Duration.zero;
    var bTotalDuration = Duration.zero;
    var aCompleted = 0;
    var bCompleted = 0;

    for (var index = 0; index < requiredGameCount; index++) {
      final manifest = manifests[index];
      final a = index < aByIndex.length ? aByIndex[index] : null;
      final b = index < bByIndex.length ? bByIndex[index] : null;

      if (a != null) {
        _validateSubmission(a, manifest.id, manifest.version);
        aTotalScore += a.result.score;
        aTotalDuration += a.result.duration;
        if (a.result.completed) aCompleted += 1;
      }
      if (b != null) {
        _validateSubmission(b, manifest.id, manifest.version);
        bTotalScore += b.result.score;
        bTotalDuration += b.result.duration;
        if (b.result.completed) bCompleted += 1;
      }

      if (a != null || b != null) {
        resolvedGames.add(
          ResolvedGameResult(
            gameId: manifest.id,
            gameVersion: manifest.version,
            playerA: a?.result,
            playerB: b?.result,
          ),
        );
      }
    }

    final aAttempted = playerASubmissions.length;
    final bAttempted = playerBSubmissions.length;
    final bothClearedAll =
        aAttempted == requiredGameCount &&
        bAttempted == requiredGameCount &&
        aCompleted == requiredGameCount &&
        bCompleted == requiredGameCount;

    String? winnerId;
    String? loserId;
    late final MatchResolutionReason reason;

    if (aTotalScore != bTotalScore) {
      final aWins = aTotalScore > bTotalScore;
      winnerId = aWins ? playerAId : playerBId;
      loserId = aWins ? playerBId : playerAId;
      reason = MatchResolutionReason.score;
    } else if (aAttempted != bAttempted) {
      final aWins = aAttempted > bAttempted;
      winnerId = aWins ? playerAId : playerBId;
      loserId = aWins ? playerBId : playerAId;
      reason = MatchResolutionReason.gameProgress;
    } else if (bothClearedAll && aTotalDuration != bTotalDuration) {
      final aWins = aTotalDuration < bTotalDuration;
      winnerId = aWins ? playerAId : playerBId;
      loserId = aWins ? playerBId : playerAId;
      reason = MatchResolutionReason.timeTieBreaker;
    } else if (bothClearedAll) {
      reason = MatchResolutionReason.exactTie;
    } else {
      reason = MatchResolutionReason.doubleFail;
    }

    return MatchResolution(
      matchId: matchId,
      playerA: PlayerMatchSummary(
        playerId: playerAId,
        totalScore: aTotalScore,
        totalDuration: aTotalDuration,
        attemptedGames: aAttempted,
        completedGames: aCompleted,
      ),
      playerB: PlayerMatchSummary(
        playerId: playerBId,
        totalScore: bTotalScore,
        totalDuration: bTotalDuration,
        attemptedGames: bAttempted,
        completedGames: bCompleted,
      ),
      games: List<ResolvedGameResult>.unmodifiable(resolvedGames),
      winnerId: winnerId,
      loserId: loserId,
      reason: reason,
    );
  }

  void _validateSubmission(
    MatchGameSubmission submission,
    String expectedId,
    int expectedVersion,
  ) {
    if (submission.gameId != expectedId ||
        submission.gameVersion != expectedVersion) {
      throw StateError('Submission does not match locked game $expectedId v$expectedVersion.');
    }
    final result = submission.result;
    if (result.duration.isNegative ||
        result.accuracy.isNaN ||
        result.accuracy < 0 ||
        result.accuracy > 1 ||
        result.mistakes < 0 ||
        result.progressStepCount < 1 ||
        result.progressStep < 0 ||
        result.progressStep > result.progressStepCount) {
      throw StateError('Mini-game result is outside the official contract.');
    }
    if (result.completed) {
      if (result.score != 1000 || result.progressStep != result.progressStepCount) {
        throw StateError('Completed mini-games must be 1000 points at full progress.');
      }
    } else if (result.score != 0 || result.progressStep >= result.progressStepCount) {
      throw StateError('Failed mini-games must be 0 points with incomplete progress.');
    }
  }

  void _validateSubmissionPrefix(
    List<MatchGameSubmission> submissions,
    List<String> gameOrder,
    String side,
  ) {
    if (submissions.length > requiredGameCount) {
      throw StateError('Player $side submitted too many game results.');
    }
    for (var index = 0; index < submissions.length; index++) {
      if (submissions[index].gameId != gameOrder[index]) {
        throw StateError('Player $side results must follow the locked game order.');
      }
    }
  }
}
