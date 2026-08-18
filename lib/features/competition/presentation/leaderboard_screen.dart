import 'package:flutter/material.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/design_tokens.dart';
import '../domain/rank_tier.dart';
import '../domain/season.dart';
import '../domain/season_reward_policy.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

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
            const SizedBox(height: GameSpacing.lg),
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
