import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/minigames/domain/competitive_result_policy.dart';
import 'package:game/features/minigames/domain/mini_game_contract.dart';

void main() {
  test('successful objective always becomes exactly 1000 points', () {
    final result = CompetitiveResultPolicy.normalize(
      const MiniGameResult(
        completed: true,
        score: 37,
        accuracy: .72,
        mistakes: 8,
        duration: Duration(seconds: 21),
        progressStep: 1,
        progressStepCount: 3,
      ),
    );

    expect(result.score, 1000);
    expect(result.completed, isTrue);
    expect(result.progressStep, 3);
    expect(result.mistakes, 8);
    expect(CompetitiveResultPolicy.isOfficial(result), isTrue);
  });

  test('failed objective always becomes zero without hiding diagnostics', () {
    final result = CompetitiveResultPolicy.normalize(
      const MiniGameResult(
        completed: false,
        score: 999,
        accuracy: .5,
        mistakes: 2,
        duration: Duration(seconds: 29),
        progressStep: 2,
        progressStepCount: 3,
      ),
    );

    expect(result.score, 0);
    expect(result.completed, isFalse);
    expect(result.progressStep, 2);
    expect(result.mistakes, 2);
    expect(result.duration, const Duration(seconds: 29));
    expect(CompetitiveResultPolicy.isOfficial(result), isTrue);
  });

  test('mistakes never subtract competitive points from a completed objective', () {
    final clean = CompetitiveResultPolicy.normalize(
      const MiniGameResult(
        completed: true,
        score: 100,
        accuracy: 1,
        mistakes: 0,
        duration: Duration(seconds: 20),
      ),
    );
    final messy = CompetitiveResultPolicy.normalize(
      const MiniGameResult(
        completed: true,
        score: 10,
        accuracy: .2,
        mistakes: 12,
        duration: Duration(seconds: 28),
      ),
    );

    expect(clean.score, 1000);
    expect(messy.score, 1000);
    expect(messy.mistakes, 12);
  });
}
