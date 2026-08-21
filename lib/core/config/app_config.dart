enum BackendPhase {
  spark,
  blaze,
}

class AppConfig {
  const AppConfig._();

  static const String appName = '3 Minutes';
  static const Duration matchDuration = Duration(minutes: 3);
  static const int gamesPerMatch = 4;

  // Single source of truth for trusted server features.
  // Change to Blaze only after Cloud Functions and security review are live.
  static const BackendPhase backendPhase = BackendPhase.spark;

  static const bool rankedAuthorityEnabled =
      backendPhase == BackendPhase.blaze;
  static const bool economyPurchasesEnabled =
      backendPhase == BackendPhase.blaze;
  static const bool liveLeaderboardEnabled =
      backendPhase == BackendPhase.blaze;
}
