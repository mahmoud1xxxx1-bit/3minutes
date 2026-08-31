import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/match/domain/match_outcome.dart';
import 'package:game/features/match/domain/match_progress.dart';

void main() {
  MatchProgress progress({
    required int completedGames,
    required int totalScore,
    required double accuracyTotal,
    int mistakes = 0,
    int elapsedMs = 1000,
    DateTime? completedAt,
  }) {
    return MatchProgress(
      completedGames: completedGames,
      totalScore: totalScore,
      accuracyTotal: accuracyTotal,
      mistakes: mistakes,
      elapsedMs: elapsedMs,
      completedAt: completedAt,
    );
  }

  test('score breaks equal-completion ties before accuracy like server authority', () {
    final playerA = progress(
      completedGames: 4,
      totalScore: 500,
      accuracyTotal: 2.0,
    );
    final playerB = progress(
      completedGames: 4,
      totalScore: 450,
      accuracyTotal: 4.0,
    );

    expect(
      MatchOutcomeResolver.compare(
        playerA: playerA,
        playerB: playerB,
        gameCount: 8,
      ),
      MatchOutcome.playerA,
    );
  });

  test('accuracy remains next tie-breaker when score is equal', () {
    final playerA = progress(
      completedGames: 4,
      totalScore: 500,
      accuracyTotal: 3.8,
    );
    final playerB = progress(
      completedGames: 4,
      totalScore: 500,
      accuracyTotal: 3.2,
    );

    expect(
      MatchOutcomeResolver.compare(
        playerA: playerA,
        playerB: playerB,
        gameCount: 8,
      ),
      MatchOutcome.playerA,
    );
  });
}
