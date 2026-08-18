import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/config/app_config.dart';
import '../../auth/data/auth_service.dart';
import '../../profile/data/profile_repository.dart';
import '../../profile/domain/player_profile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.user,
    required this.authService,
    required this.profileRepository,
  });

  final User user;
  final AuthService authService;
  final ProfileRepository profileRepository;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerProfile?>(
      stream: profileRepository.watchProfile(user.uid),
      builder: (context, snapshot) {
        final profile = snapshot.data;

        return Scaffold(
          appBar: AppBar(
            title: const Text(AppConfig.appName),
            actions: [
              IconButton(
                tooltip: 'Sign out',
                onPressed: authService.signOut,
                icon: const Icon(Icons.logout),
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _PlayerCard(profile: profile),
                  const Spacer(),
                  FilledButton(
                    onPressed: null,
                    child: const Text(
                      'PLAY',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '3:00 • ${AppConfig.gamesPerMatch} mini-games',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const Spacer(),
                  const Row(
                    children: [
                      Expanded(
                        child: _MenuTile(
                          icon: Icons.leaderboard,
                          label: 'Leaderboard',
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: _MenuTile(
                          icon: Icons.person,
                          label: 'Profile',
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: _MenuTile(
                          icon: Icons.storefront,
                          label: 'Shop',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PlayerCard extends StatelessWidget {
  const _PlayerCard({required this.profile});

  final PlayerProfile? profile;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 28,
              child: Icon(Icons.person, size: 30),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile?.gameName ?? 'Loading...',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Level ${profile?.level ?? 1} • ${profile?.rankPoints ?? 0} RP',
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded, size: 22),
                const SizedBox(width: 3),
                Text('${profile?.stars ?? 0}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
        child: Column(
          children: [
            Icon(icon),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
      ),
    );
  }
}
