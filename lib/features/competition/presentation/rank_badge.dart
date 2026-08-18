import 'package:flutter/material.dart';

import '../../../core/theme/design_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/rank_tier.dart';

class RankBadge extends StatelessWidget {
  const RankBadge({
    super.key,
    required this.tier,
    this.compact = false,
  });

  final RankTier tier;
  final bool compact;

  IconData get _icon => switch (tier) {
        RankTier.bronze => Icons.shield_outlined,
        RankTier.silver => Icons.shield,
        RankTier.gold => Icons.workspace_premium_outlined,
        RankTier.platinum => Icons.hexagon_outlined,
        RankTier.diamond => Icons.diamond_outlined,
        RankTier.master => Icons.military_tech_outlined,
      };

  Color get _color => switch (tier) {
        RankTier.bronze => GameColors.rankBronze,
        RankTier.silver => GameColors.rankSilver,
        RankTier.gold => GameColors.rankGold,
        RankTier.platinum => GameColors.rankPlatinum,
        RankTier.diamond => GameColors.rankDiamond,
        RankTier.master => GameColors.rankMaster,
      };

  String _label(AppLocalizations l10n) => switch (tier) {
        RankTier.bronze => l10n.bronze,
        RankTier.silver => l10n.silver,
        RankTier.gold => l10n.gold,
        RankTier.platinum => l10n.platinum,
        RankTier.diamond => l10n.diamond,
        RankTier.master => l10n.master,
      };

  @override
  Widget build(BuildContext context) {
    final color = _color;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 9 : 12,
        vertical: compact ? 5 : 7,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(GameRadii.pill),
        border: Border.all(color: color.withValues(alpha: 0.55)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: compact ? 14 : 18, color: color),
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
