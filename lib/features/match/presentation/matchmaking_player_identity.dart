import 'package:flutter/material.dart';

import '../../../core/theme/design_tokens.dart';
import '../../economy/domain/cosmetic_loadout.dart';
import '../../economy/presentation/cosmetic_runtime.dart';

class MatchmakingPlayerIdentity extends StatelessWidget {
  const MatchmakingPlayerIdentity({
    super.key,
    required this.avatarId,
    required this.displayName,
    required this.loadout,
  });

  final String avatarId;
  final String displayName;
  final CosmeticLoadout loadout;

  @override
  Widget build(BuildContext context) {
    final effectiveAvatarId = loadout.avatarId ?? avatarId;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            CosmeticAvatarView(
              avatarId: effectiveAvatarId,
              frameId: loadout.avatarFrameId,
              size: 106,
            ),
            if (loadout.badgeId != null)
              PositionedDirectional(
                end: -4,
                bottom: 2,
                child: CosmeticBadgeView(
                  badgeId: loadout.badgeId!,
                  size: 32,
                ),
              ),
          ],
        ),
        const SizedBox(height: GameSpacing.sm),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 140),
          child: CosmeticNameText(
            text: displayName,
            styleId: loadout.nameStyleId,
            fontSize: 15,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
