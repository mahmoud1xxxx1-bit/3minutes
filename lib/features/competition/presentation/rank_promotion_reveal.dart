import 'package:flutter/material.dart';

import '../../../core/theme/design_tokens.dart';
import '../domain/rank_tier.dart';
import '../domain/ranked_settlement_player.dart';
import 'rank_emblem.dart';

class RankPromotionReveal extends StatefulWidget {
  const RankPromotionReveal({
    super.key,
    required this.settlement,
  });

  final RankedSettlementPlayer settlement;

  @override
  State<RankPromotionReveal> createState() => _RankPromotionRevealState();
}

class _RankPromotionRevealState extends State<RankPromotionReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scale = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, .55, curve: Curves.easeOut),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
      if (reduceMotion) {
        _controller.value = 1;
      } else {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settlement = widget.settlement;
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    final color = _rankColor(settlement.nextTier);

    return Container(
      padding: const EdgeInsets.all(GameSpacing.lg),
      decoration: BoxDecoration(
        gradient: RadialGradient(
          radius: 1.3,
          colors: [
            color.withValues(alpha: .2),
            GameColors.surface,
            GameColors.backgroundDeep,
          ],
        ),
        borderRadius: BorderRadius.circular(GameRadii.panel),
        border: Border.all(color: color.withValues(alpha: .56), width: 1.4),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: .18), blurRadius: 32),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            ar ? 'ترقية رتبة' : 'RANK PROMOTION',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              letterSpacing: ar ? 0 : 2.4,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: GameSpacing.md),
          FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 126,
                    height: 126,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: color.withValues(alpha: .32)),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: .26),
                          blurRadius: 34,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                  ),
                  RankEmblem(tier: settlement.nextTier, size: 104),
                  const Positioned(
                    top: -8,
                    right: 0,
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      color: GameColors.rewardGold,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: GameSpacing.md),
          Text(
            settlement.nextTier.label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 25,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${settlement.previousRp} → ${settlement.nextRp} RP',
            style: const TextStyle(
              color: GameColors.textSoft,
              fontWeight: FontWeight.w800,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            ar
                ? 'تم فتح شارة ${settlement.nextTier.label} نهائيًا في سجل رتبك.'
                : '${settlement.nextTier.label} is now permanently unlocked in your rank legacy.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: GameColors.muted,
              fontSize: 12,
              height: 1.4,
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
