import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firebase/server_collections.dart';
import '../domain/cosmetic_item.dart';
import '../domain/purchase_receipt.dart';
import 'cosmetic_catalog.dart';
import 'economy_backend.dart';

class FirestoreEconomyBackend implements EconomyBackend {
  FirestoreEconomyBackend({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Stream<PlayerInventory?> watchInventory(String uid) {
    return _firestore
        .collection(ServerCollections.inventories)
        .doc(uid)
        .snapshots()
        .map((snapshot) {
      final data = snapshot.data();
      if (!snapshot.exists || data == null) return null;
      final owned = data['ownedCosmeticIds'];
      return PlayerInventory(
        coins: (data['coins'] as num?)?.toInt() ?? 0,
        prestigeStars: (data['prestigeStars'] as num?)?.toInt() ??
            (data['stars'] as num?)?.toInt() ??
            0,
        ownedCosmeticIds: Set.unmodifiable(
          owned is List ? owned.whereType<String>().toSet() : <String>{},
        ),
        equippedAvatarId: data['equippedAvatarId'] as String?,
        equippedAvatarFrameId: data['equippedAvatarFrameId'] as String?,
        equippedBadgeId: data['equippedBadgeId'] as String?,
        equippedProfileBackgroundId: data['equippedProfileBackgroundId'] as String?,
        equippedNameStyleId: data['equippedNameStyleId'] as String?,
        equippedMatchIntroId: data['equippedMatchIntroId'] as String?,
        equippedVictoryEffectId: data['equippedVictoryEffectId'] as String?,
        equippedRankAuraId: data['equippedRankAuraId'] as String?,
        equippedEmoteId: data['equippedEmoteId'] as String?,
        equippedRoomThemeId: data['equippedRoomThemeId'] as String?,
      );
    });
  }

  @override
  Future<List<CosmeticItem>> loadCatalog() async =>
      List<CosmeticItem>.unmodifiable(CosmeticCatalog.items);

  Never _requiresBlaze() => throw UnsupportedError(
        'This economy write requires the server-authoritative Blaze backend.',
      );

  @override
  Future<PurchaseReceipt> purchaseCosmetic({
    required String uid,
    required String cosmeticId,
  }) async =>
      _requiresBlaze();

  @override
  Future<void> unlockPrestigeCosmetic({
    required String uid,
    required String cosmeticId,
  }) async =>
      _requiresBlaze();

  @override
  Future<PlayerInventory> equipCosmetic({
    required String uid,
    required String cosmeticId,
  }) async =>
      _requiresBlaze();
}
