import 'package:flutter/material.dart';

import '../domain/rank_tier.dart';
import '../domain/season.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Season competition',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text('Each season lasts ${SeasonPolicy.duration.inDays} days.'),
                    const SizedBox(height: 6),
                    const Text(
                      'Live player standings activate with the secure competition backend so rank points cannot be forged by a modified client.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Rank ladder',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            for (final band in RankPolicy.bands)
              Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.shield_outlined),
                  ),
                  title: Text(band.tier.label),
                  trailing: Text('${band.minimumRp} RP'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
