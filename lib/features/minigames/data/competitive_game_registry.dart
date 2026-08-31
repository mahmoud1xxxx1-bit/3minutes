import '../domain/mini_game_engine.dart';
import '../domain/mini_game_manifest.dart';
import '../domain/mini_game_registry.dart';
import 'game_registry.dart';

/// Contract view of the production mini-game catalog used by competitive
/// result validation. UI/runtime selection stays in [GameRegistry], while this
/// adapter gives Match Engine a versioned, validation-oriented contract.
class CompetitiveGameRegistry {
  const CompetitiveGameRegistry._();

  static final MiniGameRegistry instance = MiniGameRegistry(
    registryVersion: GameRegistry.version,
    manifests: GameRegistry.games.map((game) {
      return MiniGameManifest(
        id: game.id,
        version: game.version,
        titleAr: game.title,
        titleEn: game.title,
        category: game.category,
        engine: MiniGameEngineRegistry.engineFor(game.id),
        maxDuration: const Duration(minutes: 3),
        minRawScore: 0,
        maxRawScore: 10000,
      );
    }),
  );
}
