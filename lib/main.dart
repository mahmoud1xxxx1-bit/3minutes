import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/auth_service.dart';
import 'features/auth/presentation/auth_gate.dart';
import 'features/competition/data/competition_backend.dart';
import 'features/competition/data/firestore_competition_backend.dart';
import 'features/competition/presentation/rank_promotion_events.dart';
import 'features/competition/presentation/rank_promotion_overlay_host.dart';
import 'features/economy/data/cloud_functions_economy_backend.dart';
import 'features/economy/data/economy_backend.dart';
import 'features/economy/data/firestore_economy_backend.dart';
import 'features/match/data/cloud_functions_match_backend.dart';
import 'features/match/data/cloud_functions_quick_match_backend.dart';
import 'features/match/data/firestore_match_backend.dart';
import 'features/match/data/firestore_social_match_backend.dart';
import 'features/match/data/match_backend.dart';
import 'features/match/data/social_match_backend.dart';
import 'features/profile/data/profile_repository.dart';
import 'features/progression/data/firestore_progression_backend.dart';
import 'features/progression/data/progression_backend.dart';
import 'features/social/data/firestore_room_backend.dart';
import 'features/social/data/firestore_social_backend.dart';
import 'features/social/data/room_backend.dart';
import 'features/social/data/social_backend.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate(
    providerAndroid: kReleaseMode
        ? const AndroidPlayIntegrityProvider()
        : const AndroidDebugProvider(),
  );

  final authService = AuthService();
  await authService.initialize();
  final blaze = AppConfig.backendPhase == BackendPhase.blaze;
  final EconomyBackend economyBackend =
      blaze ? CloudFunctionsEconomyBackend() : FirestoreEconomyBackend();
  final MatchBackend matchBackend = blaze
      ? CloudFunctionsMatchBackend(onSettlement: RankPromotionEvents.publish)
      : FirestoreMatchBackend();
  final MatchBackend quickMatchBackend = CloudFunctionsQuickMatchBackend();

  runApp(
    ThreeMinutesApp(
      authService: authService,
      profileRepository: ProfileRepository(),
      matchBackend: matchBackend,
      quickMatchBackend: quickMatchBackend,
      socialMatchBackend: FirestoreSocialMatchBackend(),
      competitionBackend: FirestoreCompetitionBackend(),
      economyBackend: economyBackend,
      progressionBackend: FirestoreProgressionBackend(),
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
    required this.quickMatchBackend,
    required this.socialMatchBackend,
    required this.competitionBackend,
    required this.economyBackend,
    required this.progressionBackend,
    required this.socialBackend,
    required this.roomBackend,
  });

  final AuthService authService;
  final ProfileRepository profileRepository;
  final MatchBackend matchBackend;
  final MatchBackend quickMatchBackend;
  final SocialMatchBackend socialMatchBackend;
  final CompetitionBackend competitionBackend;
  final EconomyBackend economyBackend;
  final ProgressionBackend progressionBackend;
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
      builder: (context, child) => RankPromotionOverlayHost(
        child: child ?? const SizedBox.shrink(),
      ),
      home: AuthGate(
        authService: authService,
        profileRepository: profileRepository,
        matchBackend: matchBackend,
        quickMatchBackend: quickMatchBackend,
        socialMatchBackend: socialMatchBackend,
        competitionBackend: competitionBackend,
        economyBackend: economyBackend,
        progressionBackend: progressionBackend,
        socialBackend: socialBackend,
        roomBackend: roomBackend,
      ),
    );
  }
}
