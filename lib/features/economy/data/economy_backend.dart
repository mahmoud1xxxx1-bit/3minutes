import '../domain/cosmetic_item.dart';

abstract class EconomyBackend {
  Stream<PlayerInventory?> watchInventory(String uid);

  Future<List<CosmeticItem>> loadCatalog();

  Future<void> purchaseCosmetic({
    required String uid,
    required String cosmeticId,
  });

  Future<void> equipCosmetic({
    required String uid,
    required String cosmeticId,
  });
}
