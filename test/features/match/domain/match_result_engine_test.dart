import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/match/domain/match_result_engine.dart';
import 'package:game/features/match/domain/match_result_receipt.dart';
import 'package:game/features/minigames/domain/mini_game_contract.dart';
import 'package:game/features/minigames/domain/mini_game_engine.dart';
import 'package:game/features/minigames/domain/mini_game_manifest.dart';
import 'package:game/features/minigames/domain/mini_game_registry.dart';

void main() {
  MiniGameManifest manifest(String id) => MiniGameManifest(
        id: id,
        version: 1,
        titleAr: id,
        titleEn: id,
        category: MiniGameCategory.reaction,
        engine: MiniGameEngine.reaction,
        maxDuration: const Duration(minutes: 1),
        minRawScore: 0,
        maxRawScore: 100,
      );

  final registry = MiniGameRegistry(
    registryVersion: 1,
    manifests: [
      manifest('g1'),
      manifest('g2'),
      manifest('g3'),
      manifest('g4'),
    ],
  );

  MiniGameResult result(int score, int milliseconds, {bool completed = true}) {
    return MiniGameResult(
      completed: completed,
      score: score,
      accuracy: 1,
      mistakes: 0,
      duration: Duration(milliseconds: milliseconds),
    );
  }

  MatchGameSubmission submission(String id, int score, int milliseconds, {bool completed = true}) {
    return MatchGameSubmission(
      gameId: id,
      gameVersion: 1,
      result: result(score, milliseconds, completed: completed),
    );
  }

  const engine = MatchResultEngine();
  const order = ['g1', 'g2', 'g3', 'g4'];

  test('higher total normalized score wins', () {
    final resolution = engine.resolve(
      matchId: 'match-score',
      playerAId: 'A',
      playerBId: 'B',
      gameOrder: order,
      registry: registry,
      playerASubmissions: [
        submission('g1', 90, 10000),
        submission('g2', 80, 10000),
        submission('g3', 70, 10000),
        submission('g4', 60, 10000),
      ],
      playerBSubmissions: [
        submission('g1', 50, 5000),
        submission('g2', 50, 5000),
        submission('g3', 50, 5000),
        submission('g4', 50, 5000),
      ],
    );

    expect(resolution.winnerId, 'A');
    expect(resolution.reason, MatchResolutionReason.score);
    expect(resolution.playerA.totalNormalizedScore, 3000);
    expect(resolution.playerB.totalNormalizedScore, 2000);
  });

  test('equal score is decided by lower total time across all four completed games', () {
    final resolution = engine.resolve(
      matchId: 'match-time',
      playerAId: 'A',
      playerBId: 'B',
      gameOrder: order,
      registry: registry,
      playerASubmissions: [
        submission('g1', 50, 9000),
        submission('g2', 50, 9000),
        submission('g3', 50, 9000),
        submission('g4', 50, 9000),
      ],
      playerBSubmissions: [
        submission('g1', 50, 10000),
        submission('g2', 50, 10000),
        submission('g3', 50, 10000),
        submission('g4', 50, 10000),
      ],
    );

    expect(resolution.winnerId, 'A');
    expect(resolution.reason, MatchResolutionReason.timeTieBreaker);
    expect(resolution.playerA.totalDuration, const Duration(seconds: 36));
    expect(resolution.playerB.totalDuration, const Duration(seconds: 40));

    final receipt = MatchResultReceipt.fromResolution(resolution);
    expect(receipt.decidedByTime, isTrue);
    expect(receipt.timeDifferenceMs, 4000);
    expect(receipt.games, hasLength(4));
  });

  test('incomplete game prevents match resolution', () {
    expect(
      () => engine.resolve(
        matchId: 'match-incomplete',
        playerAId: 'A',
        playerBId: 'B',
        gameOrder: order,
        registry: registry,
        playerASubmissions: [
          submission('g1', 50, 10000),
          submission('g2', 50, 10000),
          submission('g3', 50, 10000),
          submission('g4', 50, 10000, completed: false),
        ],
        playerBSubmissions: [
          submission('g1', 50, 10000),
          submission('g2', 50, 10000),
          submission('g3', 50, 10000),
          submission('g4', 50, 10000),
        ],
      ),
      throwsStateError,
    );
  });

  test('registry rejects duplicate game ids', () {
    expect(
      () => MiniGameRegistry(
        registryVersion: 1,
        manifests: [manifest('same'), manifest('same')],
      ),
      throwsStateError,
    );
  });
}
