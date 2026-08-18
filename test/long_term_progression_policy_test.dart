import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/competition/domain/rank_tier.dart';
import 'package:game/features/competition/domain/season_history.dart';
import 'package:game/features/competition/domain/season_reset_policy.dart';
import 'package:game/features/competition/domain/season_reward_policy.dart';
import 'package:game/features/economy/domain/economy_currency_policy.dart';
import 'package:game/features/economy/domain/prestige_star_transaction.dart';

void main() {
  test('rank ladder ends at legend and keeps ordered thresholds', () {
    expect(RankPolicy.bands.length, 8);
    expect(RankPolicy.bands.first.tier, RankTier.bronze);
    expect(RankPolicy.bands.last.tier, RankTier.legend);
    expect(RankPolicy.bands.last.minimumRp, 10000);
  });

  test('season prestige rewards grow with peak rank', () {
    final rewards = RankTier.values
        .map(SeasonRewardPolicy.starsForPeakTier)
        .toList(growable: false);
    for (var i = 1; i < rewards.length; i++) {
      expect(rewards[i], greaterThan(rewards[i - 1]));
    }
    expect(rewards.last, 35);
  });

  test('season soft reset never exceeds closing tier threshold', () {
    for (final tier in RankTier.values) {
      final reset = SeasonResetPolicy.startingRpForPeakTier(tier);
      final threshold = RankPolicy.bands
          .firstWhere((band) => band.tier == tier)
          .minimumRp;
      expect(reset, lessThanOrEqualTo(threshold));
    }
  });

  test('prestige stars cannot be bought or converted', () {
    expect(
      EconomyCurrencyPolicy.canPurchaseWithRealMoney(
        EconomyCurrency.prestigeStars,
      ),
      isFalse,
    );
    expect(
      EconomyCurrencyPolicy.canConvert(
        EconomyCurrency.coins,
        EconomyCurrency.prestigeStars,
      ),
      isFalse,
    );
    expect(
      EconomyCurrencyPolicy.canConvert(
        EconomyCurrency.prestigeStars,
        EconomyCurrency.coins,
      ),
      isFalse,
    );
  });

  test('prestige season transaction id is deterministic', () {
    expect(
      PrestigeStarBalancePolicy.seasonTransactionId(
        uid: 'u1',
        seasonId: 's7',
      ),
      'season:s7:u1',
    );
  });

  test('season history rejects impossible totals', () {
    final invalid = SeasonHistoryEntry(
      seasonId: 's1',
      seasonNumber: 1,
      peakTier: RankTier.gold,
      finalRankPoints: 1300,
      finalStanding: 10,
      wins: 5,
      losses: 4,
      ties: 2,
      gamesPlayed: 10,
      starsAwarded: 4,
      closedAt: DateTime.utc(2026, 8, 30),
    );
    expect(SeasonHistoryPolicy.isValid(invalid), isFalse);
  });
}
