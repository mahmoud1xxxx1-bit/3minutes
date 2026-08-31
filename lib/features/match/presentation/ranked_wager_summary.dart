import 'package:flutter/material.dart';

import '../../../core/theme/cosmic_background.dart';
import '../../../core/theme/design_tokens.dart';

class RankedWagerSummary extends StatelessWidget {
  const RankedWagerSummary({
    super.key,
    required this.wagerCoins,
    required this.potCoins,
    this.compact = false,
  });

  final int wagerCoins;
  final int potCoins;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    final wager = wagerCoins < 0 ? 0 : wagerCoins;
    final pot = potCoins < 0 ? 0 : potCoins;

    if (compact) {
      return Wrap(
        key: const ValueKey('ranked-wager-summary-compact'),
        spacing: GameSpacing.xs,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Icon(
            Icons.account_balance_wallet_rounded,
            size: 14,
            color: GameColors.rewardGold,
          ),
          Text(
            ar ? 'رهان $wager • الجائزة $pot' : 'Wager $wager • Pot $pot',
            style: const TextStyle(
              color: GameColors.rewardGold,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      );
    }

    return CosmicPanel(
      key: const ValueKey('ranked-wager-summary'),
      padding: const EdgeInsets.symmetric(
        horizontal: GameSpacing.md,
        vertical: GameSpacing.sm,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.account_balance_wallet_rounded,
            color: GameColors.rewardGold,
          ),
          const SizedBox(width: GameSpacing.sm),
          Expanded(
            child: _Value(
              label: ar ? 'رهان كل لاعب' : 'Each wager',
              value: '$wager',
            ),
          ),
          Container(
            width: 1,
            height: 34,
            color: GameColors.surfaceStrong,
          ),
          const SizedBox(width: GameSpacing.md),
          Expanded(
            child: _Value(
              label: ar ? 'الجائزة الكلية' : 'Total pot',
              value: '$pot',
              emphasized: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _Value extends StatelessWidget {
  const _Value({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: GameColors.muted, fontSize: 10),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: emphasized ? GameColors.rewardGold : GameColors.textStrong,
            fontWeight: FontWeight.w900,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
