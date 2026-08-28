import 'competitive_game_host.dart';

/// Single app-level registration point for embedded games.
///
/// The platform is intentionally shipped with an empty catalog until the
/// approved game package is integrated. Adding Game 17/18/etc later only
/// requires registering the game implementation and its score adapter here.
class GameIntegrationCatalog {
  GameIntegrationCatalog._();

  static const int requiredLaunchGames = 16;

  static GameIntegrationRegistry registry = GameIntegrationRegistry.empty();

  static bool supportsAll(Iterable<String> gameIds) =>
      gameIds.every(registry.supports);

  static int get installedGameCount => registry.supportedGameIds.length;

  static bool get isCompetitionReady =>
      installedGameCount >= requiredLaunchGames;
}
