import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/arena_ui.dart';
import '../../../core/theme/cosmic_background.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/theme/game_glyphs.dart';
import '../../../l10n/app_localizations.dart';
import '../data/competition_backend.dart';
import '../domain/leaderboard_entry.dart';
import '../domain/rank_tier.dart';
import '../domain/season.dart';
import '../domain/season_clock.dart';
import '../domain/season_reward_policy.dart';
import 'rank_badge.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key, required this.competitionBackend});

  final CompetitionBackend competitionBackend;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final liveEnabled = AppConfig.liveLeaderboardEnabled;
    final ar = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(l10n.leaderboard, style: const TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: CosmicBackground(
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(GameSpacing.md, GameSpacing.sm, GameSpacing.md, 110),
            children: [
              ArenaCard(
                glow: true,
                accent: GameColors.rewardGold,
                padding: const EdgeInsets.all(GameSpacing.lg),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0x3320DDEB), Color(0x337957F5)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: GameColors.rewardGold.withValues(alpha: .28)),
                      ),
                      child: const GameGlyph(
                        type: GameGlyphType.leaderboard,
                        size: 34,
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
                            ar ? 'قمة الساحة' : 'ARENA ELITE',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            liveEnabled
                                ? (ar ? 'أفضل اللاعبين حسب RP في الموسم الحالي.' : 'Top players by RP in the current season.')
                                : (ar ? 'التصنيف المباشر سيظهر هنا عند تفعيل الموسم الحي.' : 'Live ranking appears here when the active season is enabled.'),
                            style: const TextStyle(color: GameColors.textSoft, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (liveEnabled) ...[
                const SizedBox(height: GameSpacing.md),
                _SeasonStatus(competitionBackend: competitionBackend),
                const SizedBox(height: GameSpacing.lg),
                ArenaSectionTitle(
                  title: l10n.liveStandings,
                  subtitle: ar ? 'الترتيب يتغير مع كل مواجهة مصنفة' : 'The ladder shifts after every ranked battle',
                  icon: Icons.public_rounded,
                ),
                const SizedBox(height: GameSpacing.sm),
                _LiveStandings(competitionBackend: competitionBackend),
                const SizedBox(height: GameSpacing.lg),
              ],
              ArenaSectionTitle(
                title: l10n.rankLadder,
                subtitle: ar ? 'ارفع RP لتصل إلى القمة' : 'Build RP to reach the top tier',
                icon: Icons.military_tech_rounded,
              ),
              const SizedBox(height: GameSpacing.sm),
              for (final band in RankPolicy.bands) ...[
                _RankBandCard(band: band),
                const SizedBox(height: GameSpacing.sm),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RankBandCard extends StatelessWidget {
  const _RankBandCard({required this.band});
  final RankBand band;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final stars = SeasonRewardPolicy.starsForPeakTier(band.tier);
    return ArenaCard(
      padding: const EdgeInsets.all(GameSpacing.md),
      child: Row(
        children: [
          RankBadge(tier: band.tier),
          const SizedBox(width: GameSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.rpWithValue(band.minimumRp), style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(l10n.seasonStarsReward(stars), style: const TextStyle(color: GameColors.muted, fontSize: 11)),
              ],
            ),
          ),
          const GameGlyph(type: GameGlyphType.rewards, size: 24, color: GameColors.rewardGold),
        ],
      ),
    );
  }
}

class _SeasonStatus extends StatefulWidget {
  const _SeasonStatus({required this.competitionBackend});
  final CompetitionBackend competitionBackend;

  @override
  State<_SeasonStatus> createState() => _SeasonStatusState();
}

class _SeasonStatusState extends State<_SeasonStatus> {
  Timer? _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return StreamBuilder<Season?>(
      stream: widget.competitionBackend.watchCurrentSeason(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _ArenaState(icon: GameGlyphType.timer, child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _ArenaState(icon: GameGlyphType.shield, child: Text(l10n.couldNotLoadSeason));
        }
        final season = snapshot.data;
        if (season == null) {
          return _ArenaState(icon: GameGlyphType.season, child: Text(l10n.noActiveSeason));
        }
        final clock = SeasonClockPolicy.at(season: season, now: _now);
        final remaining = clock.remaining;
        return ArenaCard(
          accent: GameColors.violet,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const GameGlyph(type: GameGlyphType.season, size: 26, color: GameColors.violet),
                  const SizedBox(width: GameSpacing.sm),
                  Expanded(child: Text(l10n.seasonNumber(season.number), style: const TextStyle(fontWeight: FontWeight.w900))),
                  Text(
                    clock.active
                        ? l10n.seasonRemaining(remaining.inDays, remaining.inHours.remainder(24))
                        : l10n.seasonClosed,
                    style: const TextStyle(color: GameColors.rewardGold, fontWeight: FontWeight.w800, fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(height: GameSpacing.md),
              ArenaProgress(value: clock.progress, color: GameColors.violet),
            ],
          ),
        );
      },
    );
  }
}

