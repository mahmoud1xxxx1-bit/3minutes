import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/competition/domain/match_integrity_policy.dart';
import 'package:game/features/competition/domain/rank_tier.dart';
import 'package:game/features/competition/domain/ranked_reward_policy.dart';
import 'package:game/features/competition/domain/season_reward_policy.dart';
import 'package:game/features/economy/domain/coin_transaction.dart';
import 'package:game/features/match/domain/match_progress.dart';
import 'package:game/features/progression/domain/player_progression.dart';

void main() {
  group('ranked authority policies', () {
    test('valid four-game progress passes integrity checks', () {
      const progress = MatchProgress(
        completedGames: 4,
        totalScore: 400,
        accuracyTotal: 3.8,
        mistakes: 2,
        elapsedMs: 120000,
      );

      final report = MatchIntegrityPolicy.validateProgress(
        progress: progress,
        gameCount: 4,
      );

      expect(report.valid, isTrue);
      expect(report.reasons, isEmpty);
    });

    test('impossible progress is rejected with explicit reasons', () {
      const progress = MatchProgress(
        completedGames: 5,
        totalScore: -1,
        accuracyTotal: 12,
        mistakes: -2,
        elapsedMs: 181000,
      );

      final report = MatchIntegrityPolicy.validateProgress(
        progress: progress,
        gameCount: 4,
      );

      expect(report.valid, isFalse);
      expect(report.reasons, contains('invalid_completed_games'));
      expect(report.reasons, contains('negative_score'));
      expect(report.reasons, contains('invalid_accuracy_total'));
      expect(report.reasons, contains('negative_mistakes'));
      expect(report.reasons, contains('invalid_elapsed_time'));
    });

    test('rank rewards never produce negative RP', () {
      final loss = RankedRewardPolicy.rewardFor(RankedResult.loss);
      expect(
        RankedRewardPolicy.applyRp(currentRp: 3, delta: loss.rpDelta),
        0,
      );
    });

    test('persistent stars accumulate from peak season tier', () {
      expect(
        SeasonRewardPolicy.nextPersistentStars(
          currentStars: 10,
          peakTier: RankTier.master,
        ),
        26,
      );
    });

    test('large XP reward crosses multiple levels correctly', () {
      final next = ProgressionPolicy.applyXp(
        current: const PlayerProgression(level: 1, xp: 0),
        earnedXp: 500,
      );

      expect(next.level, 4);
      expect(next.xp, 50);
    });

    test('coin spending cannot overdraw balance', () {
      expect(CoinBalancePolicy.apply(balance: 75, delta: -25), 50);
      expect(
        () => CoinBalancePolicy.apply(balance: 5, delta: -10),
        throwsStateError,
      );
    });
  });
}

