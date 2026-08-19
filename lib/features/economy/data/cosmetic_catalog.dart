import '../domain/cosmetic_item.dart';

CosmeticItem _free(String id, String name, int priority) => CosmeticItem(
  id: id, name: name, slot: CosmeticSlot.avatar, isFree: true,
  rarity: CosmeticRarity.common, collection: 'cosmic_starters',
  sortPriority: priority,
);

CosmeticItem _coin(
  String id, String name, int price, CosmeticRarity rarity, int priority,
) => CosmeticItem(
  id: id, name: name, slot: CosmeticSlot.avatar, coinPrice: price,
  rarity: rarity, collection: 'cosmic_coin', sortPriority: priority,
);

CosmeticItem _premium(
  String id, String name, int cents, CosmeticRarity rarity, int priority,
) => CosmeticItem(
  id: id, name: name, slot: CosmeticSlot.avatar,
  premiumPriceCents: cents, isPremium: true, rarity: rarity,
  collection: 'cosmic_premium', isFeatured: true, sortPriority: priority,
);

CosmeticItem _star(
  String id, String name, int stars, CosmeticRarity rarity, int priority,
) => CosmeticItem(
  id: id, name: name, slot: CosmeticSlot.avatar, starPrice: stars,
  rarity: rarity, collection: 'cosmic_prestige', sortPriority: priority,
);

CosmeticItem _earned(
  String id, String name, String requirement, bool seasonLimited, int priority,
) => CosmeticItem(
  id: id, name: name, slot: CosmeticSlot.avatar,
  requiredAchievementId: requirement, isSeasonLimited: seasonLimited,
  rarity: CosmeticRarity.mythic, collection: 'cosmic_exclusive',
  isFeatured: true, sortPriority: priority,
);

class CosmeticCatalog {
  const CosmeticCatalog._();

  static const int version = 3;

