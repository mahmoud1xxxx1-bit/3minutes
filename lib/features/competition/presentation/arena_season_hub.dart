import 'package:flutter/material.dart';

import '../../../core/theme/arena_ui.dart';
import '../../../core/theme/cosmic_background.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/theme/game_glyphs.dart';
import '../data/competition_backend.dart';
import '../domain/rank_tier.dart';
import '../domain/season.dart';
import '../domain/season_clock.dart';
import 'rank_badge.dart';

class ArenaSeasonHub extends StatelessWidget {
  const ArenaSeasonHub({
    super.key,
    required this.uid,
    required this.competitionBackend,
    required this.onOpenMissions,
    required this.onOpenPremium,
    required this.onOpenDetails,
  });

  final String uid;
  final CompetitionBackend competitionBackend;
  final VoidCallback onOpenMissions;
  final VoidCallback onOpenPremium;
  final VoidCallback onOpenDetails;

  @override
  Widget build(BuildContext context) {
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            const GameGlyph(
              type: GameGlyphType.season,
              size: 25,
              color: GameColors.rewardGold,
              active: true,
            ),
            const SizedBox(width: 10),
            Text(ar ? 'الموسم' : 'SEASON'),
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
              _SeasonHero(
                backend: competitionBackend,
                ar: ar,
              ),
              const SizedBox(height: GameSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _Gateway(
                      glyph: GameGlyphType.missions,
                      title: ar ? 'المهام' : 'MISSIONS',
                      subtitle: ar ? 'يومية وأسبوعية' : 'Daily & weekly',
                      color: GameColors.accentBright,
                      onTap: onOpenMissions,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: _Gateway(
                      glyph: GameGlyphType.rewards,
                      title: ar ? 'المسار المميز' : 'PREMIUM',
                      subtitle: ar ? 'مكافآت الموسم' : 'Season rewards',
                      color: GameColors.rewardGold,
                      onTap: onOpenPremium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: GameSpacing.lg),
              ArenaSectionTitle(
                title: ar ? 'سلم الرتب' : 'RANK LADDER',
                subtitle: ar
                    ? 'ارتقِ من البرونزي حتى الأسطوري عبر RP.'
                    : 'Climb from Bronze to Legendary through RP.',
                trailing: const GameGlyph(
                  type: GameGlyphType.trophy,
                  size: 26,
                  color: GameColors.rewardGold,
                ),
              ),
              const SizedBox(height: GameSpacing.sm),
              _RankRoad(ar: ar),
              const SizedBox(height: GameSpacing.md),
              ArenaPlayButton(
                title: ar ? 'تفاصيل الموسم' : 'SEASON DETAILS',
                subtitle: ar
                    ? 'الترتيب، السجل ومكافآت كل رتبة'
                    : 'Standings, history and rank rewards',
                icon: Icons.arrow_forward_rounded,
                primary: false,
                onPressed: onOpenDetails,
              ),
              const SizedBox(height: GameSpacing.lg),
              ArenaCard(
                accent: GameColors.success,
                child: Row(
                  children: [
                    const GameGlyph(
                      type: GameGlyphType.shield,
                      size: 28,
                      color: GameColors.success,
                      active: true,
                    ),
                    const SizedBox(width: GameSpacing.md),
                    Expanded(
                      child: Text(
                        ar
                            ? 'الرتبة وRP تعتمد على اللعب والنتائج فقط. مكافآت الموسم لا تمنح قوة تنافسية.'
                            : 'Rank and RP come from gameplay results only. Season rewards never grant competitive power.',
                        style: const TextStyle(
                          color: GameColors.textSoft,
                          height: 1.45,
                          fontSize: 11,
                        ),
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
}

class _SeasonHero extends StatelessWidget {
  const _SeasonHero({required this.backend, required this.ar});
  final CompetitionBackend backend;
  final bool ar;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Season?>(
      stream: backend.watchCurrentSeason(),
      builder: (context, snapshot) {
        final season = snapshot.data;
        final now = DateTime.now();
        final clock = season == null ? null : SeasonClockPolicy.at(season: season, now: now);
        final days = clock?.remaining.inDays ?? 0;
        final progress = clock?.progress ?? .0;
        return Container(
          padding: const EdgeInsets.all(GameSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(27),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF38245E), Color(0xFF172D55), Color(0xFF09152C)],
            ),
            border: Border.all(color: GameColors.rewardGold.withValues(alpha: .28)),
            boxShadow: const [
              BoxShadow(color: Color(0x263B6FFF), blurRadius: 30, offset: Offset(0, 12)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 66,
                    height: 66,
                    decoration: BoxDecoration(
                      color: GameColors.rewardGold.withValues(alpha: .10),
                      borderRadius: BorderRadius.circular(21),
                      border: Border.all(color: GameColors.rewardGold.withValues(alpha: .30)),
                    ),
                    alignment: Alignment.center,
                    child: const GameGlyph(
                      type: GameGlyphType.season,
                      size: 37,
                      color: GameColors.rewardGold,
                      active: true,
                    ),
                  ),
                  const SizedBox(width: GameSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          season == null
                              ? (ar ? 'الموسم الحالي' : 'CURRENT SEASON')
                              : (ar ? 'الموسم ${season.number}' : 'SEASON ${season.number}'),
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          ar
                              ? 'تقدم، ارتقِ، واجمع مكافآت الموسم.'
                              : 'Climb, compete and earn seasonal rewards.',
                          style: const TextStyle(color: GameColors.textSoft, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  ArenaPill(
                    label: clock?.active == true
                        ? (ar ? '$days يوم' : '${days}D')
                        : (ar ? 'قريبًا' : 'SOON'),
                    color: GameColors.rewardGold,
                    solid: true,
                  ),
                ],
              ),
              const SizedBox(height: GameSpacing.lg),
              Row(
                children: [
                  Text(
                    ar ? 'تقدم الموسم' : 'SEASON PROGRESS',
                    style: const TextStyle(color: GameColors.muted, fontSize: 10, fontWeight: FontWeight.w900),
                  ),
                  const Spacer(),
                  Text(
                    '${(progress * 100).round()}%',
                    style: const TextStyle(color: GameColors.rewardGold, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ArenaProgress(value: progress, color: GameColors.rewardGold, height: 8),
            ],
          ),
        );
      },
    );
  }
}

class _Gateway extends StatelessWidget {
  const _Gateway({
    required this.glyph,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
  final GameGlyphType glyph;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ArenaCard(
      accent: color,
      glow: true,
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GameGlyph(type: glyph, size: 29, color: color, active: true),
          const SizedBox(height: 13),
          Text(title, maxLines: 1, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
          const SizedBox(height: 3),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: GameColors.muted, fontSize: 9, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _RankRoad extends StatelessWidget {
  const _RankRoad({required this.ar});
  final bool ar;

  @override
  Widget build(BuildContext context) {
    return ArenaCard(
      accent: GameColors.violet,
      child: Column(
        children: [
          for (var i = 0; i < RankPolicy.bands.length; i++) ...[
            _RankNode(band: RankPolicy.bands[i], last: i == RankPolicy.bands.length - 1),
          ],
        ],
      ),
    );
  }
}

class _RankNode extends StatelessWidget {
  const _RankNode({required this.band, required this.last});
  final RankBand band;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final color = switch (band.tier) {
      RankTier.bronze => GameColors.rankBronze,
      RankTier.silver => GameColors.rankSilver,
      RankTier.gold => GameColors.rankGold,
      RankTier.platinum => GameColors.rankPlatinum,
      RankTier.diamond => GameColors.rankDiamond,
      RankTier.master => GameColors.rankMaster,
      RankTier.grandmaster => GameColors.rankGrandmaster,
      RankTier.legend => GameColors.rankLegend,
    };
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: .13),
                border: Border.all(color: color.withValues(alpha: .55), width: 1.4),
              ),
              alignment: Alignment.center,
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              ),
            ),
            if (!last)
              Container(width: 1.5, height: 38, color: GameColors.surfaceStrong),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Row(
              children: [
                Expanded(child: RankBadge(tier: band.tier, compact: true)),
                Text(
                  '${band.minimumRp} RP',
                  style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
