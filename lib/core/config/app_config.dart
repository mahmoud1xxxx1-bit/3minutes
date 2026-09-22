enum BackendPhase {
  spark,
  blaze,
}

class AppConfig {
  const AppConfig._();

  static const String appName = 'LVL LOOL';
  static const Duration matchDuration = Duration(minutes: 3);
  static const int gamesPerMatch = 8;

  // Single source of truth for trusted server features.
  // Keep Spark fallback until the new Firebase Functions are deployed and verified.
  static const BackendPhase backendPhase = BackendPhase.spark;

  static const bool rankedAuthorityEnabled =
      backendPhase == BackendPhase.blaze;
  static const bool economyPurchasesEnabled =
      backendPhase == BackendPhase.blaze;
  static const bool liveLeaderboardEnabled =
      backendPhase == BackendPhase.blaze;
}