  static final items = <CosmeticItem>[
    // Exactly 45 approved Cosmic Flow avatars.
    _free('avatar_free_vanguard', 'Vanguard Captain', 10),
    _free('avatar_free_arena', 'Arena Ace', 11),
    _free('avatar_free_hacker', 'Neon Hacker', 12),
    _free('avatar_free_phantom', 'Street Phantom', 13),
    _free('avatar_free_warden', 'Star Warden', 14),
    _coin('avatar_coin_01', 'Nebula Scout', 1600, CosmeticRarity.rare, 101),
    _coin('avatar_coin_02', 'Flux Racer', 2000, CosmeticRarity.rare, 102),
    _coin('avatar_coin_03', 'Iron Sentinel', 2400, CosmeticRarity.rare, 103),
    _coin('avatar_coin_04', 'Pulse Duelist', 2800, CosmeticRarity.rare, 104),
    _coin('avatar_coin_05', 'Ember Agent', 3200, CosmeticRarity.rare, 105),
    _coin('avatar_coin_06', 'Orbit Archer', 3600, CosmeticRarity.epic, 106),
    _coin('avatar_coin_07', 'Prism Monk', 4000, CosmeticRarity.epic, 107),
    _coin('avatar_coin_08', 'Quantum Driver', 4400, CosmeticRarity.epic, 108),
    _coin('avatar_coin_09', 'Rift Ranger', 4800, CosmeticRarity.epic, 109),
    _coin('avatar_coin_10', 'Ion Valkyrie', 5200, CosmeticRarity.epic, 110),
    _coin('avatar_coin_11', 'Cipher Fox', 5600, CosmeticRarity.epic, 111),
    _coin('avatar_coin_12', 'Storm Gladiator', 6000, CosmeticRarity.epic, 112),
    _coin('avatar_coin_13', 'Solar Nomad', 6400, CosmeticRarity.legendary, 113),
    _coin('avatar_coin_14', 'Luna Tactician', 6800, CosmeticRarity.legendary, 114),
    _coin('avatar_coin_15', 'Cosmo Ranger', 7200, CosmeticRarity.legendary, 115),
    _coin('avatar_coin_16', 'Voltage Ronin', 7600, CosmeticRarity.legendary, 116),
    _coin('avatar_coin_17', 'Mirror Siren', 8400, CosmeticRarity.legendary, 117),
    _coin('avatar_coin_18', 'Jet Commander', 9200, CosmeticRarity.legendary, 118),
    _coin('avatar_coin_19', 'Astro Rogue', 10000, CosmeticRarity.mythic, 119),
    _coin('avatar_coin_20', 'Halo Engineer', 11000, CosmeticRarity.mythic, 120),
    _premium('avatar_premium_01', 'Nebula Oracle', 998, CosmeticRarity.legendary, 201),
    _premium('avatar_premium_02', 'Crimson Reaper', 998, CosmeticRarity.legendary, 202),
    _premium('avatar_premium_03', 'Eclipse Huntress', 1198, CosmeticRarity.legendary, 203),
    _premium('avatar_premium_04', 'Solar Sovereign', 1198, CosmeticRarity.legendary, 204),
    _premium('avatar_premium_05', 'Infinite Monarch', 1398, CosmeticRarity.legendary, 205),
    _premium('avatar_premium_06', 'Void Queen', 1398, CosmeticRarity.legendary, 206),
    _premium('avatar_premium_07', 'Astral Ronin', 1598, CosmeticRarity.mythic, 207),
    _premium('avatar_premium_08', 'Celestial Emperor', 1598, CosmeticRarity.mythic, 208),
    _premium('avatar_premium_09', 'Chrono Warden', 1998, CosmeticRarity.mythic, 209),
    _premium('avatar_premium_10', 'Nova Duchess', 1998, CosmeticRarity.mythic, 210),
    _star('avatar_star_01', 'Stellar Veteran', 3, CosmeticRarity.epic, 301),
    _star('avatar_star_02', 'Celestial Judge', 5, CosmeticRarity.epic, 302),
    _star('avatar_star_03', 'Rift Archon', 10, CosmeticRarity.legendary, 303),
    _star('avatar_star_04', 'Eternal Paladin', 20, CosmeticRarity.legendary, 304),
    _star('avatar_star_05', 'Infinite Sage', 35, CosmeticRarity.mythic, 305),
    _earned('avatar_exclusive_01', 'Zenith Paragon', 'legendary_once', false, 401),
    _earned('avatar_exclusive_02', 'Crowned Legend', 'legendary_x3', false, 402),
    _earned('avatar_exclusive_03', 'Legacy Warden', 'legendary_x5', false, 403),
    _earned('avatar_exclusive_04', 'Ranked Conqueror', 'wins_100', false, 404),
    _earned('avatar_exclusive_05', 'Season Champion', 'season_champion', true, 405),

    // Existing non-avatar coin cosmetics.
    const CosmeticItem(id: 'name_bold', name: 'Bold Name', slot: CosmeticSlot.nameStyle, coinPrice: 500, collection: 'starter', sortPriority: 510),
    const CosmeticItem(id: 'frame_classic', name: 'Classic Frame', slot: CosmeticSlot.avatarFrame, coinPrice: 750, collection: 'starter', sortPriority: 520),
    const CosmeticItem(id: 'badge_timer', name: 'Three Minute Badge', slot: CosmeticSlot.badge, coinPrice: 1200, rarity: CosmeticRarity.rare, collection: 'three_minutes', sortPriority: 530),
    const CosmeticItem(id: 'background_grid', name: 'Grid Profile', slot: CosmeticSlot.profileBackground, coinPrice: 1600, rarity: CosmeticRarity.rare, collection: 'digital', sortPriority: 540),
    const CosmeticItem(id: 'emote_gg', name: 'GG Emote', slot: CosmeticSlot.emote, coinPrice: 2200, rarity: CosmeticRarity.rare, collection: 'arena', sortPriority: 550),
    const CosmeticItem(id: 'frame_neon', name: 'Neon Frame', slot: CosmeticSlot.avatarFrame, coinPrice: 4200, rarity: CosmeticRarity.epic, collection: 'digital', isAnimated: true, sortPriority: 560),
    const CosmeticItem(id: 'name_champion', name: 'Champion Name', slot: CosmeticSlot.nameStyle, coinPrice: 5500, rarity: CosmeticRarity.epic, collection: 'arena', sortPriority: 570),
    const CosmeticItem(id: 'frame_voltage', name: 'Voltage Frame', slot: CosmeticSlot.avatarFrame, coinPrice: 7000, rarity: CosmeticRarity.epic, collection: 'voltage', isAnimated: true, isFeatured: true, sortPriority: 580),
    const CosmeticItem(id: 'background_arena', name: 'Arena Profile', slot: CosmeticSlot.profileBackground, coinPrice: 8500, rarity: CosmeticRarity.epic, collection: 'arena', sortPriority: 590),
    const CosmeticItem(id: 'victory_confetti', name: 'Victory Confetti', slot: CosmeticSlot.victoryEffect, coinPrice: 10000, rarity: CosmeticRarity.legendary, collection: 'champion', isAnimated: true, sortPriority: 600),
    const CosmeticItem(id: 'name_electric', name: 'Electric Name', slot: CosmeticSlot.nameStyle, coinPrice: 12500, rarity: CosmeticRarity.legendary, collection: 'voltage', isAnimated: true, sortPriority: 610),
    const CosmeticItem(id: 'room_arcade', name: 'Arcade Room', slot: CosmeticSlot.roomTheme, coinPrice: 16000, rarity: CosmeticRarity.legendary, collection: 'arcade', isFeatured: true, sortPriority: 620),
    const CosmeticItem(id: 'intro_redline', name: 'Redline Entrance', slot: CosmeticSlot.matchIntro, coinPrice: 22000, rarity: CosmeticRarity.legendary, collection: 'redline', isAnimated: true, sortPriority: 630),
    const CosmeticItem(id: 'aura_storm', name: 'Storm Aura', slot: CosmeticSlot.rankAura, coinPrice: 30000, rarity: CosmeticRarity.mythic, collection: 'voltage', isAnimated: true, isFeatured: true, sortPriority: 640),

    // Existing prestige cosmetics. Stars are thresholds and are never spent.
    const CosmeticItem(id: 'badge_crown', name: 'Prestige Crown', slot: CosmeticSlot.badge, starPrice: 10, rarity: CosmeticRarity.epic, collection: 'prestige', sortPriority: 700),
    const CosmeticItem(id: 'frame_prestige', name: 'Prestige Frame I', slot: CosmeticSlot.avatarFrame, starPrice: 20, rarity: CosmeticRarity.epic, collection: 'prestige', sortPriority: 710),
    const CosmeticItem(id: 'aura_rank_flare', name: 'Rank Flare Aura', slot: CosmeticSlot.rankAura, starPrice: 30, rarity: CosmeticRarity.legendary, collection: 'prestige', isAnimated: true, sortPriority: 720),
    const CosmeticItem(id: 'intro_champion', name: 'Champion Entrance', slot: CosmeticSlot.matchIntro, starPrice: 45, rarity: CosmeticRarity.legendary, collection: 'prestige', isAnimated: true, isFeatured: true, sortPriority: 730),
    const CosmeticItem(id: 'background_constellation', name: 'Constellation Profile', slot: CosmeticSlot.profileBackground, starPrice: 60, rarity: CosmeticRarity.legendary, collection: 'prestige', isAnimated: true, sortPriority: 740),
    const CosmeticItem(id: 'name_royal', name: 'Royal Name', slot: CosmeticSlot.nameStyle, starPrice: 80, rarity: CosmeticRarity.legendary, collection: 'prestige', isAnimated: true, sortPriority: 750),
    const CosmeticItem(id: 'victory_crown_burst', name: 'Crown Burst Victory', slot: CosmeticSlot.victoryEffect, starPrice: 120, rarity: CosmeticRarity.mythic, collection: 'prestige', isAnimated: true, isFeatured: true, sortPriority: 760),
    const CosmeticItem(id: 'frame_elite', name: 'Elite Prestige Frame', slot: CosmeticSlot.avatarFrame, starPrice: 160, rarity: CosmeticRarity.mythic, collection: 'prestige', isAnimated: true, sortPriority: 770),
    const CosmeticItem(id: 'aura_mythic_legacy', name: 'Mythic Legacy Aura', slot: CosmeticSlot.rankAura, starPrice: 250, rarity: CosmeticRarity.mythic, collection: 'prestige', isAnimated: true, isFeatured: true, sortPriority: 780),

    // Existing non-avatar premium cosmetics.
    const CosmeticItem(id: 'frame_obsidian', name: 'Obsidian Frame', slot: CosmeticSlot.avatarFrame, premiumPriceCents: 199, rarity: CosmeticRarity.epic, isPremium: true, collection: 'obsidian', sortPriority: 800),
    const CosmeticItem(id: 'background_void', name: 'Living Void Profile', slot: CosmeticSlot.profileBackground, premiumPriceCents: 299, rarity: CosmeticRarity.legendary, isPremium: true, collection: 'void', isAnimated: true, sortPriority: 810),
    const CosmeticItem(id: 'intro_portal', name: 'Portal Entrance', slot: CosmeticSlot.matchIntro, premiumPriceCents: 399, rarity: CosmeticRarity.legendary, isPremium: true, collection: 'void', isAnimated: true, isFeatured: true, sortPriority: 820),
    const CosmeticItem(id: 'victory_lightning', name: 'Lightning Victory', slot: CosmeticSlot.victoryEffect, premiumPriceCents: 399, rarity: CosmeticRarity.legendary, isPremium: true, collection: 'voltage', isAnimated: true, sortPriority: 830),
    const CosmeticItem(id: 'room_cyber_royal', name: 'Cyber Royal Room', slot: CosmeticSlot.roomTheme, premiumPriceCents: 499, rarity: CosmeticRarity.mythic, isPremium: true, collection: 'cyber_royal', isAnimated: true, isFeatured: true, sortPriority: 840),
  ];

