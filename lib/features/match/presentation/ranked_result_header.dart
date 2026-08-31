import 'package:flutter/material.dart';

import '../../../core/theme/design_tokens.dart';
import '../../economy/data/cosmetic_loadout_repository.dart';
import '../../economy/domain/cosmetic_loadout.dart';
import '../../economy/presentation/cosmetic_runtime.dart';

typedef WinnerLoadoutLoader = Future<CosmeticLoadout> Function(String uid);

class RankedResultHeader extends StatelessWidget {
  const RankedResultHeader({
    super.key,
    required this.winnerUid,
    required this.winnerName,
    required this.winnerAvatarId,
    required this.title,
    required this.resultColor,
    required this.resultIcon,
    this.loadoutLoader,
  });

  final String? winnerUid;
  final String? winnerName;
  final String? winnerAvatarId;
  final String title;
  final Color resultColor;
  final IconData resultIcon;
  final WinnerLoadoutLoader? loadoutLoader;

  @override
  Widget build(BuildContext context) {
    final uid = winnerUid;
    final name = winnerName;
    if (uid == null || name == null) {
      return _DefaultResultHeader(
        title: title,
        resultColor: resultColor,
        resultIcon: resultIcon,
      );
    }

    final loader = loadoutLoader ?? CosmeticLoadoutRepository().load;
    return FutureBuilder<CosmeticLoadout>(
      future: loader(uid),
      builder: (context, snapshot) {
        final loadout = snapshot.data ?? const CosmeticLoadout();
        final avatarId = loadout.avatarId ??
            winnerAvatarId ??
            'avatar_free_vanguard';
        final effectId = loadout.victoryEffectId;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (effectId != null) ...[
              CosmeticVictoryEffect(
                effectId: effectId,
                winnerName: name,
                height: 210,
              ),
              const SizedBox(height: GameSpacing.md),
            ],
            CosmeticProfileBackground(
              backgroundId: loadout.profileBackgroundId,
              borderRadius: GameRadii.panel,
              child: Container(
                key: ValueKey('ranked-result-winner-$uid'),
                padding: const EdgeInsets.all(GameSpacing.md),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(GameRadii.panel),
                  border: Border.all(
                    color: resultColor.withValues(alpha: .34),
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
                            text: name,
                            styleId: loadout.nameStyleId,
                            fontSize: 22,
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
            const SizedBox(height: GameSpacing.md),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: resultColor,
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ],
        );
      },
    );
  }
}

class _DefaultResultHeader extends StatelessWidget {
  const _DefaultResultHeader({
    required this.title,
    required this.resultColor,
    required this.resultIcon,
  });

  final String title;
  final Color resultColor;
  final IconData resultIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: resultColor.withValues(alpha: .10),
              border: Border.all(
                color: resultColor.withValues(alpha: .42),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: resultColor.withValues(alpha: .16),
                  blurRadius: 36,
                ),
              ],
            ),
            child: Icon(resultIcon, size: 56, color: resultColor),
          ),
        ),
        const SizedBox(height: GameSpacing.md),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: resultColor,
                fontWeight: FontWeight.w900,
              ),
        ),
      ],
    );
  }
}
