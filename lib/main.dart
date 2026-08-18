import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/data/auth_service.dart';
import 'features/auth/presentation/auth_gate.dart';
import 'features/competition/data/competition_backend.dart';
import 'features/competition/data/firestore_competition_backend.dart';
import 'features/economy/data/economy_backend.dart';
import 'features/economy/data/firestore_economy_backend.dart';
import 'features/match/data/firestore_match_backend.dart';
import 'features/match/data/firestore_social_match_backend.dart';
import 'features/match/data/match_backend.dart';
import 'features/match/data/social_match_backend.dart';
import 'features/profile/data/profile_repository.dart';
import 'features/social/data/firestore_room_backend.dart';
import 'features/social/data/firestore_social_backend.dart';
import 'features/social/data/room_backend.dart';
import 'features/social/data/social_backend.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final authService = AuthService();
  await authService.initialize();

  runApp(
    ThreeMinutesApp(
      authService: authService,
      profileRepository: ProfileRepository(),
      matchBackend: FirestoreMatchBackend(),
      socialMatchBackend: FirestoreSocialMatchBackend(),
      competitionBackend: FirestoreCompetitionBackend(),
      economyBackend: FirestoreEconomyBackend(),
      socialBackend: FirestoreSocialBackend(),
      roomBackend: FirestoreRoomBackend(),
    ),
  );
}

class ThreeMinutesApp extends StatelessWidget {
  const ThreeMinutesApp({
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
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: AuthGate(
        authService: authService,
        profileRepository: profileRepository,
        matchBackend: matchBackend,
        socialMatchBackend: socialMatchBackend,
        competitionBackend: competitionBackend,
        economyBackend: economyBackend,
        socialBackend: socialBackend,
        roomBackend: roomBackend,
      ),
    );
  }
}
