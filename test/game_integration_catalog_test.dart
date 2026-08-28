import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/match/application/competitive_game_host.dart';
import 'package:game/features/match/application/game_integration_catalog.dart';
import 'package:game/features/match/domain/game_integration_contract.dart';

class _Game implements ThreeMinutesGame {
  const _Game(this.gameId);

  @override
  final String gameId;

  @override
  String get displayName => gameId;

  @override
  Future<GameRunResult> play(GameRunContext context) async => GameRunResult(
        gameId: gameId,
        rawScore: 1,
        completed: true,
        elapsed: const Duration(seconds: 1),
      );
}

class _Adapter implements GameScoreAdapter {
  const _Adapter(this.gameId);

  @override
  final String gameId;

  @override
  int normalize(GameRunResult result) => result.rawScore.toInt();
}

void main() {
  tearDown(() {
    GameIntegrationCatalog.registry = GameIntegrationRegistry.empty();
  });

  test('competition remains locked when fewer than 16 games are integrated', () {
    GameIntegrationCatalog.registry = GameIntegrationRegistry(
      games: List.generate(15, (index) => _Game('game_$index')),
      adapters: List.generate(15, (index) => _Adapter('game_$index')),
    );

    expect(GameIntegrationCatalog.installedGameCount, 15);
    expect(GameIntegrationCatalog.isCompetitionReady, isFalse);
  });

  test('competition unlocks when 16 complete game integrations exist', () {
    GameIntegrationCatalog.registry = GameIntegrationRegistry(
      games: List.generate(16, (index) => _Game('game_$index')),
      adapters: List.generate(16, (index) => _Adapter('game_$index')),
    );

    expect(GameIntegrationCatalog.installedGameCount, 16);
    expect(GameIntegrationCatalog.isCompetitionReady, isTrue);
  });

  test('game without score adapter does not count as integrated', () {
    GameIntegrationCatalog.registry = GameIntegrationRegistry(
      games: List.generate(16, (index) => _Game('game_$index')),
      adapters: List.generate(15, (index) => _Adapter('game_$index')),
    );

    expect(GameIntegrationCatalog.installedGameCount, 15);
    expect(GameIntegrationCatalog.isCompetitionReady, isFalse);
  });
}
