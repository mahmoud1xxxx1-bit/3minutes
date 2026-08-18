import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firebase/server_collections.dart';
import '../domain/party.dart';
import 'party_backend.dart';

class FirestorePartyBackend implements PartyBackend {
  FirestorePartyBackend({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _parties =>
      _firestore.collection(ServerCollections.parties);

  @override
  Stream<Party?> watchParty(String partyId) {
    return _parties.doc(partyId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return _fromDoc(doc);
    });
  }

  @override
  Stream<Party?> watchMembership(String uid) {
    return _parties
        .where('memberUids', arrayContains: uid)
        .limit(1)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.isEmpty ? null : _fromDoc(snapshot.docs.first));
  }

  @override
  Stream<List<Party>> watchInvitations(String uid) {
    return _parties
        .where('pendingInviteUids', arrayContains: uid)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map(_fromDoc)
            .toList(growable: false));
  }

  @override
  Future<Party> createParty({required String leaderUid}) async {
    final existing = await _parties
        .where('memberUids', arrayContains: leaderUid)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) return _fromDoc(existing.docs.first);

    final ref = _parties.doc();
    final now = DateTime.now().toUtc();
    await ref.set({
      'leaderUid': leaderUid,
      'memberUids': [leaderUid],
      'pendingInviteUids': <String>[],
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return Party(
      id: ref.id,
      leaderUid: leaderUid,
      memberUids: [leaderUid],
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<void> inviteMember({
    required String partyId,
    required String leaderUid,
    required String invitedUid,
  }) async {
    final ref = _parties.doc(partyId);
    await _firestore.runTransaction((tx) async {
      final doc = await tx.get(ref);
      if (!doc.exists) throw StateError('Party not found.');
      final party = _fromDoc(doc);
      if (party.leaderUid != leaderUid) {
        throw StateError('Only the party leader can invite players.');
      }
      if (party.memberUids.contains(invitedUid) ||
          party.pendingInviteUids.contains(invitedUid)) {
        return;
      }
      if (party.memberUids.length >= PartyPolicy.maxMembers) {
        throw StateError('Party is full.');
      }
      tx.update(ref, {
        'pendingInviteUids': [...party.pendingInviteUids, invitedUid],
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Future<void> acceptInvite({
    required String partyId,
    required String uid,
  }) async {
    final ref = _parties.doc(partyId);
    await _firestore.runTransaction((tx) async {
      final doc = await tx.get(ref);
      if (!doc.exists) throw StateError('Party not found.');
      final party = _fromDoc(doc);
      if (!party.pendingInviteUids.contains(uid)) {
        throw StateError('Party invite not found.');
      }
      if (party.memberUids.length >= PartyPolicy.maxMembers) {
        throw StateError('Party is full.');
      }
      final pending = party.pendingInviteUids.where((id) => id != uid).toList();
      tx.update(ref, {
        'memberUids': [...party.memberUids, uid],
        'pendingInviteUids': pending,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Future<void> declineInvite({
    required String partyId,
    required String uid,
  }) async {
    final ref = _parties.doc(partyId);
    await _firestore.runTransaction((tx) async {
      final doc = await tx.get(ref);
      if (!doc.exists) return;
      final party = _fromDoc(doc);
      if (!party.pendingInviteUids.contains(uid)) return;
      tx.update(ref, {
        'pendingInviteUids':
            party.pendingInviteUids.where((id) => id != uid).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Future<void> leaveParty({required String partyId, required String uid}) async {
    final ref = _parties.doc(partyId);
    await _firestore.runTransaction((tx) async {
      final doc = await tx.get(ref);
      if (!doc.exists) return;
      final party = _fromDoc(doc);
      if (!party.memberUids.contains(uid)) return;
      final remaining = party.memberUids.where((id) => id != uid).toList();
      if (remaining.isEmpty) {
        tx.delete(ref);
        return;
      }
      final nextLeader = party.leaderUid == uid ? remaining.first : party.leaderUid;
      tx.update(ref, {
        'leaderUid': nextLeader,
        'memberUids': remaining,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Future<void> removeMember({
    required String partyId,
    required String leaderUid,
    required String memberUid,
  }) async {
    final ref = _parties.doc(partyId);
    await _firestore.runTransaction((tx) async {
      final doc = await tx.get(ref);
      if (!doc.exists) throw StateError('Party not found.');
      final party = _fromDoc(doc);
      if (party.leaderUid != leaderUid) {
        throw StateError('Only the party leader can remove members.');
      }
      if (memberUid == leaderUid) {
        throw StateError('Leader must leave the party instead.');
      }
      tx.update(ref, {
        'memberUids': party.memberUids.where((id) => id != memberUid).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Party _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return Party(
      id: doc.id,
      leaderUid: (data['leaderUid'] as String?) ?? '',
      memberUids: (data['memberUids'] as List<dynamic>?)
              ?.whereType<String>()
              .toList(growable: false) ??
          const <String>[],
      pendingInviteUids: (data['pendingInviteUids'] as List<dynamic>?)
              ?.whereType<String>()
              .toList(growable: false) ??
          const <String>[],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