class _LiveStandings extends StatefulWidget {
  const _LiveStandings({required this.competitionBackend});
  final CompetitionBackend competitionBackend;

  @override
  State<_LiveStandings> createState() => _LiveStandingsState();
}

class _LiveStandingsState extends State<_LiveStandings> {
  late Future<List<LeaderboardEntry>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.competitionBackend.loadLeaderboard();
  }

  void _reload() => setState(() => _future = widget.competitionBackend.loadLeaderboard());

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FutureBuilder<List<LeaderboardEntry>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _ArenaState(icon: GameGlyphType.leaderboard, child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _ArenaState(
            icon: GameGlyphType.shield,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.couldNotLoadStandings, textAlign: TextAlign.center),
                const SizedBox(height: GameSpacing.sm),
                OutlinedButton(onPressed: _reload, child: Text(l10n.tryAgain)),
              ],
            ),
          );
        }
        final entries = snapshot.data ?? const <LeaderboardEntry>[];
        if (entries.isEmpty) {
          return _ArenaState(icon: GameGlyphType.leaderboard, child: Text(l10n.noRankedPlayers));
        }
        return Column(
          children: [
            for (var index = 0; index < entries.length; index++) ...[
              _LeaderboardRow(index: index, entry: entries[index]),
              if (index + 1 < entries.length) const SizedBox(height: GameSpacing.sm),
            ],
          ],
        );
      },
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  const _LeaderboardRow({required this.index, required this.entry});
  final int index;
  final LeaderboardEntry entry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final podium = index < 3;
    final podiumColor = switch (index) {
      0 => GameColors.rewardGold,
      1 => GameColors.rankSilver,
      2 => GameColors.rankBronze,
      _ => GameColors.surfaceStrong,
    };
    return ArenaCard(
      glow: index == 0,
      accent: podium ? podiumColor : null,
      padding: const EdgeInsets.all(GameSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: podiumColor.withValues(alpha: podium ? .14 : .08),
              border: Border.all(color: podiumColor.withValues(alpha: podium ? .42 : .18)),
            ),
            child: Text('${index + 1}', style: TextStyle(color: podium ? podiumColor : GameColors.textSoft, fontWeight: FontWeight.w900, fontSize: 16)),
          ),
          const SizedBox(width: GameSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.gameName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 5),
                RankBadge(tier: entry.tier, compact: true, legendarySeasons: entry.legendarySeasons),
              ],
            ),
          ),
          const SizedBox(width: GameSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(l10n.rpWithValue(entry.rankPoints), style: const TextStyle(color: GameColors.accentBright, fontWeight: FontWeight.w900)),
              if (podium) ...[
                const SizedBox(height: 4),
                const GameGlyph(type: GameGlyphType.trophy, size: 20, color: GameColors.rewardGold),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ArenaState extends StatelessWidget {
  const _ArenaState({required this.icon, required this.child});
  final GameGlyphType icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ArenaCard(
      padding: const EdgeInsets.all(GameSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GameGlyph(type: icon, size: 38, color: GameColors.muted),
          const SizedBox(height: GameSpacing.md),
          child,
        ],
      ),
    );
  }
}
