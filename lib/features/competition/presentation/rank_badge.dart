import 'package:flutter/material.dart';

import '../../../core/theme/design_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/rank_tier.dart';
import 'rank_emblem.dart';

class RankBadge extends StatelessWidget {
  const RankBadge({
    super.key,
    required this.tier,
    this.compact = false,
  });

  final RankTier tier;
  final bool compact;

  Color get _color => switch (tier) {
        RankTier.bronze => GameColors.rankBronze,
        RankTier.silver => GameColors.rankSilver,
        RankTier.gold => GameColors.rankGold,
        RankTier.platinum => GameColors.rankPlatinum,
        RankTier.diamond => GameColors.rankDiamond,
        RankTier.master => GameColors.rankMaster,
        RankTier.grandmaster => GameColors.rankGrandmaster,
        RankTier.legend => GameColors.rankLegend,
      };

  String _label(AppLocalizations l10n) => switch (tier) {
        RankTier.bronze => l10n.bronze,
        RankTier.silver => l10n.silver,
        RankTier.gold => l10n.gold,
        RankTier.platinum => l10n.platinum,
        RankTier.diamond => l10n.diamond,
        RankTier.master => l10n.master,
        RankTier.grandmaster => l10n.grandmaster,
        RankTier.legend => l10n.legend,
      };

  @override
  Widget build(BuildContext context) {
    final color = _color;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(
        compact ? 7 : 9,
        compact ? 4 : 5,
        compact ? 10 : 12,
        compact ? 4 : 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(GameRadii.pill),
        border: Border.all(color: color.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.07), blurRadius: 12),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          RankEmblem(tier: tier, size: compact ? 22 : 28),
          const SizedBox(width: GameSpacing.xs),
          Text(
            _label(l10n),
            style: TextStyle(
              color: color,
              fontSize: compact ? 11 : 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
