import '../domain/cosmetic_item.dart';

class CosmeticCatalog {
  const CosmeticCatalog._();

  static const int version = 1;

  static const items = <CosmeticItem>[
    CosmeticItem(
      id: 'frame_classic',
      name: 'Classic Frame',
      slot: CosmeticSlot.avatarFrame,
      coinPrice: 250,
      rarity: CosmeticRarity.common,
    ),
    CosmeticItem(
      id: 'frame_neon',
      name: 'Neon Frame',
      slot: CosmeticSlot.avatarFrame,
      coinPrice: 600,
      rarity: CosmeticRarity.rare,
    ),
    CosmeticItem(
      id: 'badge_timer',
      name: 'Three Minute Badge',
      slot: CosmeticSlot.badge,
      coinPrice: 400,
      rarity: CosmeticRarity.rare,
    ),
    CosmeticItem(
      id: 'badge_crown',
      name: 'Crown Badge',
      slot: CosmeticSlot.badge,
      coinPrice: 900,
      rarity: CosmeticRarity.legendary,
    ),
    CosmeticItem(
      id: 'background_grid',
      name: 'Grid Profile',
      slot: CosmeticSlot.profileBackground,
      coinPrice: 500,
      rarity: CosmeticRarity.common,
    ),
    CosmeticItem(
      id: 'background_arena',
      name: 'Arena Profile',
      slot: CosmeticSlot.profileBackground,
      coinPrice: 800,
      rarity: CosmeticRarity.epic,
    ),
    CosmeticItem(
      id: 'name_bold',
      name: 'Bold Name',
      slot: CosmeticSlot.nameStyle,
      coinPrice: 300,
      rarity: CosmeticRarity.common,
    ),
    CosmeticItem(
      id: 'name_champion',
      name: 'Champion Name',
      slot: CosmeticSlot.nameStyle,
      coinPrice: 750,
      rarity: CosmeticRarity.epic,
    ),
  ];

  static CosmeticItem? byId(String id) {
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }

  static void validate() {
    final ids = <String>{};
    for (final item in items) {
      if (item.id.trim().isEmpty || !ids.add(item.id)) {
        throw StateError('Cosmetic catalog contains an invalid or duplicate id.');
      }
      if (item.name.trim().isEmpty) {
        throw StateError('Cosmetic catalog contains an empty name.');
      }
      if (item.coinPrice < 0) {
        throw StateError('Cosmetic catalog contains a negative price.');
      }
    }
  }
}
