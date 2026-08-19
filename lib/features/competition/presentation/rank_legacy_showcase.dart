import 'package:flutter/material.dart';

import '../../../core/theme/design_tokens.dart';
import '../domain/rank_tier.dart';
import 'rank_emblem.dart';

class RankLegacyShowcase extends StatelessWidget {
  const RankLegacyShowcase({
    super.key,
    required this.tier,
  });

  final RankTier tier;

  @override
  Widget build(BuildContext context) {
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    final color = _rankColor(tier);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: GameSpacing.md,
        vertical: GameSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .07),
        borderRadius: BorderRadius.circular(GameRadii.card),
        border: Border.all(color: color.withValues(alpha: .3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          RankEmblem(tier: tier, size: 44),
          const SizedBox(width: GameSpacing.sm),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ar ? 'شارة الإرث' : 'LEGACY SHOWCASE',
                style: const TextStyle(
                  color: GameColors.muted,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                tier.label,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(width: GameSpacing.sm),
          Tooltip(
            message: ar
                ? 'شارة تاريخية مكتسبة — لا تغيّر رتبتك الحالية.'
                : 'Earned historical emblem — does not change your current rank.',
            child: const Icon(
              Icons.history_edu_rounded,
              color: GameColors.muted,
              size: 17,
            ),
          ),
        ],
      ),
    );
  }

  Color _rankColor(RankTier tier) => switch (tier) {
        RankTier.bronze => GameColors.rankBronze,
        RankTier.silver => GameColors.rankSilver,
        RankTier.gold => GameColors.rankGold,
        RankTier.platinum => GameColors.rankPlatinum,
        RankTier.diamond => GameColors.rankDiamond,
        RankTier.master => GameColors.rankMaster,
        RankTier.grandmaster => GameColors.rankGrandmaster,
        RankTier.legend => GameColors.rankLegend,
      };
}
