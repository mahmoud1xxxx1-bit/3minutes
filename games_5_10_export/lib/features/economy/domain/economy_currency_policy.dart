enum EconomyCurrency {
  coins,
  prestigeStars,
  premium;
}

enum EconomyEarningSource {
  match,
  firstWin,
  levelUp,
  dailyMission,
  weeklyMission,
  achievement,
  season,
  seasonPass,
  realMoneyPurchase,
}

class EconomyCurrencyPolicy {
  const EconomyCurrencyPolicy._();

  static bool canEarn(EconomyCurrency currency, EconomyEarningSource source) {
    return switch (currency) {
      EconomyCurrency.coins => source != EconomyEarningSource.season,
      EconomyCurrency.prestigeStars => source == EconomyEarningSource.season,
      EconomyCurrency.premium => source == EconomyEarningSource.realMoneyPurchase,
    };
  }

  static bool canPurchaseWithRealMoney(EconomyCurrency currency) {
    return switch (currency) {
      EconomyCurrency.coins => true,
      EconomyCurrency.prestigeStars => false,
      EconomyCurrency.premium => true,
    };
  }

  static bool canConvert(EconomyCurrency from, EconomyCurrency to) {
    if (from == to) return false;
    if (from == EconomyCurrency.prestigeStars ||
        to == EconomyCurrency.prestigeStars) {
      return false;
    }
    return false;
  }
}

class CoinRewardSchedule {
  const CoinRewardSchedule._();

  static const int matchCompletion = 8;
  static const int winBonus = 12;
  static const int tieBonus = 6;
  static const int firstWinOfDay = 25;

  static int levelUpReward(int level) {
    final safeLevel = level < 1 ? 1 : level;
    final reward = 30 + (safeLevel - 1) * 5;
    if (reward < 30) return 30;
    if (reward > 100) return 100;
    return reward;
  }
}

class ShopPriceBands {
  const ShopPriceBands._();

  static const (int min, int max) commonCoins = (300, 800);
  static const (int min, int max) rareCoins = (1200, 2500);
  static const (int min, int max) epicCoins = (3500, 7000);
  static const (int min, int max) legendaryCoins = (9000, 18000);
  static const (int min, int max) seasonalCoins = (15000, 30000);

  static const List<int> prestigeStarMilestones = <int>[
    10,
    20,
    30,
    45,
    60,
    80,
    120,
    160,
    250,
  ];
}
