enum RankTier {
  bronze,
  silver,
  gold,
  platinum,
  diamond,
  master;

  String get label => switch (this) {
        RankTier.bronze => 'Bronze',
        RankTier.silver => 'Silver',
        RankTier.gold => 'Gold',
        RankTier.platinum => 'Platinum',
        RankTier.diamond => 'Diamond',
        RankTier.master => 'Master',
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

  // Initial bands are centralized and intentionally easy to tune before launch.
  static const bands = <RankBand>[
    RankBand(tier: RankTier.bronze, minimumRp: 0),
    RankBand(tier: RankTier.silver, minimumRp: 500),
    RankBand(tier: RankTier.gold, minimumRp: 1000),
    RankBand(tier: RankTier.platinum, minimumRp: 1600),
    RankBand(tier: RankTier.diamond, minimumRp: 2300),
    RankBand(tier: RankTier.master, minimumRp: 3200),
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
