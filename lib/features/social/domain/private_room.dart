import '../../match/domain/multiplayer_match.dart';

enum PrivateRoomStatus {
  lobby,
  countdown,
  playing,
  finished,
  cancelled,
}

class PrivateRoom {
  const PrivateRoom({
    required this.id,
    required this.code,
    required this.hostUid,
    required this.maxPlayers,
    required this.participantUids,
    required this.readyUids,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
    this.partyId,
  });

  final String id;
  final String code;
  final String hostUid;
  final int maxPlayers;
  final List<String> participantUids;
  final Set<String> readyUids;
  final PrivateRoomStatus status;
  final DateTime createdAt;
  final DateTime expiresAt;
  final String? partyId;

  bool get isFull => participantUids.length == maxPlayers;
  bool get everyoneReady =>
      participantUids.isNotEmpty && participantUids.every(readyUids.contains);
  bool get canStart => isFull && everyoneReady && status == PrivateRoomStatus.lobby;

  bool isReady(String uid) => readyUids.contains(uid);
}

class PrivateRoomPolicy {
  const PrivateRoomPolicy._();

  static final RegExp _roomCode = RegExp(r'^[A-Z0-9]{5}$');

  static bool validCode(String value) =>
      _roomCode.hasMatch(value.trim().toUpperCase());

  static void validate(PrivateRoom room) {
    if (!MultiplayerMatchPolicy.supportedPlayerCounts.contains(room.maxPlayers)) {
      throw ArgumentError('Private rooms support 2, 4, or 6 players only.');
    }
    if (!validCode(room.code)) {
      throw ArgumentError('Private room code must be five alphanumeric characters.');
    }
    if (room.participantUids.isEmpty ||
        room.participantUids.length > room.maxPlayers) {
      throw StateError('Invalid room participant count.');
    }
    if (room.participantUids.toSet().length != room.participantUids.length) {
      throw StateError('Duplicate room participants are not allowed.');
    }
    if (!room.participantUids.contains(room.hostUid)) {
      throw StateError('Room host must be a participant.');
    }
    if (!room.readyUids.every(room.participantUids.contains)) {
      throw StateError('Only current participants can be ready.');
    }
    if (!room.expiresAt.isAfter(room.createdAt)) {
      throw StateError('Room expiry must be after creation.');
    }
  }
}

class RoomInviteLink {
  const RoomInviteLink({
    required this.roomCode,
    required this.uri,
  });

  final String roomCode;
  final Uri uri;
}

class RoomInvitePolicy {
  const RoomInvitePolicy._();

  static Uri buildUri(String roomCode) {
    final normalized = roomCode.trim().toUpperCase();
    if (!PrivateRoomPolicy.validCode(normalized)) {
      throw ArgumentError('Invalid room code.');
    }
    return Uri(
      scheme: 'https',
      host: '3minutes.game',
      pathSegments: ['join', normalized],
    );
  }
}
