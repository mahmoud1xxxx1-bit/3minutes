import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/player_name_rules.dart';
import '../domain/player_profile.dart';

class ProfileRepository {
  ProfileRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Stream<PlayerProfile?> watchProfile(String uid) {
    return _users.doc(uid).snapshots().map((snapshot) {
      final data = snapshot.data();
      if (!snapshot.exists || data == null) return null;
      return PlayerProfile.fromMap(snapshot.id, data);
    });
  }

  Future<void> createProfile({
    required String uid,
    required String gameName,
    required String avatarId,
  }) async {
    final cleanedName = PlayerNameRules.validate(gameName);

    await _users.doc(uid).set({
      'gameName': cleanedName,
      'avatarId': avatarId,
      'level': 1,
      'xp': 0,
      'rankPoints': 0,
      'stars': 0,
      'wins': 0,
      'losses': 0,
      'gamesPlayed': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updatePublicProfile({
    required String uid,
    required String gameName,
    required String avatarId,
  }) async {
    final cleanedName = PlayerNameRules.validate(gameName);

    await _users.doc(uid).update({
      'gameName': cleanedName,
      'avatarId': avatarId,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
