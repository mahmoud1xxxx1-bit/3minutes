import '../../../core/config/app_config.dart';
import '../../match/domain/match_progress.dart';

class MatchIntegrityReport {
  const MatchIntegrityReport({
    required this.valid,
    required this.reasons,
  });

  final bool valid;
  final List<String> reasons;
}

class MatchIntegrityPolicy {
  const MatchIntegrityPolicy._();

  static MatchIntegrityReport validateProgress({
    required MatchProgress progress,
    required int gameCount,
  }) {
    final reasons = <String>[];

    if (gameCount != AppConfig.gamesPerMatch) {
      reasons.add('unexpected_game_count');
    }
    if (progress.completedGames < 0 || progress.completedGames > gameCount) {
      reasons.add('invalid_completed_games');
    }
    if (progress.totalScore < 0) {
      reasons.add('negative_score');
    }
    if (progress.accuracyTotal < 0 ||
        progress.accuracyTotal > progress.completedGames) {
      reasons.add('invalid_accuracy_total');
    }
    if (progress.mistakes < 0) {
      reasons.add('negative_mistakes');
    }
    if (progress.elapsedMs < 0 ||
        progress.elapsedMs > AppConfig.matchDuration.inMilliseconds) {
      reasons.add('invalid_elapsed_time');
    }

    return MatchIntegrityReport(
      valid: reasons.isEmpty,
      reasons: List.unmodifiable(reasons),
    );
  }
}
