import '../domain/cosmetic_item.dart';

class CosmeticCatalog {
  const CosmeticCatalog._();

  static const int version = 2;

  static const items = <CosmeticItem>[
    // Coins: daily-to-long-term progression.
    CosmeticItem(
      id: 'name_bold',
      name: 'Bold Name',
      slot: CosmeticSlot.nameStyle,
      coinPrice: 500,
      rarity: CosmeticRarity.common,
      collection: 'starter',
      sortPriority: 10,
    ),
    CosmeticItem(
      id: 'frame_classic',
      name: 'Classic Frame',
      slot: CosmeticSlot.avatarFrame,
      coinPrice: 750,
      rarity: CosmeticRarity.common,
      collection: 'starter',
      sortPriority: 20,
    ),
    CosmeticItem(
      id: 'badge_timer',
      name: 'Three Minute Badge',
      slot: CosmeticSlot.badge,
      coinPrice: 1200,
      rarity: CosmeticRarity.rare,
      collection: 'three_minutes',
      sortPriority: 30,
    ),
    CosmeticItem(
      id: 'background_grid',
      name: 'Grid Profile',
      slot: CosmeticSlot.profileBackground,
      coinPrice: 1600,
      rarity: CosmeticRarity.rare,
      collection: 'digital',
      sortPriority: 40,
    ),
    CosmeticItem(
      id: 'emote_gg',
      name: 'GG Emote',
      slot: CosmeticSlot.emote,
      coinPrice: 2200,
      rarity: CosmeticRarity.rare,
      collection: 'arena',
      sortPriority: 50,
    ),
    CosmeticItem(
      id: 'avatar_comet',
      name: 'Comet Avatar',
      slot: CosmeticSlot.avatar,
      coinPrice: 3000,
      rarity: CosmeticRarity.rare,
      collection: 'cosmic',
      sortPriority: 60,
    ),
    CosmeticItem(
      id: 'frame_neon',
      name: 'Neon Frame',
      slot: CosmeticSlot.avatarFrame,
      coinPrice: 4200,
      rarity: CosmeticRarity.epic,
      collection: 'digital',
      isAnimated: true,
      sortPriority: 70,
    ),
    CosmeticItem(
      id: 'name_champion',
      name: 'Champion Name',
      slot: CosmeticSlot.nameStyle,
      coinPrice: 5500,
      rarity: CosmeticRarity.epic,
      collection: 'arena',
      sortPriority: 80,
    ),
    CosmeticItem(
      id: 'frame_voltage',
      name: 'Voltage Frame',
      slot: CosmeticSlot.avatarFrame,
      coinPrice: 7000,
      rarity: CosmeticRarity.epic,
      collection: 'voltage',
      isAnimated: true,
      isFeatured: true,
      sortPriority: 90,
    ),
    CosmeticItem(
      id: 'background_arena',
      name: 'Arena Profile',
      slot: CosmeticSlot.profileBackground,
      coinPrice: 8500,
      rarity: CosmeticRarity.epic,
      collection: 'arena',
      sortPriority: 100,
    ),
    CosmeticItem(
      id: 'victory_confetti',
      name: 'Victory Confetti',
      slot: CosmeticSlot.victoryEffect,
      coinPrice: 10000,
      rarity: CosmeticRarity.legendary,
      collection: 'champion',
      isAnimated: true,
      sortPriority: 110,
    ),
    CosmeticItem(
      id: 'name_electric',
      name: 'Electric Name',
      slot: CosmeticSlot.nameStyle,
      coinPrice: 12500,
      rarity: CosmeticRarity.legendary,
      collection: 'voltage',
      isAnimated: true,
      sortPriority: 120,
    ),
    CosmeticItem(
      id: 'room_arcade',
      name: 'Arcade Room',
      slot: CosmeticSlot.roomTheme,
      coinPrice: 16000,
      rarity: CosmeticRarity.legendary,
      collection: 'arcade',
      isFeatured: true,
      sortPriority: 130,
    ),
    CosmeticItem(
      id: 'intro_redline',
      name: 'Redline Entrance',
      slot: CosmeticSlot.matchIntro,
      coinPrice: 22000,
      rarity: CosmeticRarity.legendary,
      collection: 'redline',
      isAnimated: true,
      sortPriority: 140,
    ),
    CosmeticItem(
      id: 'aura_storm',
      name: 'Storm Aura',
      slot: CosmeticSlot.rankAura,
      coinPrice: 30000,
      rarity: CosmeticRarity.mythic,
      collection: 'voltage',
      isAnimated: true,
      isFeatured: true,
      sortPriority: 150,
    ),

    // Prestige Stars: cannot be bought. These prove long-term achievement.
    CosmeticItem(
      id: 'badge_crown',
      name: 'Prestige Crown',
      slot: CosmeticSlot.badge,
      starPrice: 10,
      rarity: CosmeticRarity.epic,
      collection: 'prestige',
      sortPriority: 200,
    ),
    CosmeticItem(
      id: 'frame_prestige',
      name: 'Prestige Frame I',
      slot: CosmeticSlot.avatarFrame,
      starPrice: 20,
      rarity: CosmeticRarity.epic,
      collection: 'prestige',
      sortPriority: 210,
    ),
    CosmeticItem(
      id: 'aura_rank_flare',
      name: 'Rank Flare Aura',
      slot: CosmeticSlot.rankAura,
      starPrice: 30,
      rarity: CosmeticRarity.legendary,
      collection: 'prestige',
      isAnimated: true,
      sortPriority: 220,
    ),
    CosmeticItem(
      id: 'intro_champion',
      name: 'Champion Entrance',
      slot: CosmeticSlot.matchIntro,
      starPrice: 45,
      rarity: CosmeticRarity.legendary,
      collection: 'prestige',
      isAnimated: true,
      isFeatured: true,
      sortPriority: 230,
    ),
    CosmeticItem(
      id: 'background_constellation',
      name: 'Constellation Profile',
      slot: CosmeticSlot.profileBackground,
      starPrice: 60,
      rarity: CosmeticRarity.legendary,
      collection: 'prestige',
      isAnimated: true,
      sortPriority: 240,
    ),
    CosmeticItem(
      id: 'name_royal',
      name: 'Royal Name',
      slot: CosmeticSlot.nameStyle,
      starPrice: 80,
      rarity: CosmeticRarity.legendary,
      collection: 'prestige',
      isAnimated: true,
      sortPriority: 250,
    ),
    CosmeticItem(
      id: 'victory_crown_burst',
      name: 'Crown Burst Victory',
      slot: CosmeticSlot.victoryEffect,
      starPrice: 120,
      rarity: CosmeticRarity.mythic,
      collection: 'prestige',
      isAnimated: true,
      isFeatured: true,
      sortPriority: 260,
    ),
    CosmeticItem(
      id: 'frame_elite',
      name: 'Elite Prestige Frame',
      slot: CosmeticSlot.avatarFrame,
      starPrice: 160,
      rarity: CosmeticRarity.mythic,
      collection: 'prestige',
      isAnimated: true,
      sortPriority: 270,
    ),
    CosmeticItem(
      id: 'aura_mythic_legacy',
      name: 'Mythic Legacy Aura',
      slot: CosmeticSlot.rankAura,
      starPrice: 250,
      rarity: CosmeticRarity.mythic,
      collection: 'prestige',
      isAnimated: true,
      isFeatured: true,
      sortPriority: 280,
    ),

    // Premium: visual expression only; never competitive power.
    CosmeticItem(
      id: 'frame_obsidian',
      name: 'Obsidian Frame',
      slot: CosmeticSlot.avatarFrame,
      premiumPriceCents: 199,
      rarity: CosmeticRarity.epic,
      isPremium: true,
      collection: 'obsidian',
      sortPriority: 300,
    ),
    CosmeticItem(
      id: 'background_void',
      name: 'Living Void Profile',
      slot: CosmeticSlot.profileBackground,
      premiumPriceCents: 299,
      rarity: CosmeticRarity.legendary,
      isPremium: true,
      collection: 'void',
      isAnimated: true,
      sortPriority: 310,
    ),
    CosmeticItem(
      id: 'intro_portal',
      name: 'Portal Entrance',
      slot: CosmeticSlot.matchIntro,
      premiumPriceCents: 399,
      rarity: CosmeticRarity.legendary,
      isPremium: true,
      collection: 'void',
      isAnimated: true,
      isFeatured: true,
      sortPriority: 320,
    ),
    CosmeticItem(
      id: 'victory_lightning',
      name: 'Lightning Victory',
      slot: CosmeticSlot.victoryEffect,
      premiumPriceCents: 399,
      rarity: CosmeticRarity.legendary,
      isPremium: true,
      collection: 'voltage',
      isAnimated: true,
      sortPriority: 330,
    ),
    CosmeticItem(
      id: 'room_cyber_royal',
      name: 'Cyber Royal Room',
      slot: CosmeticSlot.roomTheme,
      premiumPriceCents: 499,
      rarity: CosmeticRarity.mythic,
      isPremium: true,
      collection: 'cyber_royal',
      isAnimated: true,
      isFeatured: true,
      sortPriority: 340,
    ),
  ];

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
      final pricedWays = <bool>[
        item.coinPrice > 0,
        item.starPrice > 0,
        item.premiumPriceCents > 0 || item.isPremium,
        item.requiredAchievementId != null,
      ].where((value) => value).length;
      if (pricedWays != 1) {
        throw StateError('Cosmetic ${item.id} must have exactly one unlock path.');
      }
      if (item.starPrice > 0 && item.isPremium) {
        throw StateError('Prestige Stars must never be sold as premium cosmetics.');
      }
    }
  }
}
