import '../../../core/config/app_config.dart';
import 'match_progress.dart';

class MatchSettlement {
  const MatchSettlement._();

  static DateTime? deadline(DateTime? countdownStartedAt) {
    if (countdownStartedAt == null) return null;
    return countdownStartedAt
        .add(const Duration(seconds: 3))
        .add(AppConfig.matchDuration);
  }

  static bool isSettled({
    required MatchProgress playerA,
    required MatchProgress playerB,
    required int gameCount,
    required DateTime? countdownStartedAt,
    required DateTime now,
  }) {
    final bothCompleted = playerA.completedGames >= gameCount &&
        playerB.completedGames >= gameCount;
    if (bothCompleted) return true;

    final end = deadline(countdownStartedAt);
    return end != null && !now.isBefore(end);
  }
}