  static List<CosmeticItem> get avatars =>
      items.where((item) => item.slot == CosmeticSlot.avatar).toList(growable: false);

  static CosmeticItem? byId(String id) {
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }

  static List<CosmeticItem> get featured => items
      .where((item) => item.isFeatured)
      .toList(growable: false)
    ..sort((a, b) => b.sortPriority.compareTo(a.sortPriority));

  static List<CosmeticItem> forPriceType(CosmeticPriceType type) => items
      .where((item) => item.priceType == type)
      .toList(growable: false)
    ..sort((a, b) => a.sortPriority.compareTo(b.sortPriority));

  static void validate() {
    final ids = <String>{};
    var avatarCount = 0;
    for (final item in items) {
      if (item.id.trim().isEmpty || !ids.add(item.id)) {
        throw StateError('Cosmetic catalog contains an invalid or duplicate id.');
      }
      if (item.name.trim().isEmpty || item.collection.trim().isEmpty) {
        throw StateError('Cosmetic catalog contains incomplete metadata.');
      }
      if (item.coinPrice < 0 || item.starPrice < 0 || item.premiumPriceCents < 0) {
        throw StateError('Cosmetic catalog contains a negative price.');
      }
      final unlockWays = <bool>[
        item.isFree,
        item.coinPrice > 0,
        item.starPrice > 0,
        item.premiumPriceCents > 0 || item.isPremium,
        item.requiredAchievementId != null,
      ].where((value) => value).length;
      if (unlockWays != 1) {
        throw StateError('Cosmetic ${item.id} must have exactly one unlock path.');
      }
      if (item.starPrice > 0 && item.isPremium) {
        throw StateError('Prestige Stars must never be sold as premium cosmetics.');
      }
      if (item.slot == CosmeticSlot.avatar) avatarCount++;
    }
    if (avatarCount != 45) {
      throw StateError('Avatar catalog must contain exactly 45 avatars.');
    }
  }
}