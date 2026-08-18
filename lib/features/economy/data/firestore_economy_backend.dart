import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/cosmetic_item.dart';
import 'cosmetic_catalog.dart';
import 'economy_backend.dart';

class FirestoreEconomyBackend implements EconomyBackend {
  FirestoreEconomyBackend({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Stream<PlayerInventory?> watchInventory(String uid) {
    return _firestore.collection('inventories').doc(uid).snapshots().map((snapshot) {
      final data = snapshot.data();
      if (!snapshot.exists || data == null) return null;

      final owned = data['ownedCosmeticIds'];
      final ownedIds = owned is List
          ? owned.whereType<String>().toSet()
          : <String>{};

      return PlayerInventory(
        coins: (data['coins'] as num?)?.toInt() ?? 0,
        ownedCosmeticIds: Set.unmodifiable(ownedIds),
        equippedAvatarFrameId: data['equippedAvatarFrameId'] as String?,
        equippedBadgeId: data['equippedBadgeId'] as String?,
        equippedProfileBackgroundId:
            data['equippedProfileBackgroundId'] as String?,
        equippedNameStyleId: data['equippedNameStyleId'] as String?,
      );
    });
  }

  @override
  Future<List<CosmeticItem>> loadCatalog() async =>
      List<CosmeticItem>.unmodifiable(CosmeticCatalog.items);

  @override
  Future<void> purchaseCosmetic({
    required String uid,
    required String cosmeticId,
  }) {
    throw UnsupportedError(
      'Cosmetic purchases require the server-authoritative Blaze backend.',
    );
  }

  @override
  Future<void> equipCosmetic({
    required String uid,
    required String cosmeticId,
  }) {
    throw UnsupportedError(
      'Cosmetic equipment writes require the server-authoritative Blaze backend.',
    );
  }
}
