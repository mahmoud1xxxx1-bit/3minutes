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
        ? _descriptorsForEvidence(evidence)
        : _descriptorsForLockedIds(lockedGameIds);
    if (lockedGameIds != null && expectedGames.length != gameCount) return false;
    if (lockedGameIds == null && expectedGames.length != evidence.length) return false;

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
      if (item.progressStepCount < 1 ||
          item.progressStep < 0 ||
          item.progressStep > item.progressStepCount) {
        return false;
      }
      if (item.completed) {
        if (item.score != maxScorePerGame ||
            item.progressStep != item.progressStepCount) {
          return false;
        }
      } else {
        if (item.score != 0 || item.progressStep >= item.progressStepCount) {
          return false;
        }
      }
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

  static List<MiniGameDescriptor> _descriptorsForEvidence(
    List<MiniGameEvidence> evidence,
  ) {
    final ids = evidence.map((item) => item.gameId).toList(growable: false);
    if (ids.toSet().length != ids.length) return const [];
    return _descriptorsForIds(ids);
  }

  static List<MiniGameDescriptor> _descriptorsForLockedIds(List<String> ids) {
    if (ids.length != 4 || ids.toSet().length != 4) return const [];
    return _descriptorsForIds(ids);
  }

  static List<MiniGameDescriptor> _descriptorsForIds(List<String> ids) {
    final result = <MiniGameDescriptor>[];
    for (final id in ids) {
      final matches = GameRegistry.games.where((game) => game.id == id);
      if (matches.length != 1) return const [];
      result.add(matches.single);
    }
    return List.unmodifiable(result);
  }
}
