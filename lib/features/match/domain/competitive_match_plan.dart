import '../../minigames/domain/mini_game_registry.dart';

class CompetitiveMatchGame {
  const CompetitiveMatchGame({
    required this.gameId,
    required this.gameVersion,
    required this.seed,
  });

  final String gameId;
  final int gameVersion;
  final int seed;
}

class CompetitiveMatchPlan {
  const CompetitiveMatchPlan._({
    required this.matchId,
    required this.registryVersion,
    required this.games,
  });

  static const int gameCount = 4;

  factory CompetitiveMatchPlan.lock({
    required String matchId,
    required MiniGameRegistry registry,
    required List<String> gameIds,
    required int matchSeed,
  }) {
    if (matchId.isEmpty) throw StateError('matchId cannot be empty.');
    final manifests = registry.requireMatchGames(
      gameIds,
      requiredCount: gameCount,
    );

    final games = <CompetitiveMatchGame>[];
    for (var index = 0; index < manifests.length; index++) {
      final manifest = manifests[index];
      games.add(
        CompetitiveMatchGame(
          gameId: manifest.id,
          gameVersion: manifest.version,
          seed: _deriveSeed(matchSeed, index, manifest.id),
        ),
      );
    }

    return CompetitiveMatchPlan._(
      matchId: matchId,
      registryVersion: registry.registryVersion,
      games: List.unmodifiable(games),
    );
  }

  final String matchId;
  final int registryVersion;
  final List<CompetitiveMatchGame> games;

  List<String> get gameOrder =>
      List.unmodifiable(games.map((game) => game.gameId));

  static int _deriveSeed(int matchSeed, int index, String gameId) {
    var value = matchSeed & 0x7fffffff;
    value = ((value * 1103515245) + 12345 + index) & 0x7fffffff;
    for (final codeUnit in gameId.codeUnits) {
      value = ((value * 31) + codeUnit) & 0x7fffffff;
    }
    return value;
  }
}
