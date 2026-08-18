import '../../economy/domain/coin_transaction.dart';
import '../../progression/domain/player_progression.dart';
import 'rank_tier.dart';
import 'ranked_reward_policy.dart';
import 'ranked_settlement.dart';

class RankedSettlementPreview {
  const RankedSettlementPreview({
    required this.player,
    required this.progression,
    required this.coins,
  });

  final RankedPlayerSettlement player;
  final PlayerProgression progression;
  final int coins;
}

class RankedSettlementPolicy {
  const RankedSettlementPolicy._();

  static RankedSettlementPreview previewPlayer({
    required String uid,
    required RankedResult result,
    required int currentRp,
    required PlayerProgression currentProgression,
    required int currentCoins,
  }) {
    final reward = RankedRewardPolicy.rewardFor(result);
    final safeRp = currentRp < 0 ? 0 : currentRp;
    final nextRp = RankedRewardPolicy.applyRp(
      currentRp: safeRp,
      delta: reward.rpDelta,
    );
    final nextProgression = ProgressionPolicy.applyXp(
      current: currentProgression,
      earnedXp: reward.xp,
    );
    final nextCoins = CoinBalancePolicy.apply(
      balance: currentCoins,
      delta: reward.coins,
    );

    return RankedSettlementPreview(
      player: RankedPlayerSettlement(
        uid: uid,
        previousRp: safeRp,
        nextRp: nextRp,
        rpDelta: nextRp - safeRp,
        previousTier: RankPolicy.tierFor(safeRp),
        nextTier: RankPolicy.tierFor(nextRp),
        xpAwarded: reward.xp,
        coinsAwarded: reward.coins,
      ),
      progression: nextProgression,
      coins: nextCoins,
    );
  }
}
