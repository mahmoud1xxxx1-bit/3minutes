import 'package:flutter/material.dart';

import '../../../core/theme/design_tokens.dart';
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: GameColors.surfaceRaised,
        borderRadius: BorderRadius.circular(GameRadii.button),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: compact ? 14 : 17),
          const SizedBox(width: GameSpacing.xs),
          Text(
            tier.label,
            style: TextStyle(
              fontSize: compact ? 11 : 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
