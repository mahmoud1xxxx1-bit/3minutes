import 'package:flutter/material.dart';

import '../../../core/theme/design_tokens.dart';
import '../../economy/domain/cosmetic_loadout.dart';
import '../../economy/presentation/cosmetic_runtime.dart';

class SocialResultWinnerHeader extends StatelessWidget {
  const SocialResultWinnerHeader({
    super.key,
    required this.winnerUid,
    required this.winnerName,
    required this.winnerAvatarId,
    required this.loadout,
    required this.placementLabel,
    required this.isWinner,
  });

  final String winnerUid;
  final String winnerName;
  final String? winnerAvatarId;
  final CosmeticLoadout loadout;
  final String placementLabel;
  final bool isWinner;

  @override
  Widget build(BuildContext context) {
    final avatarId = loadout.avatarId ??
        winnerAvatarId ??
        'avatar_free_vanguard';
    final placementColor =
        isWinner ? GameColors.rewardGold : GameColors.textStrong;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (loadout.victoryEffectId != null) ...[
          CosmeticVictoryEffect(
            effectId: loadout.victoryEffectId!,
            winnerName: winnerName,
            height: 220,
          ),
          const SizedBox(height: GameSpacing.md),
        ],
        CosmeticProfileBackground(
          backgroundId: loadout.profileBackgroundId,
          borderRadius: GameRadii.panel,
          child: Container(
            key: ValueKey('social-result-winner-$winnerUid'),
            padding: const EdgeInsets.all(GameSpacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(GameRadii.panel),
              border: Border.all(
                color: GameColors.rewardGold.withValues(alpha: .34),
              ),
            ),
            child: Column(
              children: [
                CosmeticAvatarView(
                  avatarId: avatarId,
                  frameId: loadout.avatarFrameId,
                  size: 96,
                ),
                const SizedBox(height: GameSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: CosmeticNameText(
                        text: winnerName,
                        styleId: loadout.nameStyleId,
                        fontSize: 21,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    if (loadout.badgeId != null) ...[
                      const SizedBox(width: GameSpacing.xs),
                      CosmeticBadgeView(
                        badgeId: loadout.badgeId!,
                        size: 34,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: GameSpacing.sm),
        Text(
          placementLabel,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: placementColor,
                fontWeight: FontWeight.w900,
              ),
        ),
      ],
    );
  }
}

class SocialPlacementAvatar extends StatelessWidget {
  const SocialPlacementAvatar({
    super.key,
    required this.avatarId,
    required this.position,
    this.size = 42,
  });

  final String? avatarId;
  final int position;
  final double size;

  @override
  Widget build(BuildContext context) {
    final effectiveId = avatarId ?? 'avatar_free_vanguard';
    final winner = position == 1;
    return Container(
      key: ValueKey('social-placement-avatar-$effectiveId'),
      width: size,
      height: size,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: GameColors.surfaceRaised,
        border: Border.all(
          color: winner ? GameColors.rewardGold : GameColors.surfaceStrong,
          width: winner ? 2 : 1,
        ),
      ),
      child: ClipOval(
        child: CosmeticAvatarView(
          avatarId: effectiveId,
          size: size - 4,
        ),
      ),
    );
  }
}
