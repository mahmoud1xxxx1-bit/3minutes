import '../../domain/rank_tier.dart';

/// Approved HD rank emblem assets.
///
/// Rank identity and order are locked to the competitive ladder:
/// Bronze, Silver, Gold, Platinum, Diamond, Master, Grand Master, Legendary.
abstract final class RankArtworkPaths {
  static const String bronze = 'assets/ranks_hd/rank_bronze.webp';
  static const String silver = 'assets/ranks_hd/rank_silver.webp';
  static const String gold = 'assets/ranks_hd/rank_gold.webp';
  static const String platinum = 'assets/ranks_hd/rank_platinum.webp';
  static const String diamond = 'assets/ranks_hd/rank_diamond.webp';
  static const String master = 'assets/ranks_hd/rank_master.webp';
  static const String grandmaster = 'assets/ranks_hd/rank_grandmaster.webp';
  static const String legendary = 'assets/ranks_hd/rank_legendary.webp';

  static const List<String> all = <String>[
    bronze,
    silver,
    gold,
    platinum,
    diamond,
    master,
    grandmaster,
    legendary,
  ];

  static String forTier(RankTier tier) => switch (tier) {
        RankTier.bronze => bronze,
        RankTier.silver => silver,
        RankTier.gold => gold,
        RankTier.platinum => platinum,
        RankTier.diamond => diamond,
        RankTier.master => master,
        RankTier.grandmaster => grandmaster,
        RankTier.legend => legendary,
      };
}
