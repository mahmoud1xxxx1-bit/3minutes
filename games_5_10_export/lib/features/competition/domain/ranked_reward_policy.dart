enum RankedResult {
  win,
  loss,
  tie,
}

class RankedReward {
  const RankedReward({
    required this.rpDelta,
    required this.xp,
    required this.coins,
  });

  final int rpDelta;
  final int xp;
  final int coins;
}

class RankedRewardPolicy {
  const RankedRewardPolicy._();

  // Launch-tuning values. These are deterministic policy inputs for the
  // future server-authoritative settlement function, never trusted client writes.
  static const int winRp = 30;
  static const int lossRp = -18;
  static const int tieRp = 8;

  static const int winXp = 120;
  static const int lossXp = 55;
  static const int tieXp = 80;

  static const int winCoins = 30;
  static const int lossCoins = 10;
  static const int tieCoins = 18;

  static RankedReward rewardFor(RankedResult result) {
    return switch (result) {
      RankedResult.win => const RankedReward(
          rpDelta: winRp,
          xp: winXp,
          coins: winCoins,
        ),
      RankedResult.loss => const RankedReward(
          rpDelta: lossRp,
          xp: lossXp,
          coins: lossCoins,
        ),
      RankedResult.tie => const RankedReward(
          rpDelta: tieRp,
          xp: tieXp,
          coins: tieCoins,
        ),
    };
  }

  static int applyRp({required int currentRp, required int delta}) {
    final next = currentRp + delta;
    return next < 0 ? 0 : next;
  }
}
