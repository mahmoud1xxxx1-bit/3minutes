import '../domain/cosmetic_item.dart';
import '../domain/purchase_receipt.dart';

abstract class EconomyBackend {
  Stream<PlayerInventory?> watchInventory(String uid);

  Future<List<CosmeticItem>> loadCatalog();

  Future<PurchaseReceipt> purchaseCosmetic({
    required String uid,
    required String cosmeticId,
  });

  Future<void> unlockPrestigeCosmetic({
    required String uid,
    required String cosmeticId,
  });

  Future<PlayerInventory> equipCosmetic({
    required String uid,
    required String cosmeticId,
  });
}
