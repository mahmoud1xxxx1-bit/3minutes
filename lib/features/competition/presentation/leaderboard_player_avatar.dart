import 'package:flutter/material.dart';

import '../../../core/theme/design_tokens.dart';
import '../../economy/presentation/avatar_artwork.dart';

class LeaderboardPlayerAvatar extends StatelessWidget {
  const LeaderboardPlayerAvatar({
    super.key,
    required this.avatarId,
    this.podium = false,
    this.size = 44,
  });

  final String avatarId;
  final bool podium;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey('leaderboard-avatar-$avatarId'),
      width: size,
      height: size,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: podium
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [GameColors.rewardGold, GameColors.violet],
              )
            : null,
        color: podium ? null : GameColors.surfaceStrong,
        boxShadow: podium
            ? [
                BoxShadow(
                  color: GameColors.rewardGold.withValues(alpha: .18),
                  blurRadius: 12,
                ),
              ]
            : null,
      ),
      child: ClipOval(
        child: AvatarArtwork(
          avatarId: avatarId,
          size: size - 4,
          borderRadius: size,
        ),
      ),
    );
  }
}
