import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/competition/data/mini_game_evidence_policy.dart';
import 'package:game/features/competition/domain/mini_game_evidence.dart';
import 'package:game/features/minigames/data/game_registry.dart';

void main() {
  test('ranked evidence accepts the deterministic match sequence', () {
    const matchSeed = 424242;
    final games = GameRegistry.sequence(seed: matchSeed, count: 8);
    final evidence = <MiniGameEvidence>[
      for (var index = 0; index < games.length; index++)
        MiniGameEvidence(
          gameId: games[index].id,
          gameIndex: index,
          gameSeed: MiniGameEvidencePolicy.gameSeed(
            matchSeed: matchSeed,
            gameIndex: index,
          ),
          score: 100,
          accuracy: 0.9,
          mistakes: 1,
          durationMs: 10000,
        ),
    ];

    expect(
      MiniGameEvidencePolicy.isValidMatchEvidence(
        matchSeed: matchSeed,
        gameCount: 8,
        evidence: evidence,
      ),
      isTrue,
    );
  });

  test('ranked evidence rejects a forged game id or seed', () {
    const matchSeed = 99;
    final games = GameRegistry.sequence(seed: matchSeed, count: 8);
    final forged = [
      MiniGameEvidence(
        gameId: games.first.id,
        gameIndex: 0,
        gameSeed: -1,
        score: 100,
        accuracy: 1,
        mistakes: 0,
        durationMs: 5000,
      ),
    ];

    expect(
      MiniGameEvidencePolicy.isValidMatchEvidence(
        matchSeed: matchSeed,
        gameCount: 8,
        evidence: forged,
      ),
      isFalse,
    );
  });
}
