enum SeasonPassTrack {
  free,
  premium,
}

enum SeasonPassRewardType {
  coins,
  cosmetic,
}

class SeasonPassReward {
  const SeasonPassReward({
    required this.level,
    required this.track,
    required this.type,
    this.coinAmount = 0,
    this.cosmeticId,
  });

  final int level;
  final SeasonPassTrack track;
  final SeasonPassRewardType type;
  final int coinAmount;
  final String? cosmeticId;
}

class SeasonPassPolicy {
  const SeasonPassPolicy._();

  static const int maxLevel = 30;
  static const int xpPerLevel = 500;

  static int levelForXp(int seasonXp) {
    if (seasonXp <= 0) return 1;
    final level = 1 + seasonXp ~/ xpPerLevel;
    return level > maxLevel ? maxLevel : level;
  }

  static int xpIntoLevel(int seasonXp) {
    if (seasonXp <= 0) return 0;
    if (levelForXp(seasonXp) >= maxLevel) return xpPerLevel;
    return seasonXp % xpPerLevel;
  }

  static double progressFraction(int seasonXp) {
    if (levelForXp(seasonXp) >= maxLevel) return 1;
    return xpIntoLevel(seasonXp) / xpPerLevel;
  }

  static int freeCoinRewardForLevel(int level) {
    final safeLevel = level.clamp(1, maxLevel).toInt();
    return 40 + safeLevel * 10;
  }

  static int premiumCoinRewardForLevel(int level) {
    final safeLevel = level.clamp(1, maxLevel).toInt();
    return 100 + safeLevel * 20;
  }
}
