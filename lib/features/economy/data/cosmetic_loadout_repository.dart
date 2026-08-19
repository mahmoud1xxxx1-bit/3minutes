import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firebase/server_collections.dart';
import '../domain/cosmetic_loadout.dart';

class CosmeticLoadoutRepository {
  CosmeticLoadoutRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<CosmeticLoadout> watch(String uid) {
    return _firestore
        .collection(ServerCollections.users)
        .doc(uid)
        .snapshots()
        .map((snapshot) {
      final data = snapshot.data();
      final raw = data?['cosmeticLoadout'];
      final map = raw is Map
          ? Map<String, dynamic>.from(raw)
          : const <String, dynamic>{};
      return CosmeticLoadout.fromMap(map);
    });
  }

  Future<CosmeticLoadout> load(String uid) async {
    final snapshot = await _firestore
        .collection(ServerCollections.users)
        .doc(uid)
        .get();
    final data = snapshot.data();
    final raw = data?['cosmeticLoadout'];
    final map = raw is Map
        ? Map<String, dynamic>.from(raw)
        : const <String, dynamic>{};
    return CosmeticLoadout.fromMap(map);
  }
}
