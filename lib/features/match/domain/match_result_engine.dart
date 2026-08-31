import '../../minigames/domain/mini_game_contract.dart';
import '../../minigames/domain/mini_game_registry.dart';

enum MatchResolutionReason {
  score,
  timeTieBreaker,
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
    required this.playerARawScore,
    required this.playerBRawScore,
    required this.playerANormalizedScore,
    required this.playerBNormalizedScore,
    required this.playerADuration,
    required this.playerBDuration,
  });

  final String gameId;
  final int gameVersion;
  final int playerARawScore;
  final int playerBRawScore;
  final int playerANormalizedScore;
  final int playerBNormalizedScore;
  final Duration playerADuration;
  final Duration playerBDuration;

  String? get winnerSide {
    if (playerANormalizedScore > playerBNormalizedScore) return 'A';
    if (playerBNormalizedScore > playerANormalizedScore) return 'B';
    if (playerADuration < playerBDuration) return 'A';
    if (playerBDuration < playerADuration) return 'B';
    return null;
  }
}

class PlayerMatchSummary {
  const PlayerMatchSummary({
    required this.playerId,
    required this.totalNormalizedScore,
    required this.totalDuration,
    required this.gamesCompleted,
  });

  final String playerId;
  final int totalNormalizedScore;
  final Duration totalDuration;
  final int gamesCompleted;
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
  final String winnerId;
  final String loserId;
  final MatchResolutionReason reason;

  Duration get timeDifference {
    final delta = playerA.totalDuration - playerB.totalDuration;
    return delta.isNegative ? -delta : delta;
  }
}

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
    _validateSubmissionSet(playerASubmissions, gameOrder, 'A');
    _validateSubmissionSet(playerBSubmissions, gameOrder, 'B');

    final aById = {for (final submission in playerASubmissions) submission.gameId: submission};
    final bById = {for (final submission in playerBSubmissions) submission.gameId: submission};

    final resolvedGames = <ResolvedGameResult>[];
    var aTotalScore = 0;
    var bTotalScore = 0;
    var aTotalDuration = Duration.zero;
    var bTotalDuration = Duration.zero;

    for (final manifest in manifests) {
      final a = aById[manifest.id]!;
      final b = bById[manifest.id]!;
      if (a.gameVersion != manifest.version || b.gameVersion != manifest.version) {
        throw StateError('Version mismatch for ${manifest.id}.');
      }
      manifest.validateResult(a.result);
      manifest.validateResult(b.result);
      if (!a.result.completed || !b.result.completed) {
        throw StateError('Both players must correctly complete all $requiredGameCount games.');
      }

      final aNormalized = manifest.normalizeScore(a.result.score);
      final bNormalized = manifest.normalizeScore(b.result.score);
      aTotalScore += aNormalized;
      bTotalScore += bNormalized;
      aTotalDuration += a.result.duration;
      bTotalDuration += b.result.duration;

      resolvedGames.add(
        ResolvedGameResult(
          gameId: manifest.id,
          gameVersion: manifest.version,
          playerARawScore: a.result.score,
          playerBRawScore: b.result.score,
          playerANormalizedScore: aNormalized,
          playerBNormalizedScore: bNormalized,
          playerADuration: a.result.duration,
          playerBDuration: b.result.duration,
        ),
      );
    }

    late final String winnerId;
    late final String loserId;
    late final MatchResolutionReason reason;

    if (aTotalScore > bTotalScore) {
      winnerId = playerAId;
      loserId = playerBId;
      reason = MatchResolutionReason.score;
    } else if (bTotalScore > aTotalScore) {
      winnerId = playerBId;
      loserId = playerAId;
      reason = MatchResolutionReason.score;
    } else if (aTotalDuration < bTotalDuration) {
      winnerId = playerAId;
      loserId = playerBId;
      reason = MatchResolutionReason.timeTieBreaker;
    } else if (bTotalDuration < aTotalDuration) {
      winnerId = playerBId;
      loserId = playerAId;
      reason = MatchResolutionReason.timeTieBreaker;
    } else {
      throw StateError(
        'Score and total time are exactly equal; a deterministic final tie policy is required.',
      );
    }

    return MatchResolution(
      matchId: matchId,
      playerA: PlayerMatchSummary(
        playerId: playerAId,
        totalNormalizedScore: aTotalScore,
        totalDuration: aTotalDuration,
        gamesCompleted: requiredGameCount,
      ),
      playerB: PlayerMatchSummary(
        playerId: playerBId,
        totalNormalizedScore: bTotalScore,
        totalDuration: bTotalDuration,
        gamesCompleted: requiredGameCount,
      ),
      games: List.unmodifiable(resolvedGames),
      winnerId: winnerId,
      loserId: loserId,
      reason: reason,
    );
  }

  void _validateSubmissionSet(
    List<MatchGameSubmission> submissions,
    List<String> gameOrder,
    String side,
  ) {
    if (submissions.length != requiredGameCount) {
      throw StateError('Player $side must submit exactly $requiredGameCount game results.');
    }
    final ids = submissions.map((submission) => submission.gameId).toList();
    if (ids.toSet().length != ids.length) {
      throw StateError('Player $side submitted duplicate game results.');
    }
    if (ids.toSet().difference(gameOrder.toSet()).isNotEmpty ||
        gameOrder.toSet().difference(ids.toSet()).isNotEmpty) {
      throw StateError('Player $side submissions do not match the locked game order.');
    }
  }
}
