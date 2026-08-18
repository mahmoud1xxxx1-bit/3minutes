import 'package:flutter/material.dart';

import '../../../core/theme/design_tokens.dart';

class SeasonStarBadge extends StatelessWidget {
  const SeasonStarBadge({
    super.key,
    required this.stars,
    this.compact = false,
  });

  final int stars;
  final bool compact;

  int get _prestigeLevel {
    if (stars >= 100) return 4;
    if (stars >= 50) return 3;
    if (stars >= 25) return 2;
    if (stars >= 10) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final level = _prestigeLevel;
    final size = compact ? 20.0 : 30.0;
    final ringColor = switch (level) {
      0 => GameColors.rewardGold.withValues(alpha: 0.35),
      1 => GameColors.rankSilver,
      2 => GameColors.rankPlatinum,
      3 => GameColors.rankGold,
      _ => GameColors.accent,
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 11,
        vertical: compact ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: GameColors.rewardGold.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(GameRadii.pill),
        border: Border.all(color: ringColor.withValues(alpha: 0.55)),
        boxShadow: level >= 3
            ? [
                BoxShadow(
                  color: ringColor.withValues(alpha: 0.12),
                  blurRadius: 18,
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              if (level >= 1)
                Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: ringColor,
                      width: level >= 3 ? 2 : 1.4,
                    ),
                  ),
                ),
              Icon(
                Icons.star_rounded,
                color: GameColors.rewardGold,
                size: compact ? 18 : 24,
              ),
              if (level >= 4)
                Positioned(
                  top: 0,
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    color: GameColors.accent,
                    size: compact ? 8 : 10,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 5),
          Text(
            '$stars',
            style: const TextStyle(
              color: GameColors.rewardGold,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
