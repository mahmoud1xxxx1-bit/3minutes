import '../../economy/data/competitive_economy_service.dart';
import '../domain/game_integration_contract.dart';

class GameIntegrationRegistry {
  GameIntegrationRegistry({
    required Iterable<ThreeMinutesGame> games,
    required Iterable<GameScoreAdapter> adapters,
  })  : _games = {for (final game in games) game.gameId: game},
        _adapters = {for (final adapter in adapters) adapter.gameId: adapter};

  final Map<String, ThreeMinutesGame> _games;
  final Map<String, GameScoreAdapter> _adapters;

  ThreeMinutesGame game(String gameId) {
    final value = _games[gameId];
    if (value == null) throw StateError('Game $gameId is not registered.');
    return value;
  }

  GameScoreAdapter adapter(String gameId) {
    final value = _adapters[gameId];
    if (value == null) throw StateError('Score adapter $gameId is not registered.');
    return value;
  }

  bool supports(String gameId) => _games.containsKey(gameId) && _adapters.containsKey(gameId);
}

class CompetitiveGameHost {
  CompetitiveGameHost({
    required this.matchId,
    required this.playerId,
    required this.gameOrder,
    required this.deadline,
    required this.registry,
    required this.backend,
  }) {
    if (gameOrder.length != 4) {
      throw ArgumentError.value(gameOrder.length, 'gameOrder', 'Competitive match requires four game slots.');
    }
  }

  final String matchId;
  final String playerId;
  final List<String> gameOrder;
  final DateTime deadline;
  final GameIntegrationRegistry registry;
  final CompetitiveEconomyService backend;

  Future<CompetitiveHostResult> run({
    void Function(CompetitiveHostProgress progress)? onProgress,
  }) async {
    final submitted = <HostedGameResult>[];

    for (var index = 0; index < gameOrder.length; index++) {
      if (!DateTime.now().isBefore(deadline)) break;
      final gameId = gameOrder[index];
      final game = registry.game(gameId);
      final adapter = registry.adapter(gameId);
      onProgress?.call(CompetitiveHostProgress(
        gameIndex: index,
        totalGames: gameOrder.length,
        gameId: gameId,
        remaining: _remaining(),
      ));

      final result = await game.play(GameRunContext(
        matchId: matchId,
        playerId: playerId,
        gameId: gameId,
        gameIndex: index,
        totalGames: gameOrder.length,
        matchDeadline: deadline,
      ));
      if (result.gameId != gameId) {
        throw StateError('Game $gameId returned a result for ${result.gameId}.');
      }
      final normalized = adapter.normalize(result);
      if (normalized < 0) {
        throw StateError('Normalized score cannot be negative.');
      }

      await backend.submitGameResult(
        matchId: matchId,
        gameId: gameId,
        gameIndex: index,
        rawScore: result.rawScore,
        normalizedScore: normalized,
        completed: result.completed,
        progress: result.progress,
        elapsed: result.elapsed,
        stats: result.stats,
      );
      submitted.add(HostedGameResult(
        gameId: gameId,
        gameIndex: index,
        normalizedScore: normalized,
        completed: result.completed,
      ));
    }

    final finalized = await backend.finalizeResults(matchId);
    final settlement = await backend.settleMatch(matchId);
    return CompetitiveHostResult(
      submitted: submitted,
      finalized: finalized,
      settlement: settlement,
    );
  }

  Duration _remaining() {
    final value = deadline.difference(DateTime.now());
    return value.isNegative ? Duration.zero : value;
  }
}

class CompetitiveHostProgress {
  const CompetitiveHostProgress({
    required this.gameIndex,
    required this.totalGames,
    required this.gameId,
    required this.remaining,
  });

  final int gameIndex;
  final int totalGames;
  final String gameId;
  final Duration remaining;
}

class HostedGameResult {
  const HostedGameResult({
    required this.gameId,
    required this.gameIndex,
    required this.normalizedScore,
    required this.completed,
  });

  final String gameId;
  final int gameIndex;
  final int normalizedScore;
  final bool completed;
}

class CompetitiveHostResult {
  const CompetitiveHostResult({
    required this.submitted,
    required this.finalized,
    required this.settlement,
  });

  final List<HostedGameResult> submitted;
  final CompetitiveFinalizedResult finalized;
  final CompetitiveSettlementResult settlement;
}
