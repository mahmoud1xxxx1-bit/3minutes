import '../data/game_registry.dart';
import 'mini_game_engine.dart';

class MiniGameContentPolicy {
  const MiniGameContentPolicy._();

  static void validate() {
    final gameIds = GameRegistry.games.map((game) => game.id).toSet();
    final engineIds = MiniGameEngineRegistry.byGameId.keys.toSet();

    final missingEngines = gameIds.difference(engineIds);
    if (missingEngines.isNotEmpty) {
      throw StateError(
        'Registered mini-games without playable engines: ${missingEngines.join(', ')}',
      );
    }

    final orphanEngines = engineIds.difference(gameIds);
    if (orphanEngines.isNotEmpty) {
      throw StateError(
        'Mini-game engines without registry descriptors: ${orphanEngines.join(', ')}',
      );
    }
  }
}
