import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/minigames/data/competitive_game_registry.dart';
import 'package:game/features/minigames/data/game_registry.dart';

void main() {
  test('competitive contract mirrors every production game exactly once', () {
    final contract = CompetitiveGameRegistry.instance;

    expect(contract.registryVersion, GameRegistry.version);
    expect(contract.enabledGames.length, GameRegistry.games.length);
    expect(
      contract.enabledGames.map((game) => game.id).toSet(),
      GameRegistry.games.map((game) => game.id).toSet(),
    );
  });

  test('every production game exposes a positive immutable contract version', () {
    for (final game in GameRegistry.games) {
      expect(game.version, greaterThan(0), reason: game.id);
      final manifest = CompetitiveGameRegistry.instance.requireGame(
        game.id,
        version: game.version,
      );
      expect(manifest.id, game.id);
    }
  });

  test('competitive registry accepts exactly four distinct locked games', () {
    final ids = GameRegistry.sequence(seed: 20260818, count: 4)
        .map((game) => game.id)
        .toList(growable: false);

    expect(
      CompetitiveGameRegistry.instance.requireMatchGames(ids),
      hasLength(4),
    );
  });
}
