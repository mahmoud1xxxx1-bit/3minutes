import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../../core/firebase/server_collections.dart';
import '../domain/cosmetic_item.dart';
import '../domain/purchase_receipt.dart';
import 'cosmetic_catalog.dart';
import 'economy_backend.dart';

class CloudFunctionsEconomyBackend implements EconomyBackend {
  CloudFunctionsEconomyBackend({
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _functions = functions ?? FirebaseFunctions.instanceFor(region: 'me-central2');

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  PlayerInventory _inventoryFromData(Map<String, dynamic> data) {
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
  }

  @override
  Stream<PlayerInventory?> watchInventory(String uid) {
    return _firestore
        .collection(ServerCollections.inventories)
        .doc(uid)
        .snapshots()
        .map((snapshot) {
      final data = snapshot.data();
      if (!snapshot.exists || data == null) return null;
      return _inventoryFromData(data);
    });
  }

  @override
  Future<List<CosmeticItem>> loadCatalog() async =>
      List<CosmeticItem>.unmodifiable(CosmeticCatalog.items);

  @override
  Future<PurchaseReceipt> purchaseCosmetic({
    required String uid,
    required String cosmeticId,
  }) async {
    final response = await _functions
        .httpsCallable('purchaseCosmetic')
        .call<Map<Object?, Object?>>({'cosmeticId': cosmeticId});
    final data = Map<String, dynamic>.from(response.data);
    return PurchaseReceipt(
      transactionId: data['transactionId'] as String,
      uid: data['uid'] as String? ?? uid,
      cosmeticId: data['cosmeticId'] as String? ?? cosmeticId,
      coinPrice: (data['coinPrice'] as num?)?.toInt() ?? 0,
      remainingCoins: (data['remainingCoins'] as num?)?.toInt() ?? 0,
      purchasedAt: DateTime.tryParse(data['purchasedAt'] as String? ?? '') ??
          DateTime.now().toUtc(),
    );
  }

  @override
  Future<void> unlockPrestigeCosmetic({
    required String uid,
    required String cosmeticId,
  }) async {
    await _functions.httpsCallable('unlockPrestigeCosmetic').call<void>({
      'cosmeticId': cosmeticId,
    });
  }

  @override
  Future<void> claimEarnedCosmetic({
    required String uid,
    required String cosmeticId,
  }) async {
    await _functions.httpsCallable('claimEarnedCosmetic').call<void>({
      'cosmeticId': cosmeticId,
    });
  }

  @override
  Future<PlayerInventory> equipCosmetic({
    required String uid,
    required String cosmeticId,
  }) async {
    await _functions.httpsCallable('equipCosmetic').call<void>({
      'cosmeticId': cosmeticId,
    });
    final snapshot = await _firestore
        .collection(ServerCollections.inventories)
        .doc(uid)
        .get();
    return _inventoryFromData(snapshot.data() ?? const <String, dynamic>{});
  }
}