import '../../minigames/data/game_registry.dart';
import 'mini_game_evidence.dart';

class MiniGameEvidencePolicy {
  const MiniGameEvidencePolicy._();

  static const int _seedMix = 0x45d9f3b;
  static const int maxScorePerGame = 10000;
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
  }) {
    if (gameCount < 1 || gameCount > GameRegistry.games.length) return false;
    if (evidence.length > gameCount) return false;

    final expectedGames = GameRegistry.sequence(
      seed: matchSeed,
      count: gameCount,
    );

    var totalDurationMs = 0;
    for (var index = 0; index < evidence.length; index++) {
      final item = evidence[index];
      if (item.gameIndex != index) return false;
      if (item.gameId != expectedGames[index].id) return false;
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
}
