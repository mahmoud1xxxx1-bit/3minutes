import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/cosmic_background.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../data/competition_backend.dart';
import '../domain/leaderboard_entry.dart';
import '../domain/rank_tier.dart';
import '../domain/season.dart';
import '../domain/season_clock.dart';
import '../domain/season_reward_policy.dart';
import 'rank_badge.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({
    super.key,
    required this.competitionBackend,
  });

  final CompetitionBackend competitionBackend;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final liveEnabled = AppConfig.liveLeaderboardEnabled;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          l10n.leaderboard,
          style: const TextStyle(fontWeight: FontWeight.w900),
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
              110,
            ),
            children: [
              CosmicPanel(
                glow: true,
                padding: const EdgeInsets.all(GameSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: GameColors.cosmicGradient,
                            borderRadius: BorderRadius.circular(17),
                            boxShadow: GameShadows.primaryGlow,
                          ),
                          child: Icon(
                            liveEnabled
                                ? Icons.leaderboard_rounded
                                : Icons.calendar_month_rounded,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: GameSpacing.md),
                        Expanded(
                          child: Text(
                            l10n.seasonCompetition,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: GameSpacing.md),
                    Text(
                      l10n.seasonDuration(SeasonPolicy.duration.inDays),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: GameSpacing.xs),
                    Text(
                      l10n.seasonStarsExplanation,
                      style: const TextStyle(color: GameColors.muted),
                    ),
                    const SizedBox(height: GameSpacing.sm),
                    Container(
                      padding: const EdgeInsets.all(GameSpacing.sm),
                      decoration: BoxDecoration(
                        color: GameColors.background.withValues(alpha: .38),
                        borderRadius: BorderRadius.circular(GameRadii.button),
                      ),
                      child: Text(
                        liveEnabled
                            ? l10n.liveStandingsProtected
                            : l10n.liveStandingsLocked,
                        style: const TextStyle(
                          color: GameColors.muted,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (liveEnabled) ...[
                const SizedBox(height: GameSpacing.md),
                _SeasonStatus(competitionBackend: competitionBackend),
              ],
              const SizedBox(height: GameSpacing.lg),
              if (liveEnabled) ...[
                Row(
                  children: [
                    const Icon(
                      Icons.public_rounded,
                      color: GameColors.accentBright,
                    ),
                    const SizedBox(width: GameSpacing.sm),
                    Text(
                      l10n.liveStandings,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: GameSpacing.sm),
                _LiveStandings(competitionBackend: competitionBackend),
                const SizedBox(height: GameSpacing.lg),
              ],
              Row(
                children: [
                  const Icon(
                    Icons.military_tech_rounded,
                    color: GameColors.rewardGold,
                  ),
                  const SizedBox(width: GameSpacing.sm),
                  Text(
                    l10n.rankLadder,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
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

    return CosmicPanel(
      padding: const EdgeInsets.all(GameSpacing.md),
      child: Row(
        children: [
          RankBadge(tier: band.tier),
          const SizedBox(width: GameSpacing.md),
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.star_rounded,
                  color: GameColors.rewardGold,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    l10n.seasonStarsReward(stars),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: GameColors.muted),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: GameSpacing.sm),
          Text(
            l10n.rpWithValue(band.minimumRp),
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
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
      if (!mounted) return;
      setState(() => _now = DateTime.now());
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
          return const _StateCard(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _StateCard(child: Text(l10n.couldNotLoadSeason));
        }

        final season = snapshot.data;
        if (season == null) {
          return _StateCard(child: Text(l10n.noActiveSeason));
        }

        final clock = SeasonClockPolicy.at(season: season, now: _now);
        final remaining = clock.remaining;
        final remainingLabel = clock.active
            ? l10n.seasonRemaining(
                remaining.inDays,
                remaining.inHours.remainder(24),
              )
            : l10n.seasonClosed;

        return CosmicPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.seasonNumber(season.number),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Text(
                    remainingLabel,
                    style: const TextStyle(
                      color: GameColors.rewardGold,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: GameSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(GameRadii.pill),
                child: LinearProgressIndicator(
                  value: clock.progress,
                  minHeight: 9,
                ),
              ),
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

  void _reload() {
    setState(() => _future = widget.competitionBackend.loadLeaderboard());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return FutureBuilder<List<LeaderboardEntry>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _StateCard(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _StateCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.couldNotLoadStandings),
                const SizedBox(height: GameSpacing.sm),
                OutlinedButton(
                  onPressed: _reload,
                  child: Text(l10n.tryAgain),
                ),
              ],
            ),
          );
        }

        final entries = snapshot.data ?? const <LeaderboardEntry>[];
        if (entries.isEmpty) {
          return _StateCard(child: Text(l10n.noRankedPlayers));
        }

        return Column(
          children: [
            for (var index = 0; index < entries.length; index++) ...[
              _LeaderboardRow(index: index, entry: entries[index]),
              if (index + 1 < entries.length)
                const SizedBox(height: GameSpacing.sm),
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

    return CosmicPanel(
      glow: podium,
      padding: const EdgeInsets.all(GameSpacing.sm),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: podium
                ? GameColors.rewardGold.withValues(alpha: .16)
                : GameColors.surfaceRaised,
            child: Text(
              '${index + 1}',
              style: TextStyle(
                color: podium ? GameColors.rewardGold : GameColors.textStrong,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: GameSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.gameName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                RankBadge(
                  tier: entry.tier,
                  compact: true,
                  legendarySeasons: entry.legendarySeasons,
                ),
              ],
            ),
          ),
          const SizedBox(width: GameSpacing.sm),
          Text(
            l10n.rpWithValue(entry.rankPoints),
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CosmicPanel(
      padding: const EdgeInsets.all(GameSpacing.lg),
      child: Center(child: child),
    );
  }
}
