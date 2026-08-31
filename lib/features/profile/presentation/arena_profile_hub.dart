import 'package:flutter/material.dart';

import '../../../core/theme/arena_ui.dart';
import '../../../core/theme/cosmic_background.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/theme/game_glyphs.dart';
import '../../competition/domain/rank_tier.dart';
import '../../competition/presentation/rank_badge.dart';
import '../../economy/presentation/avatar_artwork.dart';
import '../domain/player_profile.dart';

class ArenaProfileHub extends StatelessWidget {
  const ArenaProfileHub({
    super.key,
    required this.profile,
    required this.onOpenShowcase,
  });

  final PlayerProfile profile;
  final VoidCallback onOpenShowcase;

  @override
  Widget build(BuildContext context) {
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    final tier = RankPolicy.tierFor(profile.rankPoints);
    final winRate = (profile.winRate * 100).round();
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            const GameGlyph(
              type: GameGlyphType.identity,
              size: 25,
              color: GameColors.accentBright,
              active: true,
            ),
            const SizedBox(width: 10),
            Text(ar ? 'هوية اللاعب' : 'PLAYER IDENTITY'),
          ],
        ),
      ),
      body: CosmicBackground(
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              GameSpacing.md,
              GameSpacing.sm,
              GameSpacing.md,
              112,
            ),
            children: [
              _IdentityCard(profile: profile, tier: tier),
              const SizedBox(height: GameSpacing.md),
              Row(
                children: [
                  ArenaMetric(
                    label: ar ? 'نسبة الفوز' : 'WIN RATE',
                    value: '$winRate%',
                    icon: Icons.trending_up_rounded,
                    color: GameColors.success,
                  ),
                  const SizedBox(width: 8),
                  ArenaMetric(
                    label: ar ? 'أفضل سلسلة' : 'BEST STREAK',
                    value: '${profile.bestWinStreak}',
                    icon: Icons.local_fire_department_rounded,
                    color: GameColors.warning,
                  ),
                  const SizedBox(width: 8),
                  ArenaMetric(
                    label: ar ? 'المواجهات' : 'BATTLES',
                    value: '${profile.gamesPlayed}',
                    icon: Icons.sports_esports_rounded,
                    color: GameColors.violet,
                  ),
                ],
              ),
              const SizedBox(height: GameSpacing.lg),
              ArenaSectionTitle(
                title: ar ? 'تقدمك التنافسي' : 'COMPETITIVE PROGRESS',
                subtitle: ar
                    ? 'كل مباراة تكتب جزءًا من سجل اللاعب.'
                    : 'Every battle writes another line in your player record.',
                trailing: const GameGlyph(
                  type: GameGlyphType.trophy,
                  size: 25,
                  color: GameColors.rewardGold,
                ),
              ),
              const SizedBox(height: GameSpacing.sm),
              ArenaCard(
                accent: _rankColor(tier),
                glow: tier.index >= RankTier.diamond.index,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            ar ? 'الرتبة الحالية' : 'CURRENT RANK',
                            style: const TextStyle(color: GameColors.muted, fontSize: 10, fontWeight: FontWeight.w900),
                          ),
                        ),
                        Text(
                          '${profile.rankPoints} RP',
                          style: TextStyle(color: _rankColor(tier), fontWeight: FontWeight.w900, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        RankBadge(
                          tier: tier,
                          legendarySeasons: profile.legendarySeasons,
                        ),
                        const Spacer(),
                        ArenaPill(
                          label: ar ? 'المستوى ${profile.level}' : 'LV ${profile.level}',
                          color: GameColors.violet,
                          solid: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: GameSpacing.md),
                    ArenaProgress(
                      value: _rankProgress(profile.rankPoints),
                      color: _rankColor(tier),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: GameSpacing.md),
              ArenaPlayButton(
                title: ar ? 'عرض الملف الكامل' : 'OPEN FULL SHOWCASE',
                subtitle: ar
                    ? 'الشارات، المظهر، الإنجازات وتفاصيل الحساب'
                    : 'Badges, cosmetics, achievements and account details',
                icon: Icons.arrow_forward_rounded,
                primary: false,
                onPressed: onOpenShowcase,
              ),
              const SizedBox(height: GameSpacing.lg),
              ArenaCard(
                accent: GameColors.accentBright,
                child: Row(
                  children: [
                    const GameGlyph(
                      type: GameGlyphType.shield,
                      size: 28,
                      color: GameColors.accentBright,
                    ),
                    const SizedBox(width: GameSpacing.md),
                    Expanded(
                      child: Text(
                        ar
                            ? 'ملفك هو هويتك داخل الساحة. الرتبة والإحصائيات تعكس اللعب الفعلي فقط.'
                            : 'Your profile is your arena identity. Rank and stats reflect real gameplay only.',
                        style: const TextStyle(color: GameColors.textSoft, fontSize: 11, height: 1.45),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static double _rankProgress(int rp) {
    final tier = RankPolicy.tierFor(rp);
    final index = RankPolicy.bands.indexWhere((band) => band.tier == tier);
    if (index < 0 || index >= RankPolicy.bands.length - 1) return 1;
    final floor = RankPolicy.bands[index].minimumRp;
    final ceiling = RankPolicy.bands[index + 1].minimumRp;
    return ((rp - floor) / (ceiling - floor)).clamp(0.0, 1.0).toDouble();
  }

  static Color _rankColor(RankTier tier) => switch (tier) {
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

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.profile, required this.tier});
  final PlayerProfile profile;
  final RankTier tier;

  @override
  Widget build(BuildContext context) {
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    return Container(
      padding: const EdgeInsets.all(GameSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(27),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF173A58), Color(0xFF20214E), Color(0xFF09152C)],
        ),
        border: Border.all(color: GameColors.accentBright.withValues(alpha: .24)),
        boxShadow: const [BoxShadow(color: Color(0x332B72FF), blurRadius: 30, offset: Offset(0, 12))],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 126,
                height: 126,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: GameColors.cosmicGradient,
                  boxShadow: GameShadows.primaryGlow,
                ),
                padding: const EdgeInsets.all(3),
                child: ClipOval(
                  child: ColoredBox(
                    color: GameColors.surface,
                    child: AvatarArtwork(
                      avatarId: profile.avatarId,
                      size: 120,
                      borderRadius: 60,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -12,
                child: RankBadge(
                  tier: tier,
                  compact: true,
                  legendarySeasons: profile.legendarySeasons,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            profile.gameName,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: .4),
          ),
          const SizedBox(height: 5),
          Text(
            ar ? 'لاعب 3 Minutes' : '3 MINUTES PLAYER',
            style: const TextStyle(color: GameColors.accentBright, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2),
          ),
          const SizedBox(height: GameSpacing.md),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 7,
            runSpacing: 7,
            children: [
              ArenaPill(label: '${profile.rankPoints} RP', color: _rankColor(tier), solid: true),
              ArenaPill(label: ar ? 'المستوى ${profile.level}' : 'LEVEL ${profile.level}', color: GameColors.violet),
              ArenaPill(label: '★ ${profile.stars}', color: GameColors.rewardGold),
            ],
          ),
        ],
      ),
    );
  }

  static Color _rankColor(RankTier tier) => ArenaProfileHub._rankColor(tier);
}
