import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';

import '../../../core/theme/design_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/season_history.dart';
import '../domain/rank_tier.dart';
import 'rank_emblem.dart';

class RankBadge extends StatelessWidget {
  const RankBadge({
    super.key,
    required this.tier,
    this.compact = false,
    this.legendarySeasons = 0,
  });

  final RankTier tier;
  final bool compact;

  /// Permanent Legendary prestige earned in distinct completed seasons.
  /// Only shown when this badge represents the Legendary tier.
  final int legendarySeasons;

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

  bool get _showsPrestige => tier == RankTier.legend && legendarySeasons > 0;

  LegendaryPrestigeLevel get _prestigeLevel =>
      LegendaryPrestigePolicy.levelFor(legendarySeasons);

  IconData? get _prestigeIcon => switch (_prestigeLevel) {
        LegendaryPrestigeLevel.none => null,
        LegendaryPrestigeLevel.legendary => Icons.auto_awesome_rounded,
        LegendaryPrestigeLevel.doubleHalo => Icons.blur_circular_rounded,
        LegendaryPrestigeLevel.crowned => Icons.workspace_premium_rounded,
        LegendaryPrestigeLevel.aura => Icons.flare_rounded,
        LegendaryPrestigeLevel.legacy => Icons.military_tech_rounded,
      };

  double get _glowAlpha => switch (_prestigeLevel) {
        LegendaryPrestigeLevel.none => 0.07,
        LegendaryPrestigeLevel.legendary => 0.12,
        LegendaryPrestigeLevel.doubleHalo => 0.17,
        LegendaryPrestigeLevel.crowned => 0.22,
        LegendaryPrestigeLevel.aura => 0.27,
        LegendaryPrestigeLevel.legacy => 0.34,
      };

  @override
  Widget build(BuildContext context) {
    final color = _color;
    final l10n = AppLocalizations.of(context);
    final prestigeIcon = _prestigeIcon;

    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(
        compact ? 7 : 9,
        compact ? 4 : 5,
        compact ? 10 : 12,
        compact ? 4 : 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: _showsPrestige ? 0.16 : 0.12),
        borderRadius: BorderRadius.circular(GameRadii.pill),
        border: Border.all(
          color: color.withValues(alpha: _showsPrestige ? 0.82 : 0.5),
          width: _showsPrestige ? 1.3 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: _glowAlpha),
            blurRadius: _showsPrestige ? 18 : 12,
          ),
          if (_showsPrestige && legendarySeasons >= 5)
            BoxShadow(
              color: GameColors.violet.withValues(alpha: 0.14),
              blurRadius: 26,
            ),
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
          if (_showsPrestige) ...[
            const SizedBox(width: 4),
            Text(
              '×$legendarySeasons',
              style: TextStyle(
                color: GameColors.textStrong,
                fontSize: compact ? 10 : 12,
                fontWeight: FontWeight.w900,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            if (prestigeIcon != null) ...[
              const SizedBox(width: 3),
              Icon(
                prestigeIcon,
                size: compact ? 13 : 15,
                color: legendarySeasons >= 10
                    ? GameColors.rewardGold
                    : GameColors.rankLegend,
              ),
            ],
          ],
        ],
      ),
    );
  }
}
