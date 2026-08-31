import 'package:flutter/material.dart';

import '../../../core/theme/design_tokens.dart';
import '../../competition/domain/ranked_settlement_player.dart';

class RankedRewardReceipt extends StatelessWidget {
  const RankedRewardReceipt({
    super.key,
    required this.settlement,
  });

  final RankedSettlementPlayer settlement;

  String _signed(int value) => value > 0 ? '+$value' : '$value';

  @override
  Widget build(BuildContext context) {
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    final wagerPayout = settlement.wagerPayoutCoins;

    return CosmicPanel(
      key: const ValueKey('ranked-reward-receipt'),
      glow: settlement.rpDelta > 0,
      padding: const EdgeInsets.all(GameSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.receipt_long_rounded,
                color: GameColors.accentBright,
              ),
              const SizedBox(width: GameSpacing.sm),
              Expanded(
                child: Text(
                  ar ? 'مكافآت المباراة' : 'Match rewards',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: GameSpacing.md),
          _RewardRow(
            icon: Icons.military_tech_rounded,
            label: 'RP',
            value: _signed(settlement.rpDelta),
            color: settlement.rpDelta < 0 ? GameColors.danger : GameColors.accentBright,
          ),
          const SizedBox(height: GameSpacing.xs),
          _RewardRow(
            icon: Icons.bolt_rounded,
            label: 'XP',
            value: '+${settlement.xpAwarded}',
            color: GameColors.success,
          ),
          const SizedBox(height: GameSpacing.xs),
          _RewardRow(
            icon: Icons.paid_rounded,
            label: ar ? 'مكافأة Coins' : 'Coins reward',
            value: '+${settlement.coinsAwarded}',
            color: GameColors.rewardGold,
          ),
          const SizedBox(height: GameSpacing.xs),
          _RewardRow(
            key: const ValueKey('wager-payout-row'),
            icon: Icons.account_balance_wallet_rounded,
            label: ar ? 'عائد الرهان' : 'Wager payout',
            value: '+$wagerPayout',
            color: wagerPayout > 0 ? GameColors.rewardGold : GameColors.muted,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: GameSpacing.sm),
            child: Divider(height: 1),
          ),
          _RewardRow(
            key: const ValueKey('total-coins-row'),
            icon: Icons.savings_rounded,
            label: ar ? 'إجمالي Coins المستلمة' : 'Total Coins received',
            value: '+${settlement.totalCoinsReceived}',
            color: GameColors.rewardGold,
            emphasize: true,
          ),
        ],
      ),
    );
  }
}

class _RewardRow extends StatelessWidget {
  const _RewardRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.emphasize = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: GameSpacing.sm),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: emphasize ? GameColors.textStrong : GameColors.textSoft,
              fontWeight: emphasize ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w900,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
