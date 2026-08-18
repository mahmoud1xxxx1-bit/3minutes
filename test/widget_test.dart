import 'package:flutter_test/flutter_test.dart';
import 'package:game/core/config/app_config.dart';
import 'package:game/features/match/domain/match_outcome.dart';
import 'package:game/features/match/domain/match_progress.dart';
import 'package:game/features/match/domain/match_runtime.dart';
import 'package:game/features/minigames/data/game_registry.dart';
import 'package:game/features/minigames/domain/mini_game_contract.dart';
import 'package:game/features/profile/domain/player_name_rules.dart';
import 'package:game/features/profile/domain/player_profile.dart';

void main() {
  test('match configuration stays fixed at three minutes', () {
    expect(AppConfig.matchDuration, const Duration(minutes: 3));
    expect(AppConfig.gamesPerMatch, 8);
  });

  test('player profile map keeps safe defaults', () {
    final profile = PlayerProfile.fromMap('uid-1', const {});

    expect(profile.uid, 'uid-1');
    expect(profile.gameName, 'Player');
    expect(profile.level, 1);
    expect(profile.rankPoints, 0);
    expect(profile.stars, 0);
  });

  test('player name normalization trims and collapses spaces', () {
    expect(PlayerNameRules.validate('  Player   One  '), 'Player One');
    expect(PlayerNameRules.validate('  لاعب   واحد  '), 'لاعب واحد');
  });

  test('player name rejects empty and symbol-only values', () {
    expect(() => PlayerNameRules.validate('   '), throwsArgumentError);
    expect(() => PlayerNameRules.validate('---'), throwsArgumentError);
    expect(() => PlayerNameRules.validate('ab'), throwsArgumentError);
  });

  test('same match seed produces identical eight-game order', () {
    final firstPhone = GameRegistry.sequence(seed: 314159, count: 8);
    final secondPhone = GameRegistry.sequence(seed: 314159, count: 8);

    expect(firstPhone.map((game) => game.id), secondPhone.map((game) => game.id));
    expect(firstPhone.length, AppConfig.gamesPerMatch);
    expect(firstPhone.map((game) => game.id).toSet().length, 8);
  });

  test('registry refuses a match larger than available games', () {
    expect(
      () => GameRegistry.sequence(seed: 1, count: GameRegistry.games.length + 1),
      throwsArgumentError,
    );
  });

  test('match runtime keeps a strict 180 second deadline', () {
    final start = DateTime.utc(2026, 1, 1, 12);
    final runtime = MatchRuntime(seed: 7, startedAt: start, gameCount: 8);

    expect(runtime.endsAt, start.add(const Duration(minutes: 3)));
    expect(runtime.remaining(start), const Duration(minutes: 3));
    expect(runtime.remaining(runtime.endsAt), Duration.zero);
    expect(runtime.isExpired(runtime.endsAt), isTrue);
  });

  test('runtime aggregates only normalized mini-game results', () {
    final runtime = MatchRuntime(
      seed: 9,
      startedAt: DateTime.utc(2026, 1, 1),
      gameCount: 8,
    );

    final progress = runtime.recordResult(
      const MiniGameResult(
        completed: true,
        score: 120,
        accuracy: 0.9,
        mistakes: 1,
        duration: Duration(seconds: 12),
      ),
    );

    expect(progress.completedGames, 1);
    expect(progress.totalScore, 120);
    expect(progress.averageAccuracy, 0.9);
    expect(progress.mistakes, 1);
    expect(progress.elapsedMs, 12000);

    expect(
      () => runtime.recordResult(
        const MiniGameResult(
          completed: true,
          score: 10,
          accuracy: 1.2,
          mistakes: 0,
          duration: Duration(seconds: 1),
        ),
      ),
      throwsArgumentError,
    );
  });

  test('outcome prioritizes progress before score', () {
    const playerA = MatchProgress(
      completedGames: 5,
      totalScore: 10,
      accuracyTotal: 4,
      mistakes: 0,
      elapsedMs: 50000,
    );
    const playerB = MatchProgress(
      completedGames: 4,
      totalScore: 9999,
      accuracyTotal: 4,
      mistakes: 0,
      elapsedMs: 1000,
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
