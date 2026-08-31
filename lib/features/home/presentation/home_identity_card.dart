import 'package:flutter/material.dart';

import '../../../core/theme/design_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../competition/domain/rank_tier.dart';
import '../../competition/presentation/rank_badge.dart';
import '../../competition/presentation/season_star_badge.dart';
import '../../economy/domain/cosmetic_item.dart';
import '../../economy/presentation/cosmetic_runtime.dart';
import '../../profile/domain/player_profile.dart';

class HomeIdentityCard extends StatelessWidget {
  const HomeIdentityCard({
    super.key,
    required this.profile,
    this.inventory,
  });

  final PlayerProfile? profile;
  final PlayerInventory? inventory;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final player = profile;
    final rp = player?.rankPoints ?? 0;
    final tier = RankPolicy.tierFor(rp);
    final avatarId = inventory?.equippedAvatarId ??
        player?.avatarId ??
        'avatar_free_vanguard';
    final frameId = inventory?.equippedAvatarFrameId;
    final badgeId = inventory?.equippedBadgeId;
    final backgroundId = inventory?.equippedProfileBackgroundId;
    final nameStyleId = inventory?.equippedNameStyleId;
    final auraId = inventory?.equippedRankAuraId;

    return CosmeticProfileBackground(
      backgroundId: backgroundId,
      borderRadius: GameRadii.panel,
      child: Container(
        padding: const EdgeInsets.all(GameSpacing.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(GameRadii.panel),
          border: Border.all(
            color: backgroundId == null
                ? GameColors.surfaceStrong
                : GameColors.accentBright.withValues(alpha: .3),
            width: .8,
          ),
        ),
        child: Row(
          children: [
            CosmeticAvatarView(
              avatarId: avatarId,
              frameId: frameId,
              size: 68,
            ),
            const SizedBox(width: GameSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: CosmeticNameText(
                          text: player?.gameName ?? '—',
                          styleId: nameStyleId,
                          fontSize: 20,
                        ),
                      ),
                      if (badgeId != null) ...[
                        const SizedBox(width: GameSpacing.xs),
                        CosmeticBadgeView(badgeId: badgeId, size: 28),
                      ],
                    ],
                  ),
                  const SizedBox(height: GameSpacing.xs),
                  Wrap(
                    spacing: GameSpacing.sm,
                    runSpacing: GameSpacing.xs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      CosmeticRankAura(
                        auraId: auraId,
                        padding: auraId == null ? 0 : 3,
                        child: RankBadge(
                          tier: tier,
                          compact: true,
                          legendarySeasons: player?.legendarySeasons ?? 0,
                        ),
                      ),
                      Text(
                        l10n.levelWithValue(player?.level ?? 1),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: GameSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  l10n.rpWithValue(rp),
                  style: const TextStyle(
                    color: GameColors.accentBright,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: GameSpacing.xs),
                SeasonStarBadge(stars: player?.stars ?? 0, compact: true),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
