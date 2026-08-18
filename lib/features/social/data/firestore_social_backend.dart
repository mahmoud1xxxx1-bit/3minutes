import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firebase/server_collections.dart';
import '../domain/friendship.dart';
import '../domain/player_friend_code.dart';
import 'social_backend.dart';

class FirestoreSocialBackend implements SocialBackend {
  FirestoreSocialBackend({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _friendships =>
      _firestore.collection(ServerCollections.friendships);

  @override
  Stream<List<Friendship>> watchFriendships(String uid) {
    return _friendships.where('memberUids', arrayContains: uid).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => _friendshipFromDoc(doc))
              .toList(growable: false),
        );
  }

  @override
  Future<PlayerFriendCode?> findByFriendCode(String code) async {
    final normalized = code.trim().toUpperCase();
    if (!PlayerFriendCodePolicy.isValid(normalized)) return null;
    final doc = await _firestore
        .collection(ServerCollections.friendCodes)
        .doc(normalized)
        .get();
    if (!doc.exists) return null;
    final uid = doc.data()?['uid'] as String?;
    if (uid == null || uid.isEmpty) return null;
    return PlayerFriendCode(uid: uid, code: normalized);
  }

  @override
  Future<void> ensureFriendCode(PlayerFriendCode friendCode) async {
    final normalized = friendCode.code.trim().toUpperCase();
    if (!PlayerFriendCodePolicy.isValid(normalized)) {
      throw ArgumentError('Invalid friend code.');
    }
    await _firestore.runTransaction((transaction) async {
      final ref = _firestore.collection(ServerCollections.friendCodes).doc(normalized);
      final current = await transaction.get(ref);
      if (current.exists && current.data()?['uid'] != friendCode.uid) {
        throw StateError('Friend code is already owned by another player.');
      }
      transaction.set(ref, {
        'uid': friendCode.uid,
        'code': normalized,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  @override
  Future<void> sendFriendRequest({
    required String requesterUid,
    required String recipientUid,
  }) async {
    final id = FriendshipPolicy.pairId(requesterUid, recipientUid);
    final ref = _friendships.doc(id);
    await _firestore.runTransaction((transaction) async {
      final current = await transaction.get(ref);
      if (current.exists) {
        final status = current.data()?['status'] as String?;
        if (status == FriendshipStatus.blocked.name) {
          throw StateError('Friendship is blocked.');
        }
        if (status == FriendshipStatus.accepted.name ||
            status == FriendshipStatus.pending.name) {
          return;
        }
      }
      transaction.set(ref, {
        'requesterUid': requesterUid,
        'recipientUid': recipientUid,
        'memberUids': [requesterUid, recipientUid],
        'status': FriendshipStatus.pending.name,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Future<void> acceptFriendRequest({
    required String friendshipId,
    required String actingUid,
  }) async {
    final ref = _friendships.doc(friendshipId);
    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(ref);
      if (!doc.exists) throw StateError('Friend request does not exist.');
      final friendship = _friendshipFromDoc(doc);
      if (!FriendshipPolicy.canAccept(
        friendship: friendship,
        actingUid: actingUid,
      )) {
        throw StateError('This player cannot accept the request.');
      }
      transaction.update(ref, {
        'status': FriendshipStatus.accepted.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Future<void> removeFriendship({
    required String friendshipId,
    required String actingUid,
  }) async {
    final ref = _friendships.doc(friendshipId);
    final doc = await ref.get();
    if (!doc.exists) return;
    final friendship = _friendshipFromDoc(doc);
    if (!friendship.involves(actingUid)) {
      throw StateError('Only friendship members can remove it.');
    }
    await ref.delete();
  }

  @override
  Future<void> blockPlayer({
    required String actingUid,
    required String blockedUid,
  }) async {
    final id = FriendshipPolicy.pairId(actingUid, blockedUid);
    await _friendships.doc(id).set({
      'requesterUid': actingUid,
      'recipientUid': blockedUid,
      'memberUids': [actingUid, blockedUid],
      'blockedByUid': actingUid,
      'status': FriendshipStatus.blocked.name,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<List<RecentPlayer>> loadRecentPlayers(
    String uid, {
    int limit = 30,
  }) async {
    final snapshot = await _firestore
        .collection(ServerCollections.recentPlayers)
        .doc(uid)
        .collection('players')
        .orderBy('lastPlayedAt', descending: true)
        .limit(limit.clamp(1, 100))
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return RecentPlayer(
        uid: doc.id,
        displayName: (data['displayName'] as String?) ?? 'Player',
        avatarId: data['avatarId'] as String?,
        lastPlayedAt: (data['lastPlayedAt'] as Timestamp?)?.toDate() ??
            DateTime.fromMillisecondsSinceEpoch(0),
        matchId: (data['matchId'] as String?) ?? '',
      );
    }).toList(growable: false);
  }

  Friendship _friendshipFromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    final statusName = data['status'] as String?;
    final status = FriendshipStatus.values.firstWhere(
      (value) => value.name == statusName,
      orElse: () => FriendshipStatus.pending,
    );
    return Friendship(
      id: doc.id,
      requesterUid: (data['requesterUid'] as String?) ?? '',
      recipientUid: (data['recipientUid'] as String?) ?? '',
      status: status,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
