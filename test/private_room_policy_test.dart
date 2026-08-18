import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/social/domain/private_room.dart';

void main() {
  PrivateRoom room({
    int maxPlayers = 4,
    List<String> participants = const ['host'],
    Set<String> ready = const <String>{},
  }) {
    return PrivateRoom(
      id: 'room-1',
      code: 'A2B3C',
      hostUid: 'host',
      maxPlayers: maxPlayers,
      participantUids: participants,
      readyUids: ready,
      status: PrivateRoomStatus.lobby,
      createdAt: DateTime.utc(2026, 8, 18),
      expiresAt: DateTime.utc(2026, 8, 18, 6),
    );
  }

  test('private room supports only 2, 4, or 6 players', () {
    for (final count in const [2, 4, 6]) {
      expect(
        () => PrivateRoomPolicy.validate(
          room(maxPlayers: count),
        ),
        returnsNormally,
      );
    }

    expect(
      () => PrivateRoomPolicy.validate(room(maxPlayers: 3)),
      throwsArgumentError,
    );
  });

  test('room cannot start until full and everyone is ready', () {
    final waiting = room(
      maxPlayers: 4,
      participants: const ['host', 'p2', 'p3'],
      ready: const {'host', 'p2', 'p3'},
    );
    expect(waiting.canStart, isFalse);

    final notReady = room(
      maxPlayers: 4,
      participants: const ['host', 'p2', 'p3', 'p4'],
      ready: const {'host', 'p2', 'p3'},
    );
    expect(notReady.canStart, isFalse);

    final ready = room(
      maxPlayers: 4,
      participants: const ['host', 'p2', 'p3', 'p4'],
      ready: const {'host', 'p2', 'p3', 'p4'},
    );
    expect(ready.canStart, isTrue);
  });

  test('ready set may contain only room participants', () {
    expect(
      () => PrivateRoomPolicy.validate(
        room(ready: const {'outsider'}),
      ),
      throwsStateError,
    );
  });
}
