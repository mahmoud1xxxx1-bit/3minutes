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
        maxDuration: const Duration(minutes: 3),
        minRawScore: 0,
        maxRawScore: 1000,
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

  MiniGameResult cleared(int milliseconds, {int mistakes = 0}) => MiniGameResult(
        completed: true,
        score: 1000,
        accuracy: 1,
        mistakes: mistakes,
        duration: Duration(milliseconds: milliseconds),
        progressStep: 3,
        progressStepCount: 3,
      );

  MiniGameResult failed(
    int milliseconds, {
    int progressStep = 1,
    int mistakes = 1,
  }) => MiniGameResult(
        completed: false,
        score: 0,
        accuracy: .5,
        mistakes: mistakes,
        duration: Duration(milliseconds: milliseconds),
        progressStep: progressStep,
        progressStepCount: 3,
      );

  MatchGameSubmission submission(String id, MiniGameResult result) =>
      MatchGameSubmission(gameId: id, gameVersion: 1, result: result);

  const engine = MatchResultEngine();
  const order = ['g1', 'g2', 'g3', 'g4'];

  test('more completed 1000-point games wins', () {
    final resolution = engine.resolve(
      matchId: 'match-score',
      playerAId: 'A',
      playerBId: 'B',
      gameOrder: order,
      registry: registry,
      playerASubmissions: [
        submission('g1', cleared(10000)),
        submission('g2', cleared(10000)),
        submission('g3', cleared(10000)),
        submission('g4', cleared(10000)),
      ],
      playerBSubmissions: [
        submission('g1', cleared(8000)),
        submission('g2', cleared(8000)),
        submission('g3', cleared(8000)),
        submission('g4', failed(8000, progressStep: 2)),
      ],
    );

    expect(resolution.winnerId, 'A');
    expect(resolution.reason, MatchResolutionReason.score);
    expect(resolution.playerA.totalScore, 4000);
    expect(resolution.playerB.totalScore, 3000);
  });

  test('equal points at timeout are decided by later locked game position', () {
    final resolution = engine.resolve(
      matchId: 'match-progress',
      playerAId: 'A',
      playerBId: 'B',
      gameOrder: order,
      registry: registry,
      playerASubmissions: [
        submission('g1', cleared(10000)),
        submission('g2', failed(10000)),
      ],
      playerBSubmissions: [
        submission('g1', cleared(9000)),
        submission('g2', failed(9000)),
        submission('g3', failed(9000)),
      ],
    );

    expect(resolution.playerA.totalScore, 1000);
    expect(resolution.playerB.totalScore, 1000);
    expect(resolution.winnerId, 'B');
    expect(resolution.reason, MatchResolutionReason.gameProgress);
  });

  test('same score and same game position with failure is double fail', () {
    final resolution = engine.resolve(
      matchId: 'match-double-fail',
      playerAId: 'A',
      playerBId: 'B',
      gameOrder: order,
      registry: registry,
      playerASubmissions: [
        submission('g1', cleared(10000)),
        submission('g2', failed(8000, progressStep: 2, mistakes: 3)),
      ],
      playerBSubmissions: [
        submission('g1', cleared(9000)),
        submission('g2', failed(7000, progressStep: 1, mistakes: 0)),
      ],
    );

    expect(resolution.winnerId, isNull);
    expect(resolution.loserId, isNull);
    expect(resolution.reason, MatchResolutionReason.doubleFail);
    // Time, mistakes and per-game failure depth do not secretly decide it.
    expect(resolution.playerA.totalScore, resolution.playerB.totalScore);
  });

  test('4000 to 4000 is decided only by lower total completion time', () {
    final resolution = engine.resolve(
      matchId: 'match-time',
      playerAId: 'A',
      playerBId: 'B',
      gameOrder: order,
      registry: registry,
      playerASubmissions: order
          .map((id) => submission(id, cleared(9000)))
          .toList(growable: false),
      playerBSubmissions: order
          .map((id) => submission(id, cleared(10000)))
          .toList(growable: false),
    );

    expect(resolution.winnerId, 'A');
    expect(resolution.reason, MatchResolutionReason.timeTieBreaker);
    expect(resolution.playerA.totalScore, 4000);
    expect(resolution.playerB.totalScore, 4000);

    final receipt = MatchResultReceipt.fromResolution(resolution);
    expect(receipt.decidedByTime, isTrue);
    expect(receipt.timeDifferenceMs, 4000);
    expect(receipt.games, hasLength(4));
  });

  test('exact 4000 score and exact time remains a true tie', () {
    final a = order
        .map((id) => submission(id, cleared(9000)))
        .toList(growable: false);
    final b = order
        .map((id) => submission(id, cleared(9000)))
        .toList(growable: false);

    final resolution = engine.resolve(
      matchId: 'match-exact-tie',
      playerAId: 'A',
      playerBId: 'B',
      gameOrder: order,
      registry: registry,
      playerASubmissions: a,
      playerBSubmissions: b,
    );

    expect(resolution.winnerId, isNull);
    expect(resolution.reason, MatchResolutionReason.exactTie);
  });

  test('completed result cannot award anything except 1000 points', () {
    final invalid = MiniGameResult(
      completed: true,
      score: 900,
      accuracy: 1,
      mistakes: 0,
      duration: const Duration(seconds: 10),
      progressStep: 3,
      progressStepCount: 3,
    );

    expect(
      () => engine.resolve(
        matchId: 'invalid-score',
        playerAId: 'A',
        playerBId: 'B',
        gameOrder: order,
        registry: registry,
        playerASubmissions: [submission('g1', invalid)],
        playerBSubmissions: [submission('g1', failed(10000))],
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
