import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../home/presentation/home_screen.dart';
import '../../profile/data/profile_repository.dart';
import '../../profile/domain/player_profile.dart';
import '../../profile/presentation/profile_setup_screen.dart';
import '../data/auth_service.dart';
import 'sign_in_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({
    super.key,
    required this.authService,
    required this.profileRepository,
  });

  final AuthService authService;
  final ProfileRepository profileRepository;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: authService.authStateChanges(),
      initialData: authService.currentUser,
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScreen();
        }

        final user = authSnapshot.data;
        if (user == null) {
          return SignInScreen(authService: authService);
        }

        return StreamBuilder<PlayerProfile?>(
          stream: profileRepository.watchProfile(user.uid),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.hasError) {
              return _ProfileErrorScreen(onSignOut: authService.signOut);
            }

            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const _LoadingScreen();
            }

            final profile = profileSnapshot.data;
            if (profile == null) {
              return ProfileSetupScreen(
                uid: user.uid,
                profileRepository: profileRepository,
              );
            }

            return HomeScreen(
              user: user,
              authService: authService,
              profileRepository: profileRepository,
            );
          },
        );
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class _ProfileErrorScreen extends StatelessWidget {
  const _ProfileErrorScreen({required this.onSignOut});

  final Future<void> Function() onSignOut;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off, size: 44),
                const SizedBox(height: 12),
                const Text(
                  'We could not load your player profile.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: onSignOut,
                  child: const Text('Sign out'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
