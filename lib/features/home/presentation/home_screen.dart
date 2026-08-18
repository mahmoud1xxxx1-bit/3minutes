import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/config/app_config.dart';
import '../../auth/data/auth_service.dart';
import '../../match/data/match_backend.dart';
import '../../match/domain/match_ticket.dart';
import '../../match/presentation/match_room_screen.dart';
import '../../match/presentation/matchmaking_screen.dart';
import '../../profile/data/profile_repository.dart';
import '../../profile/domain/player_profile.dart';
import '../../profile/presentation/profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.user,
    required this.authService,
    required this.profileRepository,
    required this.matchBackend,
  });

  final User user;
  final AuthService authService;
  final ProfileRepository profileRepository;
  final MatchBackend matchBackend;

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
                  _PlayButton(
                    profile: profile,
                    matchBackend: matchBackend,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '3:00 • ${AppConfig.gamesPerMatch} mini-games',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      const Expanded(
                        child: _MenuTile(
                          icon: Icons.leaderboard,
                          label: 'Leaderboard',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _MenuTile(
                          icon: Icons.person,
                          label: 'Profile',
                          onTap: profile == null
                              ? null
                              : () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => ProfileScreen(
                                        profile: profile,
                                        profileRepository: profileRepository,
                                      ),
                                    ),
                                  );
                                },
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
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

class _PlayButton extends StatelessWidget {
  const _PlayButton({
    required this.profile,
    required this.matchBackend,
  });

  final PlayerProfile? profile;
  final MatchBackend matchBackend;

  @override
  Widget build(BuildContext context) {
    final player = profile;
    if (player == null) {
      return const FilledButton(onPressed: null, child: Text('PLAY'));
    }

    return StreamBuilder<MatchTicket?>(
      stream: matchBackend.watchTicket(player.uid),
      builder: (context, snapshot) {
        final ticket = snapshot.data;
        final resumable = ticket?.status == MatchTicketStatus.matched &&
            ticket?.matchId != null;

        return FilledButton(
          onPressed: () {
            if (resumable) {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => MatchRoomScreen(
                    matchId: ticket!.matchId!,
                    uid: player.uid,
                    matchBackend: matchBackend,
                  ),
                ),
              );
              return;
            }

            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => MatchmakingScreen(
                  profile: player,
                  matchBackend: matchBackend,
                ),
              ),
            );
          },
          child: Text(
            resumable ? 'RESUME' : 'PLAY',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
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
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
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
      ),
    );
  }
}
