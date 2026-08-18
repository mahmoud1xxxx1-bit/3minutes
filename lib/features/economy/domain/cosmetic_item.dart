enum CosmeticSlot {
  avatar,
  avatarFrame,
  badge,
  profileBackground,
  nameStyle,
  matchIntro,
  victoryEffect,
  rankAura,
  emote,
  roomTheme,
}

enum CosmeticRarity {
  common,
  rare,
  epic,
  legendary,
  mythic,
}

enum CosmeticPriceType {
  coins,
  prestigeStars,
  premium,
  achievement,
  seasonalPlacement,
}

class CosmeticItem {
  const CosmeticItem({
    required this.id,
    required this.name,
    required this.slot,
    this.coinPrice = 0,
    this.starPrice = 0,
    this.premiumPriceCents = 0,
    this.rarity = CosmeticRarity.common,
    this.isPremium = false,
    this.isSeasonLimited = false,
    this.requiredAchievementId,
    this.collection = 'core',
    this.isFeatured = false,
    this.isAnimated = false,
    this.sortPriority = 0,
  });

  final String id;
  final String name;
  final CosmeticSlot slot;
  final int coinPrice;
  final int starPrice;
  final int premiumPriceCents;
  final CosmeticRarity rarity;
  final bool isPremium;
  final bool isSeasonLimited;
  final String? requiredAchievementId;
  final String collection;
  final bool isFeatured;
  final bool isAnimated;
  final int sortPriority;

  CosmeticPriceType get priceType {
    if (requiredAchievementId != null) return CosmeticPriceType.achievement;
    if (starPrice > 0) return CosmeticPriceType.prestigeStars;
    if (isPremium || premiumPriceCents > 0) return CosmeticPriceType.premium;
    return CosmeticPriceType.coins;
  }
}

class PlayerInventory {
  const PlayerInventory({
    required this.coins,
    required this.ownedCosmeticIds,
    this.prestigeStars = 0,
    this.premiumBalance = 0,
    this.equippedAvatarId,
    this.equippedAvatarFrameId,
    this.equippedBadgeId,
    this.equippedProfileBackgroundId,
    this.equippedNameStyleId,
    this.equippedMatchIntroId,
    this.equippedVictoryEffectId,
    this.equippedRankAuraId,
    this.equippedEmoteId,
    this.equippedRoomThemeId,
  });

  final int coins;
  final int prestigeStars;
  final int premiumBalance;
  final Set<String> ownedCosmeticIds;
  final String? equippedAvatarId;
  final String? equippedAvatarFrameId;
  final String? equippedBadgeId;
  final String? equippedProfileBackgroundId;
  final String? equippedNameStyleId;
  final String? equippedMatchIntroId;
  final String? equippedVictoryEffectId;
  final String? equippedRankAuraId;
  final String? equippedEmoteId;
  final String? equippedRoomThemeId;
}
