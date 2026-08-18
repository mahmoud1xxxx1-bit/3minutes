import 'cosmetic_item.dart';

class EquipmentPolicy {
  const EquipmentPolicy._();

  static bool canEquip({
    required PlayerInventory inventory,
    required CosmeticItem item,
  }) {
    return inventory.ownedCosmeticIds.contains(item.id);
  }

  static PlayerInventory previewEquip({
    required PlayerInventory inventory,
    required CosmeticItem item,
  }) {
    if (!canEquip(inventory: inventory, item: item)) {
      throw StateError('Cannot equip a cosmetic the player does not own.');
    }

    return PlayerInventory(
      coins: inventory.coins,
      ownedCosmeticIds: inventory.ownedCosmeticIds,
      equippedAvatarFrameId: item.slot == CosmeticSlot.avatarFrame
          ? item.id
          : inventory.equippedAvatarFrameId,
      equippedBadgeId:
          item.slot == CosmeticSlot.badge ? item.id : inventory.equippedBadgeId,
      equippedProfileBackgroundId: item.slot == CosmeticSlot.profileBackground
          ? item.id
          : inventory.equippedProfileBackgroundId,
      equippedNameStyleId: item.slot == CosmeticSlot.nameStyle
          ? item.id
          : inventory.equippedNameStyleId,
    );
  }
}
