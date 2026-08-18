class AppConfig {
  const AppConfig._();

  static const String appName = '3 Minutes';
  static const Duration matchDuration = Duration(minutes: 3);
  static const int gamesPerMatch = 8;

  // These remain disabled on Spark. Enable only after the corresponding
  // server-authoritative Blaze implementation and security review are live.
  static const bool rankedAuthorityEnabled = false;
  static const bool economyPurchasesEnabled = false;
  static const bool liveLeaderboardEnabled = false;
}
