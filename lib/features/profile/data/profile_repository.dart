import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/player_profile.dart';

class ProfileRepository {
  ProfileRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Future<void> ensureProfile(User user) async {
    final ref = _users.doc(user.uid);
    final snapshot = await ref.get();

    if (snapshot.exists) return;

    await ref.set({
      'gameName': _safeGameName(user.displayName),
      'avatarId': 'default_01',
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

  Stream<PlayerProfile?> watchProfile(String uid) {
    return _users.doc(uid).snapshots().map((snapshot) {
      final data = snapshot.data();
      if (!snapshot.exists || data == null) return null;
      return PlayerProfile.fromMap(snapshot.id, data);
    });
  }

  String _safeGameName(String? displayName) {
    final cleaned = (displayName ?? '').trim();
    if (cleaned.isEmpty) return 'Player';
    return cleaned.length <= 20 ? cleaned : cleaned.substring(0, 20);
  }
}
