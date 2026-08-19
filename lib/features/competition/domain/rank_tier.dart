enum RankTier {
  bronze,
  silver,
  gold,
  platinum,
  diamond,
  master,
  grandmaster,
  legend;

  String get label => switch (this) {
        RankTier.bronze => 'Bronze',
        RankTier.silver => 'Silver',
        RankTier.gold => 'Gold',
        RankTier.platinum => 'Platinum',
        RankTier.diamond => 'Diamond',
        RankTier.master => 'Master',
        RankTier.grandmaster => 'Grandmaster',
        RankTier.legend => 'Legendary',
      };
}

class RankBand {
  const RankBand({
    required this.tier,
    required this.minimumRp,
  });

  final RankTier tier;
  final int minimumRp;
}

class RankPolicy {
  const RankPolicy._();

  // Final launch ladder. These thresholds are shared by presentation,
  // settlement, leaderboard, season rewards and server authority.
  static const bands = <RankBand>[
    RankBand(tier: RankTier.bronze, minimumRp: 0),
    RankBand(tier: RankTier.silver, minimumRp: 500),
    RankBand(tier: RankTier.gold, minimumRp: 1200),
    RankBand(tier: RankTier.platinum, minimumRp: 2200),
    RankBand(tier: RankTier.diamond, minimumRp: 3500),
    RankBand(tier: RankTier.master, minimumRp: 5000),
    RankBand(tier: RankTier.grandmaster, minimumRp: 7000),
    RankBand(tier: RankTier.legend, minimumRp: 10000),
  ];

  static RankTier tierFor(int rankPoints) {
    final safeRp = rankPoints < 0 ? 0 : rankPoints;
    var result = bands.first.tier;
    for (final band in bands) {
      if (safeRp >= band.minimumRp) {
        result = band.tier;
      } else {
        break;
      }
    }
    return result;
  }
}
