import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/competition/data/mini_game_evidence_policy.dart';
import 'package:game/features/competition/domain/mini_game_evidence.dart';
import 'package:game/features/minigames/data/game_registry.dart';

void main() {
  const lockedGameIds = <String>[
    'level_devil',
    'follow_the_cup',
    'path_rush',
    'find_differences',
  ];
  const matchSeed = 424242;

  test('single-result validation accepts the real index for games 2-4', () {
    for (var gameIndex = 1; gameIndex < 4; gameIndex++) {
      final descriptor = GameRegistry.games.singleWhere(
        (game) => game.id == lockedGameIds[gameIndex],
      );
      final evidence = MiniGameEvidence(
        gameId: descriptor.id,
        gameVersion: descriptor.version,
        gameIndex: gameIndex,
        gameSeed: MiniGameEvidencePolicy.gameSeed(
          matchSeed: matchSeed,
          gameIndex: gameIndex,
        ),
        completed: true,
        progressStep: 3,
        progressStepCount: 3,
        score: 1000,
        accuracy: 1,
        mistakes: 0,
        durationMs: 10000,
      );

      expect(
        MiniGameEvidencePolicy.isValidGameEvidence(
          matchSeed: matchSeed,
          gameCount: 4,
          evidence: evidence,
          lockedGameIds: lockedGameIds,
        ),
        isTrue,
        reason: 'game index $gameIndex must retain its locked slot',
      );
    }
  });

  test('single-result validation rejects evidence for the wrong locked slot', () {
    final descriptor = GameRegistry.games.singleWhere(
      (game) => game.id == lockedGameIds[2],
    );
    final evidence = MiniGameEvidence(
      gameId: descriptor.id,
      gameVersion: descriptor.version,
      gameIndex: 2,
      gameSeed: MiniGameEvidencePolicy.gameSeed(
        matchSeed: matchSeed,
        gameIndex: 2,
      ),
      completed: true,
      progressStep: 3,
      progressStepCount: 3,
      score: 1000,
      accuracy: 1,
      mistakes: 0,
      durationMs: 10000,
    );

    expect(
      MiniGameEvidencePolicy.isValidGameEvidence(
        matchSeed: matchSeed,
        gameCount: 4,
        evidence: evidence,
        lockedGameIds: const [
          'level_devil',
          'follow_the_cup',
          'find_differences',
          'path_rush',
        ],
      ),
      isFalse,
    );
  });
}
