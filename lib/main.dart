import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/auth_service.dart';
import 'features/auth/presentation/auth_gate.dart';
import 'features/competition/data/competition_backend.dart';
import 'features/competition/data/firestore_competition_backend.dart';
import 'features/match/data/firestore_match_backend.dart';
import 'features/match/data/match_backend.dart';
import 'features/profile/data/profile_repository.dart';

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
      competitionBackend: FirestoreCompetitionBackend(),
    ),
  );
}

class ThreeMinutesApp extends StatelessWidget {
  const ThreeMinutesApp({
    super.key,
    required this.authService,
    required this.profileRepository,
    required this.matchBackend,
    required this.competitionBackend,
  });

  final AuthService authService;
  final ProfileRepository profileRepository;
  final MatchBackend matchBackend;
  final CompetitionBackend competitionBackend;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: AuthGate(
        authService: authService,
        profileRepository: profileRepository,
        matchBackend: matchBackend,
        competitionBackend: competitionBackend,
      ),
    );
  }
}
