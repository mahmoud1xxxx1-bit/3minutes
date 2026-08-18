import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/design_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../competition/data/competition_backend.dart';
import '../../economy/data/economy_backend.dart';
import '../../home/presentation/home_screen.dart';
import '../../match/data/match_backend.dart';
import '../../match/data/social_match_backend.dart';
import '../../profile/data/profile_repository.dart';
import '../../profile/domain/player_profile.dart';
import '../../profile/presentation/profile_setup_screen.dart';
import '../../social/data/room_backend.dart';
import '../../social/data/social_backend.dart';
import '../data/auth_service.dart';
import 'sign_in_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({
    super.key,
    required this.authService,
    required this.profileRepository,
    required this.matchBackend,
    required this.socialMatchBackend,
    required this.competitionBackend,
    required this.economyBackend,
    required this.socialBackend,
    required this.roomBackend,
  });

  final AuthService authService;
  final ProfileRepository profileRepository;
  final MatchBackend matchBackend;
  final SocialMatchBackend socialMatchBackend;
  final CompetitionBackend competitionBackend;
  final EconomyBackend economyBackend;
  final SocialBackend socialBackend;
  final RoomBackend roomBackend;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  int _profileRetry = 0;

  void _retryProfile() {
    setState(() => _profileRetry++);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return StreamBuilder<User?>(
      stream: widget.authService.authStateChanges(),
      initialData: widget.authService.currentUser,
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return _LoadingScreen(message: l10n.signingYouIn);
        }

        final user = authSnapshot.data;
        if (user == null) {
          return SignInScreen(authService: widget.authService);
        }

        return StreamBuilder<PlayerProfile?>(
          key: ValueKey(_profileRetry),
          stream: widget.profileRepository.watchProfile(user.uid),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.hasError) {
              return _ProfileErrorScreen(
                onRetry: _retryProfile,
                onSignOut: widget.authService.signOut,
              );
            }

            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return _LoadingScreen(message: l10n.loadingProfile);
            }

            final profile = profileSnapshot.data;
            if (profile == null) {
              return ProfileSetupScreen(
                uid: user.uid,
                profileRepository: widget.profileRepository,
              );
            }

            return HomeScreen(
              user: user,
              authService: widget.authService,
              profileRepository: widget.profileRepository,
              matchBackend: widget.matchBackend,
              socialMatchBackend: widget.socialMatchBackend,
              competitionBackend: widget.competitionBackend,
              economyBackend: widget.economyBackend,
              socialBackend: widget.socialBackend,
              roomBackend: widget.roomBackend,
            );
          },
        );
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(GameSpacing.lg),
            padding: const EdgeInsets.all(GameSpacing.lg),
            decoration: BoxDecoration(
              color: GameColors.surface,
              borderRadius: BorderRadius.circular(GameRadii.panel),
              border: Border.all(color: GameColors.surfaceStrong),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: GameSpacing.md),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileErrorScreen extends StatelessWidget {
  const _ProfileErrorScreen({
    required this.onRetry,
    required this.onSignOut,
  });

  final VoidCallback onRetry;
  final Future<void> Function() onSignOut;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(GameSpacing.lg),
            child: Container(
              padding: const EdgeInsets.all(GameSpacing.lg),
              decoration: BoxDecoration(
                color: GameColors.surface,
                borderRadius: BorderRadius.circular(GameRadii.panel),
                border: Border.all(color: GameColors.surfaceStrong),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.cloud_off_rounded,
                    size: 50,
                    color: GameColors.warning,
                  ),
                  const SizedBox(height: GameSpacing.md),
                  Text(
                    l10n.profileLoadFailed,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: GameSpacing.xs),
                  Text(
                    l10n.checkConnection,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: GameColors.muted),
                  ),
                  const SizedBox(height: GameSpacing.lg),
                  FilledButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(l10n.tryAgain),
                  ),
                  const SizedBox(height: GameSpacing.sm),
                  TextButton(
                    onPressed: onSignOut,
                    child: Text(l10n.signOut),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
