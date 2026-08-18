import 'package:flutter/material.dart';

import '../../../core/theme/cosmic_background.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../competition/domain/rank_tier.dart';
import '../../competition/presentation/rank_badge.dart';
import '../../competition/presentation/season_star_badge.dart';
import '../../economy/data/cosmetic_catalog.dart';
import '../../economy/data/economy_backend.dart';
import '../../economy/domain/cosmetic_item.dart';
import '../../economy/presentation/cosmetic_preview.dart';
import '../../progression/data/achievement_catalog.dart';
import '../../progression/presentation/progression_copy.dart';
import '../data/profile_repository.dart';
import '../domain/player_profile.dart';
import 'profile_screen.dart';
import 'rank_showcase_screen.dart';

class ProfileShowcaseScreen extends StatelessWidget {
  const ProfileShowcaseScreen({
    super.key,
    required this.profile,
    required this.profileRepository,
    required this.economyBackend,
  });

  final PlayerProfile profile;
  final ProfileRepository profileRepository;
  final EconomyBackend economyBackend;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pcopy = ProgressionCopy.of(context);
    final tier = RankPolicy.tierFor(profile.rankPoints);
    final ar = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          l10n.profile,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            tooltip: ar ? 'شارات الرتب' : 'Rank emblems',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => RankShowcaseScreen(
                  profile: profile,
                  profileRepository: profileRepository,
                ),
              ),
            ),
            icon: const Icon(Icons.shield_rounded),
          ),
          IconButton(
            tooltip: l10n.editProfile,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => ProfileScreen(
                  profile: profile,
                  profileRepository: profileRepository,
                ),
              ),
            ),
            icon: const Icon(Icons.edit_rounded),
          ),
        ],
      ),
      body: CosmicBackground(
        child: SafeArea(
          top: false,
          child: StreamBuilder<PlayerInventory?>(
            stream: economyBackend.watchInventory(profile.uid),
            builder: (context, snapshot) {
              final inventory = snapshot.data;
              return ListView(
                padding: const EdgeInsets.fromLTRB(
                  GameSpacing.md,
                  GameSpacing.sm,
                  GameSpacing.md,
                  110,
                ),
                children: [
                  _HeroIdentity(profile: profile, tier: tier),
                  const SizedBox(height: GameSpacing.md),
                  _StatsGrid(profile: profile),
                  const SizedBox(height: GameSpacing.lg),
                  _SectionTitle(
                    icon: Icons.emoji_events_rounded,
                    title: pcopy.achievements,
                    color: GameColors.rewardGold,
                  ),
                  const SizedBox(height: GameSpacing.sm),
                  _AchievementShowcase(profile: profile, copy: pcopy),
                  const SizedBox(height: GameSpacing.lg),
                  _SectionTitle(
                    icon: Icons.auto_awesome_rounded,
                    title: ar ? 'المظهر المجهز' : 'Equipped style',
                    color: GameColors.violet,
                  ),
                  const SizedBox(height: GameSpacing.sm),
                  _EquippedShowcase(inventory: inventory),
                  const SizedBox(height: GameSpacing.lg),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => RankShowcaseScreen(
                          profile: profile,
                          profileRepository: profileRepository,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.shield_rounded),
                    label: Text(ar ? 'شارات الرتب المكتسبة' : 'Earned rank emblems'),
                  ),
                  const SizedBox(height: GameSpacing.sm),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ProfileScreen(
                          profile: profile,
                          profileRepository: profileRepository,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.tune_rounded),
                    label: Text(l10n.editProfile),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.color,
  });

  final IconData icon;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: GameSpacing.sm),
        Text(title, style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }
}

class _HeroIdentity extends StatelessWidget {
  const _HeroIdentity({required this.profile, required this.tier});
  final PlayerProfile profile;
  final RankTier tier;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return CosmicPanel(
      glow: true,
      padding: const EdgeInsets.all(GameSpacing.lg),
      child: Column(
        children: [
          Container(
            width: 108,
            height: 108,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: GameColors.cosmicGradient,
              boxShadow: GameShadows.primaryGlow,
            ),
            child: const DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: GameColors.surface,
              ),
              child: Icon(Icons.person_rounded, size: 58),
            ),
          ),
          const SizedBox(height: GameSpacing.md),
          Text(
            profile.gameName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          if (profile.selectedTitleId != null) ...[
            const SizedBox(height: 4),
            Text(
              profile.selectedTitleId!,
              style: const TextStyle(
                color: GameColors.rewardGold,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
          const SizedBox(height: GameSpacing.sm),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: GameSpacing.sm,
            runSpacing: GameSpacing.xs,
            children: [
              RankBadge(
                tier: tier,
                legendarySeasons: profile.legendarySeasons,
              ),
              SeasonStarBadge(stars: profile.stars),
            ],
          ),
          if (profile.legendarySeasons > 0) ...[
            const SizedBox(height: GameSpacing.sm),
            _LegendaryHistoryLine(count: profile.legendarySeasons),
          ],
          if (profile.showcaseRankTier != null) ...[
            const SizedBox(height: GameSpacing.sm),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.shield_outlined,
                  size: 16,
                  color: GameColors.violet,
                ),
                const SizedBox(width: 5),
                Text(
                  Localizations.localeOf(context).languageCode == 'ar'
                      ? 'شارة العرض: ${profile.showcaseRankTier!.label}'
                      : 'Showcase emblem: ${profile.showcaseRankTier!.label}',
                  style: const TextStyle(
                    color: GameColors.textSoft,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: GameSpacing.sm),
          Text(
            '${l10n.levelWithValue(profile.level)} • ${l10n.rpWithValue(profile.rankPoints)}',
            style: const TextStyle(
              color: GameColors.muted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendaryHistoryLine extends StatelessWidget {
  const _LegendaryHistoryLine({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.history_edu_rounded,
          size: 16,
          color: GameColors.rewardGold,
        ),
        const SizedBox(width: 5),
        Text(
          ar
              ? 'وصل إلى الأسطوري في $count ${count == 1 ? 'موسم' : 'مواسم'}'
              : 'Legendary in $count ${count == 1 ? 'season' : 'seasons'}',
          style: const TextStyle(
            color: GameColors.textSoft,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.profile});
  final PlayerProfile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: GameSpacing.sm,
      mainAxisSpacing: GameSpacing.sm,
      childAspectRatio: 2.25,
      children: [
        _StatCard(
          icon: Icons.emoji_events_rounded,
          label: l10n.wins,
          value: '${profile.wins}',
          color: GameColors.rewardGold,
        ),
        _StatCard(
          icon: Icons.sports_esports_rounded,
          label: l10n.matches,
          value: '${profile.gamesPlayed}',
          color: GameColors.accentBright,
        ),
        _StatCard(
          icon: Icons.percent_rounded,
          label: ar ? 'نسبة الفوز' : 'Win rate',
          value: '${(profile.winRate * 100).toStringAsFixed(1)}%',
          color: GameColors.success,
        ),
        _StatCard(
          icon: Icons.local_fire_department_rounded,
          label: ar ? 'أفضل سلسلة' : 'Best streak',
          value: '${profile.bestWinStreak}',
          color: GameColors.violet,
        ),
        if (profile.legendarySeasons > 0)
          _StatCard(
            icon: Icons.military_tech_rounded,
            label: ar ? 'مواسم أسطورية' : 'Legendary seasons',
            value: '×${profile.legendarySeasons}',
            color: GameColors.rankLegend,
          ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CosmicPanel(
      padding: const EdgeInsets.all(GameSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 21),
          ),
          const SizedBox(width: GameSpacing.sm),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: GameColors.muted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementShowcase extends StatelessWidget {
  const _AchievementShowcase({required this.profile, required this.copy});
  final PlayerProfile profile;
  final ProgressionCopy copy;

  @override
  Widget build(BuildContext context) {
    final ids = profile.showcaseAchievementIds;
    if (ids.isEmpty) {
      return CosmicPanel(
        child: Text(
          Localizations.localeOf(context).languageCode == 'ar'
              ? 'اختر حتى 3 إنجازات لعرضها هنا.'
              : 'Choose up to 3 achievements to showcase here.',
          style: const TextStyle(color: GameColors.muted),
        ),
      );
    }

    return Row(
      children: [
        for (var i = 0; i < ids.length; i++) ...[
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(GameSpacing.sm),
              decoration: BoxDecoration(
                color: GameColors.rewardGold.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(GameRadii.card),
                border: Border.all(
                  color: GameColors.rewardGold.withValues(alpha: .28),
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.emoji_events_rounded,
                    color: GameColors.rewardGold,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    copy.achievement(
                      AchievementCatalog.byId(ids[i])?.id ?? ids[i],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (i != ids.length - 1) const SizedBox(width: GameSpacing.sm),
        ],
      ],
    );
  }
}

class _EquippedShowcase extends StatelessWidget {
  const _EquippedShowcase({required this.inventory});
  final PlayerInventory? inventory;

  @override
  Widget build(BuildContext context) {
    final ids = <String?>[
      inventory?.equippedAvatarFrameId,
      inventory?.equippedBadgeId,
      inventory?.equippedProfileBackgroundId,
      inventory?.equippedNameStyleId,
      inventory?.equippedMatchIntroId,
      inventory?.equippedVictoryEffectId,
      inventory?.equippedRankAuraId,
      inventory?.equippedEmoteId,
      inventory?.equippedRoomThemeId,
    ].whereType<String>().toList();

    if (ids.isEmpty) {
      return CosmicPanel(
        child: Text(
          Localizations.localeOf(context).languageCode == 'ar'
              ? 'جهز عناصر من المتجر لتظهر هنا.'
              : 'Equip shop cosmetics to display them here.',
          style: const TextStyle(color: GameColors.muted),
        ),
      );
    }

    return CosmicPanel(
      child: Wrap(
        spacing: GameSpacing.sm,
        runSpacing: GameSpacing.sm,
        children: [
          for (final id in ids)
            if (CosmeticCatalog.byId(id) case final CosmeticItem item)
              CosmeticPreview(
                item: item,
                rarityColor: _rarityColor(item.rarity),
                size: 66,
              ),
        ],
      ),
    );
  }

  Color _rarityColor(CosmeticRarity rarity) => switch (rarity) {
        CosmeticRarity.common => GameColors.rarityCommon,
        CosmeticRarity.rare => GameColors.rarityRare,
        CosmeticRarity.epic => GameColors.rarityEpic,
        CosmeticRarity.legendary => GameColors.rarityLegendary,
        CosmeticRarity.mythic => GameColors.rarityMythic,
      };
}
