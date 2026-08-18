enum CosmeticSlot {
  avatarFrame,
  badge,
  profileBackground,
  nameStyle,
}

enum CosmeticRarity {
  common,
  rare,
  epic,
  legendary,
}

class CosmeticItem {
  const CosmeticItem({
    required this.id,
    required this.name,
    required this.slot,
    required this.coinPrice,
    this.rarity = CosmeticRarity.common,
    this.isPremium = false,
  });

  final String id;
  final String name;
  final CosmeticSlot slot;
  final int coinPrice;
  final CosmeticRarity rarity;
  final bool isPremium;
}

class PlayerInventory {
  const PlayerInventory({
    required this.coins,
    required this.ownedCosmeticIds,
    this.equippedAvatarFrameId,
    this.equippedBadgeId,
    this.equippedProfileBackgroundId,
    this.equippedNameStyleId,
  });

  final int coins;
  final Set<String> ownedCosmeticIds;
  final String? equippedAvatarFrameId;
  final String? equippedBadgeId;
  final String? equippedProfileBackgroundId;
  final String? equippedNameStyleId;
}
