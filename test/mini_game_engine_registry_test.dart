import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/minigames/data/game_registry.dart';
import 'package:game/features/minigames/domain/mini_game_engine.dart';

void main() {
  test('every registered mini game maps to exactly one reusable engine', () {
    final registeredIds = GameRegistry.games.map((game) => game.id).toSet();
    final engineIds = MiniGameEngineRegistry.byGameId.keys.toSet();

    expect(engineIds, registeredIds);
    for (final game in GameRegistry.games) {
      expect(
        () => MiniGameEngineRegistry.engineFor(game.id),
        returnsNormally,
      );
    }
  });
}
