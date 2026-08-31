import 'package:flutter/material.dart';

import '../../../core/theme/design_tokens.dart';
import '../../economy/presentation/avatar_artwork.dart';

class MatchHistoryAvatar extends StatelessWidget {
  const MatchHistoryAvatar({
    super.key,
    required this.avatarId,
    required this.statusColor,
    required this.statusIcon,
    this.size = 52,
  });

  final String avatarId;
  final Color statusColor;
  final IconData statusIcon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Container(
              key: ValueKey('match-history-avatar-$avatarId'),
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: statusColor.withValues(alpha: .55),
                  width: 1.5,
                ),
                color: GameColors.surfaceRaised,
              ),
              child: ClipOval(
                child: AvatarArtwork(
                  avatarId: avatarId,
                  size: size - 4,
                  borderRadius: size,
                ),
              ),
            ),
          ),
          PositionedDirectional(
            end: -3,
            bottom: -3,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: GameColors.surface,
                border: Border.all(color: statusColor, width: 1.5),
              ),
              child: Icon(statusIcon, size: 13, color: statusColor),
            ),
          ),
        ],
      ),
    );
  }
}
