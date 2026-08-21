import 'package:flutter_test/flutter_test.dart';
import 'package:game/core/config/app_config.dart';
import 'package:game/features/competition/domain/rank_tier.dart';
import 'package:game/features/competition/domain/ranked_reward_policy.dart';
import 'package:game/features/competition/domain/season.dart';
import 'package:game/features/competition/domain/season_reward_policy.dart';
import 'package:game/features/economy/domain/coin_transaction.dart';
import 'package:game/features/match/domain/match_outcome.dart';
import 'package:game/features/match/domain/match_progress.dart';
import 'package:game/features/match/domain/match_runtime.dart';
import 'package:game/features/match/domain/match_settlement.dart';
import 'package:game/features/minigames/data/game_registry.dart';
import 'package:game/features/minigames/domain/mini_game_contract.dart';
import 'package:game/features/profile/domain/player_name_rules.dart';
import 'package:game/features/profile/domain/player_profile.dart';
import 'package:game/features/progression/domain/player_progression.dart';

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

  test('reconnect restores saved progress and resumes next game', () {
    const saved = MatchProgress(
      completedGames: 3,
      totalScore: 280,
      accuracyTotal: 2.5,
      mistakes: 2,
      elapsedMs: 34000,
    );
    final runtime = MatchRuntime(
      seed: 12345,
      startedAt: DateTime.utc(2026, 1, 1),
      gameCount: 8,
      initialProgress: saved,
    );
    final sequence = GameRegistry.sequence(seed: 12345, count: 8);
    expect(runtime.progress.completedGames, 3);
    expect(runtime.progress.totalScore, 280);
    expect(runtime.progress.elapsedMs, 34000);
    expect(runtime.currentGame?.id, sequence[3].id);
  });

  test('settlement waits for opponent before three minute deadline', () {
    final countdown = DateTime.utc(2026, 1, 1, 12);
    const finished = MatchProgress(
      completedGames: 8,
      totalScore: 800,
      accuracyTotal: 8,
      mistakes: 0,
      elapsedMs: 60000,
    );
    const stillPlaying = MatchProgress(
      completedGames: 5,
      totalScore: 500,
      accuracyTotal: 5,
      mistakes: 0,
      elapsedMs: 50000,
    );
    expect(
      MatchSettlement.isSettled(
        playerA: finished,
        playerB: stillPlaying,
        gameCount: 8,
        countdownStartedAt: countdown,
        now: countdown.add(const Duration(seconds: 120)),
      ),
      isFalse,
    );
    expect(
      MatchSettlement.isSettled(
        playerA: finished,
        playerB: stillPlaying,
        gameCount: 8,
        countdownStartedAt: countdown,
        now: countdown.add(const Duration(seconds: 183)),
      ),
      isTrue,
    );
  });

  test('settlement finishes immediately when both players complete', () {
    final countdown = DateTime.utc(2026, 1, 1, 12);
    const complete = MatchProgress(
      completedGames: 8,
      totalScore: 700,
      accuracyTotal: 7.5,
      mistakes: 1,
      elapsedMs: 70000,
    );
    expect(
      MatchSettlement.isSettled(
        playerA: complete,
        playerB: complete,
        gameCount: 8,
        countdownStartedAt: countdown,
        now: countdown.add(const Duration(seconds: 40)),
      ),
      isTrue,
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
      MatchOutcomeResolver.compare(playerA: playerA, playerB: playerB, gameCount: 8),
      MatchOutcome.playerA,
    );
  });

  test('rank policy maps rp to final eight-tier ladder', () {
    expect(RankPolicy.tierFor(0), RankTier.bronze);
    expect(RankPolicy.tierFor(500), RankTier.silver);
    expect(RankPolicy.tierFor(1200), RankTier.gold);
    expect(RankPolicy.tierFor(2200), RankTier.platinum);
    expect(RankPolicy.tierFor(3500), RankTier.diamond);
    expect(RankPolicy.tierFor(5000), RankTier.master);
    expect(RankPolicy.tierFor(7000), RankTier.grandmaster);
    expect(RankPolicy.tierFor(10000), RankTier.legend);
    expect(RankPolicy.tierFor(-100), RankTier.bronze);
  });

  test('season policy stays fixed at thirty days', () {
    final start = DateTime.utc(2026, 8, 1);
    expect(SeasonPolicy.duration, const Duration(days: 30));
    expect(SeasonPolicy.endFor(start), start.add(const Duration(days: 30)));
  });

  test('xp requirement grows predictably by level', () {
    expect(ProgressionPolicy.xpRequiredForLevel(1), 100);
    expect(ProgressionPolicy.xpRequiredForLevel(2), 150);
    expect(ProgressionPolicy.xpRequiredForLevel(10), 550);
    expect(ProgressionPolicy.xpRequiredForLevel(0), 100);
  });

  test('ranked rewards are centralized and rp never becomes negative', () {
    final win = RankedRewardPolicy.rewardFor(RankedResult.win);
    final loss = RankedRewardPolicy.rewardFor(RankedResult.loss);
    final tie = RankedRewardPolicy.rewardFor(RankedResult.tie);
    expect(win.rpDelta, greaterThan(0));
    expect(win.xp, greaterThan(loss.xp));
    expect(win.coins, greaterThan(loss.coins));
    expect(tie.rpDelta, greaterThanOrEqualTo(0));
    expect(RankedRewardPolicy.applyRp(currentRp: 5, delta: loss.rpDelta), 0);
  });

  test('season stars are persistent cumulative identity rewards', () {
    expect(SeasonRewardPolicy.starsForPeakTier(RankTier.bronze), 1);
    expect(SeasonRewardPolicy.starsForPeakTier(RankTier.master), 16);
    expect(SeasonRewardPolicy.starsForPeakTier(RankTier.legend), 35);
    expect(
      SeasonRewardPolicy.nextPersistentStars(
        currentStars: 12,
        peakTier: RankTier.diamond,
      ),
      23,
    );
  });

  test('xp application can cross multiple levels safely', () {
    final next = ProgressionPolicy.applyXp(
      current: const PlayerProgression(level: 1, xp: 90),
      earnedXp: 220,
    );
    expect(next.level, 3);
    expect(next.xp, 60);
    expect(ProgressionPolicy.progressFraction(next), closeTo(0.3, 0.0001));
  });

  test('coin balance rejects overspending', () {
    expect(CoinBalancePolicy.apply(balance: 100, delta: -40), 60);
    expect(() => CoinBalancePolicy.apply(balance: 20, delta: -25), throwsStateError);
  });
}
