import '../../features/competition/domain/rank_tier.dart';

/// Production contract for owner-approved player identity artwork.
///
/// The paths below are the canonical destinations for the final 1024x1024
/// local WebP masters. They intentionally do not imply that the source bytes
/// are already present in the repository. Runtime must not switch away from
/// its temporary fallback until [productionSourcesAvailable] is true.
class ApprovedIdentityArtManifest {
  const ApprovedIdentityArtManifest._();

  static const bool productionSourcesAvailable = false;

  static const String avatarRoot = 'assets/avatars/approved_1024';
  static const String rankRoot = 'assets/ranks/approved_1024';

  static const List<String> avatarIds = <String>[
    'avatar_free_vanguard',
    'avatar_free_arena',
    'avatar_free_hacker',
    'avatar_free_phantom',
    'avatar_free_warden',
    'avatar_coin_01',
    'avatar_coin_02',
    'avatar_coin_03',
    'avatar_coin_04',
    'avatar_coin_05',
    'avatar_coin_06',
    'avatar_coin_07',
    'avatar_coin_08',
    'avatar_coin_09',
    'avatar_coin_10',
    'avatar_coin_11',
    'avatar_coin_12',
    'avatar_coin_13',
    'avatar_coin_14',
    'avatar_coin_15',
    'avatar_coin_16',
    'avatar_coin_17',
    'avatar_coin_18',
    'avatar_coin_19',
    'avatar_coin_20',
    'avatar_premium_01',
    'avatar_premium_02',
    'avatar_premium_03',
    'avatar_premium_04',
    'avatar_premium_05',
    'avatar_premium_06',
    'avatar_premium_07',
    'avatar_premium_08',
    'avatar_premium_09',
    'avatar_premium_10',
    'avatar_star_01',
    'avatar_star_02',
    'avatar_star_03',
    'avatar_star_04',
    'avatar_star_05',
    'avatar_exclusive_01',
    'avatar_exclusive_02',
    'avatar_exclusive_03',
    'avatar_exclusive_04',
    'avatar_exclusive_05',
  ];

  static final Map<String, String> avatarMasterPaths = <String, String>{
    for (final id in avatarIds) id: '$avatarRoot/$id.webp',
  };

  static const Map<RankTier, String> rankFileNames = <RankTier, String>{
    RankTier.bronze: 'rank_bronze.webp',
    RankTier.silver: 'rank_silver.webp',
    RankTier.gold: 'rank_gold.webp',
    RankTier.platinum: 'rank_platinum.webp',
    RankTier.diamond: 'rank_diamond.webp',
    RankTier.master: 'rank_master.webp',
    RankTier.grandmaster: 'rank_grandmaster.webp',
    RankTier.legend: 'rank_legendary.webp',
  };

  static final Map<RankTier, String> rankMasterPaths = <RankTier, String>{
    for (final entry in rankFileNames.entries)
      entry.key: '$rankRoot/${entry.value}',
  };

  static String? avatarMasterPath(String avatarId) =>
      avatarMasterPaths[avatarId];

  static String rankMasterPath(RankTier tier) => rankMasterPaths[tier]!;

  /// Legacy/intermediate payloads may be preserved for restoration work, but
  /// they are never production identity masters.
  static const Set<String> prohibitedProductionSources = <String>{
    'assets/avatars/approved_hd_00.b64',
    'assets/avatars/free_atlas.webp.b64',
    'assets/avatars/coins_atlas.webp.b64',
    'assets/avatars/premium_atlas.webp.b64',
    'assets/avatars/stars_atlas.webp.b64',
    'assets/avatars/exclusive_atlas.webp.b64',
  };
}
