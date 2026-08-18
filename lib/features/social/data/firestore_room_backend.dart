import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firebase/server_collections.dart';
import '../domain/private_room.dart';
import 'room_backend.dart';

class FirestoreRoomBackend implements RoomBackend {
  FirestoreRoomBackend({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _rooms =>
      _firestore.collection(ServerCollections.privateRooms);

  @override
  Stream<PrivateRoom?> watchRoom(String roomId) {
    return _rooms.doc(roomId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return _fromDoc(doc);
    });
  }

  @override
  Future<PrivateRoom> createRoom({
    required String hostUid,
    required int maxPlayers,
    required String roomCode,
  }) async {
    final code = roomCode.trim().toUpperCase();
    if (!PrivateRoomPolicy.validCode(code)) {
      throw ArgumentError('Invalid room code.');
    }
    if (!const <int>{2, 4, 6}.contains(maxPlayers)) {
      throw ArgumentError('Room size must be 2, 4, or 6.');
    }

    final roomRef = _rooms.doc();
    final codeRef = _firestore.collection('roomCodes').doc(code);
    final now = DateTime.now().toUtc();
    final expiresAt = now.add(const Duration(hours: 6));

    await _firestore.runTransaction((transaction) async {
      final codeDoc = await transaction.get(codeRef);
      if (codeDoc.exists) throw StateError('Room code already exists.');
      transaction.set(roomRef, {
        'code': code,
        'hostUid': hostUid,
        'maxPlayers': maxPlayers,
        'participantUids': [hostUid],
        'status': PrivateRoomStatus.lobby.name,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(expiresAt),
      });
      transaction.set(codeRef, {
        'roomId': roomRef.id,
        'expiresAt': Timestamp.fromDate(expiresAt),
      });
    });

    return PrivateRoom(
      id: roomRef.id,
      code: code,
      hostUid: hostUid,
      maxPlayers: maxPlayers,
      participantUids: [hostUid],
      status: PrivateRoomStatus.lobby,
      createdAt: now,
      expiresAt: expiresAt,
    );
  }

  @override
  Future<PrivateRoom?> findRoomByCode(String roomCode) async {
    final code = roomCode.trim().toUpperCase();
    if (!PrivateRoomPolicy.validCode(code)) return null;
    final codeDoc = await _firestore.collection('roomCodes').doc(code).get();
    final roomId = codeDoc.data()?['roomId'] as String?;
    if (roomId == null) return null;
    final roomDoc = await _rooms.doc(roomId).get();
    if (!roomDoc.exists) return null;
    final room = _fromDoc(roomDoc);
    if (DateTime.now().toUtc().isAfter(room.expiresAt)) return null;
    return room;
  }

  @override
  Future<void> joinRoom({
    required String roomId,
    required String uid,
  }) async {
    final ref = _rooms.doc(roomId);
    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(ref);
      if (!doc.exists) throw StateError('Room not found.');
      final room = _fromDoc(doc);
      if (room.status != PrivateRoomStatus.lobby) {
        throw StateError('Room is no longer accepting players.');
      }
      if (room.participantUids.contains(uid)) return;
      if (room.isFull) throw StateError('Room is full.');
      transaction.update(ref, {
        'participantUids': [...room.participantUids, uid],
      });
    });
  }

  @override
  Future<void> leaveRoom({
    required String roomId,
    required String uid,
  }) async {
    final ref = _rooms.doc(roomId);
    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(ref);
      if (!doc.exists) return;
      final room = _fromDoc(doc);
      if (!room.participantUids.contains(uid)) return;
      if (room.hostUid == uid) {
        transaction.update(ref, {'status': PrivateRoomStatus.cancelled.name});
        return;
      }
      transaction.update(ref, {
        'participantUids': room.participantUids.where((id) => id != uid).toList(),
      });
    });
  }

  @override
  Future<void> cancelRoom({
    required String roomId,
    required String hostUid,
  }) async {
    final ref = _rooms.doc(roomId);
    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(ref);
      if (!doc.exists) return;
      final room = _fromDoc(doc);
      if (room.hostUid != hostUid) {
        throw StateError('Only the host can cancel the room.');
      }
      transaction.update(ref, {'status': PrivateRoomStatus.cancelled.name});
    });
  }

  PrivateRoom _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    final statusName = data['status'] as String?;
    return PrivateRoom(
      id: doc.id,
      code: (data['code'] as String?) ?? '',
      hostUid: (data['hostUid'] as String?) ?? '',
      maxPlayers: (data['maxPlayers'] as num?)?.toInt() ?? 2,
      participantUids: (data['participantUids'] as List<dynamic>?)
              ?.whereType<String>()
              .toList(growable: false) ??
          const <String>[],
      status: PrivateRoomStatus.values.firstWhere(
        (value) => value.name == statusName,
        orElse: () => PrivateRoomStatus.cancelled,
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ??
          DateTime.fromMillisecondsSinceEpoch(0),
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate() ??
          DateTime.fromMillisecondsSinceEpoch(0),
      partyId: data['partyId'] as String?,
    );
  }
}
