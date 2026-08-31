import 'match_progress.dart';

enum MatchOutcome { playerA, playerB, tie }

class MatchOutcomeResolver {
  const MatchOutcomeResolver._();

  static MatchOutcome compare({
    required MatchProgress playerA,
    required MatchProgress playerB,
    required int gameCount,
  }) {
    final aFinished = playerA.completedGames >= gameCount;
    final bFinished = playerB.completedGames >= gameCount;

    if (aFinished && bFinished) {
      final aTime = playerA.completedAt;
      final bTime = playerB.completedAt;
      if (aTime != null && bTime != null && aTime != bTime) {
        return aTime.isBefore(bTime) ? MatchOutcome.playerA : MatchOutcome.playerB;
      }
    } else if (aFinished != bFinished) {
      return aFinished ? MatchOutcome.playerA : MatchOutcome.playerB;
    }

    if (playerA.completedGames != playerB.completedGames) {
      return playerA.completedGames > playerB.completedGames
          ? MatchOutcome.playerA
          : MatchOutcome.playerB;
    }

    if (playerA.totalScore != playerB.totalScore) {
      return playerA.totalScore > playerB.totalScore
          ? MatchOutcome.playerA
          : MatchOutcome.playerB;
    }

    final accuracyCompare =
        playerA.averageAccuracy.compareTo(playerB.averageAccuracy);
    if (accuracyCompare != 0) {
      return accuracyCompare > 0 ? MatchOutcome.playerA : MatchOutcome.playerB;
    }

    if (playerA.mistakes != playerB.mistakes) {
      return playerA.mistakes < playerB.mistakes
          ? MatchOutcome.playerA
          : MatchOutcome.playerB;
    }

    if (playerA.elapsedMs != playerB.elapsedMs) {
      return playerA.elapsedMs < playerB.elapsedMs
          ? MatchOutcome.playerA
          : MatchOutcome.playerB;
    }

    return MatchOutcome.tie;
  }
}
