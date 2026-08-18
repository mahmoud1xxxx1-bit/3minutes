import 'package:flutter/material.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/design_tokens.dart';
import '../data/competition_backend.dart';
import '../domain/leaderboard_entry.dart';
import '../domain/rank_tier.dart';
import '../domain/season.dart';
import '../domain/season_clock.dart';
import '../domain/season_reward_policy.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({
    super.key,
    required this.competitionBackend,
  });

  final CompetitionBackend competitionBackend;

  @override
  Widget build(BuildContext context) {
    final liveEnabled = AppConfig.liveLeaderboardEnabled;

    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(GameSpacing.md),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(GameSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(
                          liveEnabled
                              ? Icons.leaderboard_outlined
                              : Icons.calendar_month_outlined,
                        ),
                        const SizedBox(width: GameSpacing.sm),
                        Expanded(
                          child: Text(
                            'Season competition',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: GameSpacing.sm),
                    Text('Each season lasts ${SeasonPolicy.duration.inDays} days.'),
                    const SizedBox(height: GameSpacing.xs),
                    const Text(
                      'Your highest tier in the season awards permanent stars. Stars stay on your identity and never affect gameplay.',
                    ),
                    const SizedBox(height: GameSpacing.sm),
                    Text(
                      liveEnabled
                          ? 'Live standings are protected by the secure competition backend.'
                          : 'Live player standings activate with the secure competition backend so RP cannot be forged by a modified client.',
                      style: const TextStyle(color: GameColors.muted),
                    ),
                  ],
                ),
              ),
            ),
            if (liveEnabled) ...[
              const SizedBox(height: GameSpacing.md),
              _SeasonStatus(competitionBackend: competitionBackend),
            ],
            const SizedBox(height: GameSpacing.lg),
            if (liveEnabled) ...[
              Text(
                'Live standings',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: GameSpacing.sm),
              _LiveStandings(competitionBackend: competitionBackend),
              const SizedBox(height: GameSpacing.lg),
            ],
            Text(
              'Rank ladder',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: GameSpacing.sm),
            for (final band in RankPolicy.bands) ...[
              Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: GameColors.surfaceRaised,
                    child: const Icon(Icons.shield_outlined),
                  ),
                  title: Text(
                    band.tier.label,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    '${SeasonRewardPolicy.starsForPeakTier(band.tier)} season stars',
                  ),
                  trailing: Text('${band.minimumRp} RP'),
                ),
              ),
              const SizedBox(height: GameSpacing.sm),
            ],
          ],
        ),
      ),
    );
  }
}

class _SeasonStatus extends StatelessWidget {
  const _SeasonStatus({required this.competitionBackend});

  final CompetitionBackend competitionBackend;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Season?>(
      stream: competitionBackend.watchCurrentSeason(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(GameSpacing.md),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(GameSpacing.md),
              child: Text(
                'Could not load the current season.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final season = snapshot.data;
        if (season == null) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(GameSpacing.md),
              child: Text(
                'No active season.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final clock = SeasonClockPolicy.at(season: season, now: DateTime.now());
        final remaining = clock.remaining;
        final days = remaining.inDays;
        final hours = remaining.inHours.remainder(24);
        final remainingLabel = clock.active
            ? '${days}d ${hours}h remaining'
            : 'Season closed';

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(GameSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Season #${season.number}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                    Text(
                      remainingLabel,
                      style: const TextStyle(color: GameColors.muted),
                    ),
                  ],
                ),
                const SizedBox(height: GameSpacing.sm),
                LinearProgressIndicator(value: clock.progress),
              ],
            ),
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
    return FutureBuilder<List<LeaderboardEntry>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(GameSpacing.lg),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(GameSpacing.md),
              child: Column(
                children: [
                  const Text('Could not load live standings.'),
                  const SizedBox(height: GameSpacing.sm),
                  OutlinedButton(
                    onPressed: _reload,
                    child: const Text('TRY AGAIN'),
                  ),
                ],
              ),
            ),
          );
        }

        final entries = snapshot.data ?? const <LeaderboardEntry>[];
        if (entries.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(GameSpacing.md),
              child: Text(
                'No ranked players yet.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return Column(
          children: [
            for (var index = 0; index < entries.length; index++) ...[
              Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: GameColors.surfaceRaised,
                    child: Text('${index + 1}'),
                  ),
                  title: Text(entries[index].gameName),
                  subtitle: Text(
                    '${entries[index].tier.label} • ${entries[index].wins}W ${entries[index].losses}L',
                  ),
                  trailing: Text(
                    '${entries[index].rankPoints} RP',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              if (index + 1 < entries.length)
                const SizedBox(height: GameSpacing.sm),
            ],
          ],
        );
      },
    );
  }
}
