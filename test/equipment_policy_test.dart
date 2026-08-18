import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/economy/domain/cosmetic_item.dart';
import 'package:game/features/economy/domain/equipment_policy.dart';

void main() {
  const frame = CosmeticItem(
    id: 'frame_test',
    name: 'Test Frame',
    slot: CosmeticSlot.avatarFrame,
    coinPrice: 100,
  );

  test('owned cosmetic can be equipped into its slot', () {
    const inventory = PlayerInventory(
      coins: 500,
      ownedCosmeticIds: {'frame_test'},
    );

    final next = EquipmentPolicy.previewEquip(
      inventory: inventory,
      item: frame,
    );

    expect(next.coins, 500);
    expect(next.equippedAvatarFrameId, 'frame_test');
  });

  test('unowned cosmetic cannot be equipped', () {
    const inventory = PlayerInventory(
      coins: 500,
      ownedCosmeticIds: {},
    );

    expect(
      () => EquipmentPolicy.previewEquip(inventory: inventory, item: frame),
      throwsStateError,
    );
  });
}
