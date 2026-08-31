import 'mini_game_manifest.dart';

class MiniGameRegistry {
  MiniGameRegistry({
    required this.registryVersion,
    required Iterable<MiniGameManifest> manifests,
  }) : assert(registryVersion > 0),
       _byId = _build(manifests);

  final int registryVersion;
  final Map<String, MiniGameManifest> _byId;

  static Map<String, MiniGameManifest> _build(
    Iterable<MiniGameManifest> manifests,
  ) {
    final result = <String, MiniGameManifest>{};
    for (final manifest in manifests) {
      if (result.containsKey(manifest.id)) {
        throw StateError('Duplicate mini-game id: ${manifest.id}.');
      }
      result[manifest.id] = manifest;
    }
    return Map.unmodifiable(result);
  }

  List<MiniGameManifest> get enabledGames => List.unmodifiable(
        _byId.values.where((game) => game.enabled),
      );

  MiniGameManifest requireGame(String gameId, {int? version}) {
    final game = _byId[gameId];
    if (game == null) {
      throw StateError('Mini-game $gameId is not registered.');
    }
    if (!game.enabled) {
      throw StateError('Mini-game $gameId is disabled.');
    }
    if (version != null && game.version != version) {
      throw StateError(
        'Mini-game $gameId version mismatch: expected $version, registry has ${game.version}.',
      );
    }
    return game;
  }

  List<MiniGameManifest> requireMatchGames(
    List<String> gameIds, {
    int requiredCount = 4,
  }) {
    if (gameIds.length != requiredCount) {
      throw StateError(
        'A competitive match requires exactly $requiredCount games; got ${gameIds.length}.',
      );
    }
    if (gameIds.toSet().length != gameIds.length) {
      throw StateError('A competitive match cannot contain duplicate game ids.');
    }
    return List.unmodifiable(gameIds.map(requireGame));
  }
}
