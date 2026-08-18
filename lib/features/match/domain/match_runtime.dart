import '../../../core/config/app_config.dart';
import '../../minigames/data/game_registry.dart';
import '../../minigames/domain/mini_game_contract.dart';
import 'match_progress.dart';

class MatchRuntime {
  MatchRuntime({
    required this.seed,
    required this.startedAt,
    required this.gameCount,
  }) : gameSequence = GameRegistry.sequence(seed: seed, count: gameCount);

  final int seed;
  final DateTime startedAt;
  final int gameCount;
  final List<MiniGameDescriptor> gameSequence;

  MatchProgress _progress = const MatchProgress.empty();

  MatchProgress get progress => _progress;

  DateTime get endsAt => startedAt.add(AppConfig.matchDuration);

  bool get allGamesCompleted => _progress.completedGames >= gameCount;

  bool isExpired(DateTime now) => !now.isBefore(endsAt);

  Duration remaining(DateTime now) {
    final value = endsAt.difference(now);
    return value.isNegative ? Duration.zero : value;
  }

  MiniGameDescriptor? get currentGame {
    if (allGamesCompleted) return null;
    return gameSequence[_progress.completedGames];
  }

  MatchProgress recordResult(MiniGameResult result) {
    if (allGamesCompleted) return _progress;
    _validateResult(result);

    final completedGames = _progress.completedGames + 1;
    _progress = MatchProgress(
      completedGames: completedGames,
      totalScore: _progress.totalScore + result.score,
      accuracyTotal: _progress.accuracyTotal + result.accuracy,
      mistakes: _progress.mistakes + result.mistakes,
      elapsedMs: _progress.elapsedMs + result.duration.inMilliseconds,
    );
    return _progress;
  }

  void _validateResult(MiniGameResult result) {
    if (result.score < 0 ||
        result.accuracy < 0 ||
        result.accuracy > 1 ||
        result.mistakes < 0 ||
        result.duration.isNegative) {
      throw ArgumentError('Mini-game returned an invalid normalized result.');
    }
  }
}
