import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/economy/data/competitive_economy_service.dart';
import 'package:game/features/match/application/competitive_game_host.dart';
import 'package:game/features/match/domain/game_integration_contract.dart';

void main() {
  test('game host runs four slots, normalizes, submits, finalizes and settles', () async {
    final games = List.generate(4, (index) => _FakeGame('g$index', index + 1));
    final adapters = List.generate(4, (index) => _DoubleAdapter('g$index'));
    final backend = _FakeBackend();
    final host = CompetitiveGameHost(
      matchId: 'm1',
      playerId: 'p1',
      gameOrder: const ['g0', 'g1', 'g2', 'g3'],
      deadline: DateTime.now().add(const Duration(minutes: 3)),
      registry: GameIntegrationRegistry(games: games, adapters: adapters),
      backend: backend,
    );

    final progress = <int>[];
    final result = await host.run(onProgress: (value) => progress.add(value.gameIndex));

    expect(progress, [0, 1, 2, 3]);
    expect(backend.submitted.map((e) => e.$1), ['g0', 'g1', 'g2', 'g3']);
    expect(backend.submitted.map((e) => e.$2), [2, 4, 6, 8]);
    expect(result.submitted.map((e) => e.normalizedScore), [2, 4, 6, 8]);
    expect(backend.finalizeCalls, 1);
    expect(backend.settleCalls, 1);
  });

  test('host refuses missing integration before fabricated gameplay', () {
    expect(
      () => GameIntegrationRegistry.empty().game('missing'),
      throwsStateError,
    );
  });
}

class _FakeGame implements ThreeMinutesGame {
  _FakeGame(this.gameId, this.score);

  @override
  final String gameId;
  final int score;

  @override
  String get displayName => gameId;

  @override
  Future<GameRunResult> play(GameRunContext context) async => GameRunResult(
        gameId: gameId,
        rawScore: score,
        completed: true,
        elapsed: const Duration(seconds: 1),
      );
}

class _DoubleAdapter implements GameScoreAdapter {
  _DoubleAdapter(this.gameId);

  @override
  final String gameId;

  @override
  int normalize(GameRunResult result) => result.rawScore.toInt() * 2;
}

class _FakeBackend implements CompetitiveGameResultBackend {
  final submitted = <(String, int)>[];
  int finalizeCalls = 0;
  int settleCalls = 0;

  @override
  Future<void> submitGameResult({
    required String matchId,
    required String gameId,
    required int gameIndex,
    required num rawScore,
    required int normalizedScore,
    required bool completed,
    required double progress,
    required Duration elapsed,
    Map<String, num> stats = const <String, num>{},
  }) async {
    submitted.add((gameId, normalizedScore));
  }

  @override
  Future<CompetitiveFinalizedResult> finalizeResults(String matchId) async {
    finalizeCalls++;
    return const CompetitiveFinalizedResult(
      status: 'awaitingSettlement',
      outcome: 'playerA',
      totalScoreA: 20,
      totalScoreB: 10,
      games: [],
    );
  }

  @override
  Future<CompetitiveSettlementResult> settleMatch(String matchId) async {
    settleCalls++;
    return const CompetitiveSettlementResult(
      matchId: 'm1',
      outcome: 'playerA',
      wager: 180,
      playerA: CompetitiveSettlementPlayer(uid: 'p1', goldDelta: 180, coinsDelta: 30, rpDelta: 30),
      playerB: CompetitiveSettlementPlayer(uid: 'p2', goldDelta: -180, coinsDelta: 10, rpDelta: -18),
    );
  }
}
