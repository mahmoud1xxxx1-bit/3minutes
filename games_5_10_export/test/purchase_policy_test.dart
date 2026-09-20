import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/economy/domain/cosmetic_item.dart';
import 'package:game/features/economy/domain/purchase_policy.dart';

void main() {
  const item = CosmeticItem(
    id: 'badge_test',
    name: 'Test Badge',
    slot: CosmeticSlot.badge,
    coinPrice: 120,
  );

  test('purchase preview calculates remaining balance', () {
    const inventory = PlayerInventory(
      coins: 200,
      ownedCosmeticIds: {},
    );

    final preview = PurchasePolicy.preview(inventory: inventory, item: item);
    expect(preview.remainingCoins, 80);
    expect(preview.cosmeticId, item.id);
  });

  test('duplicate ownership blocks purchase', () {
    const inventory = PlayerInventory(
      coins: 200,
      ownedCosmeticIds: {'badge_test'},
    );

    expect(
      () => PurchasePolicy.preview(inventory: inventory, item: item),
      throwsStateError,
    );
  });

  test('insufficient coins blocks purchase', () {
    const inventory = PlayerInventory(
      coins: 50,
      ownedCosmeticIds: {},
    );

    expect(
      () => PurchasePolicy.preview(inventory: inventory, item: item),
      throwsStateError,
    );
  });
}
