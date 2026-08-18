import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/design_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/auth_service.dart';
import '../../competition/data/competition_backend.dart';
import '../../competition/presentation/season_hub_screen.dart';
import '../../economy/data/economy_backend.dart';
import '../../economy/presentation/shop_screen.dart';
import '../../match/data/match_backend.dart';
import '../../match/data/social_match_backend.dart';
import '../../profile/data/profile_repository.dart';
import '../../profile/domain/player_profile.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../progression/data/progression_backend.dart';
import '../../social/data/room_backend.dart';
import '../../social/data/social_backend.dart';
import '../../social/presentation/friends_screen.dart';
import '../../social/presentation/social_copy.dart';
import 'home_screen.dart';

class GameShellScreen extends StatefulWidget {
  const GameShellScreen({
    super.key,
    required this.user,
    required this.authService,
    required this.profileRepository,
    required this.matchBackend,
    required this.socialMatchBackend,
    required this.competitionBackend,
    required this.economyBackend,
    required this.progressionBackend,
    required this.socialBackend,
    required this.roomBackend,
  });

  final User user;
  final AuthService authService;
  final ProfileRepository profileRepository;
  final MatchBackend matchBackend;
  final SocialMatchBackend socialMatchBackend;
  final CompetitionBackend competitionBackend;
  final EconomyBackend economyBackend;
  final ProgressionBackend progressionBackend;
  final SocialBackend socialBackend;
  final RoomBackend roomBackend;

  @override
  State<GameShellScreen> createState() => _GameShellScreenState();
}

class _GameShellScreenState extends State<GameShellScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final social = SocialCopy.of(context);

    return StreamBuilder<PlayerProfile?>(
      stream: widget.profileRepository.watchProfile(widget.user.uid),
      builder: (context, snapshot) {
        final profile = snapshot.data;
        if (profile == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final pages = <Widget>[
          HomeScreen(
            user: widget.user,
            authService: widget.authService,
            profileRepository: widget.profileRepository,
            matchBackend: widget.matchBackend,
            socialMatchBackend: widget.socialMatchBackend,
            competitionBackend: widget.competitionBackend,
            economyBackend: widget.economyBackend,
            socialBackend: widget.socialBackend,
            roomBackend: widget.roomBackend,
          ),
          SeasonHubScreen(
            uid: profile.uid,
            competitionBackend: widget.competitionBackend,
            progressionBackend: widget.progressionBackend,
          ),
          FriendsScreen(profile: profile, socialBackend: widget.socialBackend),
          ShopScreen(uid: profile.uid, economyBackend: widget.economyBackend),
          ProfileScreen(profile: profile, profileRepository: widget.profileRepository),
        ];

        return Scaffold(
          body: IndexedStack(index: _index, children: pages),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (value) => setState(() => _index = value),
            backgroundColor: GameColors.surface,
            indicatorColor: GameColors.accentSoft,
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.home_rounded),
                selectedIcon: const Icon(Icons.home_rounded, color: GameColors.accent),
                label: l10n.home,
              ),
              NavigationDestination(
                icon: const Icon(Icons.auto_awesome_rounded),
                selectedIcon: const Icon(Icons.auto_awesome_rounded, color: GameColors.accent),
                label: l10n.season,
              ),
              NavigationDestination(
                icon: const Icon(Icons.group_rounded),
                selectedIcon: const Icon(Icons.group_rounded, color: GameColors.accent),
                label: social.friends,
              ),
              NavigationDestination(
                icon: const Icon(Icons.storefront_rounded),
                selectedIcon: const Icon(Icons.storefront_rounded, color: GameColors.accent),
                label: l10n.shop,
              ),
              NavigationDestination(
                icon: const Icon(Icons.person_rounded),
                selectedIcon: const Icon(Icons.person_rounded, color: GameColors.accent),
                label: l10n.profile,
              ),
            ],
          ),
        );
      },
    );
  }
}
