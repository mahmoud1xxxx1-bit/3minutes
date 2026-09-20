import 'coin_transaction.dart';
import 'cosmetic_item.dart';

class PurchasePreview {
  const PurchasePreview({
    required this.remainingCoins,
    required this.cosmeticId,
  });

  final int remainingCoins;
  final String cosmeticId;
}

class PurchasePolicy {
  const PurchasePolicy._();

  static PurchasePreview preview({
    required PlayerInventory inventory,
    required CosmeticItem item,
  }) {
    if (inventory.ownedCosmeticIds.contains(item.id)) {
      throw StateError('Player already owns this cosmetic.');
    }
    if (item.coinPrice < 0) {
      throw StateError('Cosmetic price cannot be negative.');
    }

    final remaining = CoinBalancePolicy.apply(
      balance: inventory.coins,
      delta: -item.coinPrice,
    );

    return PurchasePreview(
      remainingCoins: remaining,
      cosmeticId: item.id,
    );
  }
}
