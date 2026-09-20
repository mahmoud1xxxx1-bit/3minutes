class SocialRewardPolicy {
  const SocialRewardPolicy._();

  static const int fullRewardMatchesPerPairPerDay = 5;
  static const int reducedRewardMatchesPerPairPerDay = 10;

  static double coinMultiplierForRepeatedPair(int matchesTogetherToday) {
    if (matchesTogetherToday < 0) return 1;
    if (matchesTogetherToday < fullRewardMatchesPerPairPerDay) return 1;
    if (matchesTogetherToday < reducedRewardMatchesPerPairPerDay) return 0.35;
    return 0;
  }

  static int applyCoinMultiplier({
    required int baseCoins,
    required int matchesTogetherToday,
  }) {
    if (baseCoins <= 0) return 0;
    final multiplier = coinMultiplierForRepeatedPair(matchesTogetherToday);
    return (baseCoins * multiplier).floor();
  }

  static bool awardsRankPointsForFriendLobby() => false;
}
