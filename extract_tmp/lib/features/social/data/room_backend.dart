import '../domain/private_room.dart';

abstract class RoomBackend {
  Stream<PrivateRoom?> watchRoom(String roomId);

  Future<PrivateRoom> createRoom({
    required String hostUid,
    required int maxPlayers,
    required String roomCode,
  });

  Future<PrivateRoom?> findRoomByCode(String roomCode);

  Future<void> joinRoom({
    required String roomId,
    required String uid,
  });

  Future<void> setReady({
    required String roomId,
    required String uid,
    required bool ready,
  });

  Future<void> startRoom({
    required String roomId,
    required String hostUid,
  });

  Future<void> leaveRoom({
    required String roomId,
    required String uid,
  });

  Future<void> cancelRoom({
    required String roomId,
    required String hostUid,
  });
}
