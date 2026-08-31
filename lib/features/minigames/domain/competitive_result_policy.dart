import 'mini_game_contract.dart';

/// Single competitive scoring boundary shared by every mini-game.
///
/// A mini-game owns only its objective and diagnostic telemetry. It never owns
/// ranked point formulas: full objective completion is 1000 points and failure
/// is 0. Internal hearts, mistakes, rounds and raw counters remain available
/// for the result report without changing match points.
class CompetitiveResultPolicy {
  const CompetitiveResultPolicy._();

  static const int completionPoints = 1000;
  static const int failurePoints = 0;

  static MiniGameResult normalize(MiniGameResult raw) {
    final stepCount = raw.progressStepCount < 1 ? 1 : raw.progressStepCount;
    final progress = raw.completed
        ? stepCount
        : raw.progressStep.clamp(0, stepCount - 1).toInt();

    return MiniGameResult(
      completed: raw.completed,
      score: raw.completed ? completionPoints : failurePoints,
      accuracy: raw.accuracy.clamp(0.0, 1.0).toDouble(),
      mistakes: raw.mistakes < 0 ? 0 : raw.mistakes,
      duration: raw.duration.isNegative ? Duration.zero : raw.duration,
      progressStep: progress,
      progressStepCount: stepCount,
    );
  }

  static bool isOfficial(MiniGameResult result) {
    if (result.accuracy.isNaN ||
        result.accuracy < 0 ||
        result.accuracy > 1 ||
        result.mistakes < 0 ||
        result.duration.isNegative ||
        result.progressStepCount < 1 ||
        result.progressStep < 0 ||
        result.progressStep > result.progressStepCount) {
      return false;
    }
    if (result.completed) {
      return result.score == completionPoints &&
          result.progressStep == result.progressStepCount;
    }
    return result.score == failurePoints &&
        result.progressStep < result.progressStepCount;
  }
}
