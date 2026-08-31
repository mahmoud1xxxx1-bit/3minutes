import '../../minigames/data/game_registry.dart';
import '../domain/mini_game_evidence.dart';

class MiniGameEvidencePolicy {
  const MiniGameEvidencePolicy._();

  static const int _seedMix = 0x45d9f3b;
  static const int maxScorePerGame = 1000;
  static const int maxMatchDurationMs = 180000;

  static int gameSeed({
    required int matchSeed,
    required int gameIndex,
  }) {
    return matchSeed ^ ((gameIndex + 1) * _seedMix);
  }

  static bool isValidMatchEvidence({
    required int matchSeed,
    required int gameCount,
    required List<MiniGameEvidence> evidence,
    List<String>? lockedGameIds,
  }) {
    if (gameCount != 4) return false;
    if (evidence.length > gameCount) return false;

    final expectedGames = lockedGameIds == null
        ? GameRegistry.sequence(seed: matchSeed, count: gameCount)
        : _descriptorsForLockedIds(lockedGameIds);
    if (expectedGames.length != gameCount) return false;

    var totalDurationMs = 0;
    for (var index = 0; index < evidence.length; index++) {
      final item = evidence[index];
      final expected = expectedGames[index];
      if (item.gameIndex != index) return false;
      if (item.gameId != expected.id) return false;
      if (item.gameVersion != expected.version) return false;
      if (item.gameSeed != gameSeed(matchSeed: matchSeed, gameIndex: index)) {
        return false;
      }
      if (item.score < 0 || item.score > maxScorePerGame) return false;
      if (item.accuracy < 0 || item.accuracy > 1) return false;
      if (item.mistakes < 0) return false;
      if (item.durationMs < 0 || item.durationMs > maxMatchDurationMs) {
        return false;
      }
      totalDurationMs += item.durationMs;
      if (totalDurationMs > maxMatchDurationMs) return false;
    }

    return true;
  }

  static List<MiniGameDescriptor> _descriptorsForLockedIds(List<String> ids) {
    if (ids.length != 4 || ids.toSet().length != 4) return const [];
    final result = <MiniGameDescriptor>[];
    for (final id in ids) {
      final matches = GameRegistry.games.where((game) => game.id == id);
      if (matches.length != 1) return const [];
      result.add(matches.single);
    }
    return List.unmodifiable(result);
  }
}
