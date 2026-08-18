import 'package:flutter_test/flutter_test.dart';
import 'package:three_minutes/features/match/domain/match_progress.dart';
import 'package:three_minutes/features/match/domain/multiplayer_match.dart';
import 'package:three_minutes/features/match/domain/multiplayer_result.dart';
import 'package:three_minutes/features/social/domain/party.dart';
import 'package:three_minutes/features/social/domain/private_room.dart';

void main() {
  MatchParticipant player(
    String uid, {
    int games = 0,
    int score = 0,
    double accuracy = 0,
    int mistakes = 0,
    int elapsedMs = 0,
  }) {
    return MatchParticipant(
      uid: uid,
      displayName: uid,
      progress: MatchProgress(
        completedGames: games,
        totalScore: score,
        accuracyTotal: accuracy * games,
        mistakes: mistakes,
        elapsedMs: elapsedMs,
      ),
    );
  }

  test('social launch player counts are exactly 2, 4, and 6', () {
    expect(MultiplayerMatchPolicy.supportedPlayerCounts, <int>{2, 4, 6});
  });

  test('ranked remains strictly 1v1', () {
    final two = MultiplayerMatch(
      id: 'ranked-2',
      mode: MatchMode.ranked,
      hostUid: 'a',
      maxPlayers: 2,
      seed: 1,
      registryVersion: 3,
      participants: [player('a'), player('b')],
    );
    expect(() => MultiplayerMatchPolicy.validate(two), returnsNormally);

    final four = MultiplayerMatch(
      id: 'ranked-4',
      mode: MatchMode.ranked,
      hostUid: 'a',
      maxPlayers: 4,
      seed: 1,
      registryVersion: 3,
      participants: [player('a'), player('b'), player('c'), player('d')],
    );
    expect(() => MultiplayerMatchPolicy.validate(four), throwsStateError);
  });

  test('private rooms accept only 2, 4, or 6 maximum players', () {
    for (final count in const [2, 4, 6]) {
      final room = PrivateRoom(
        id: 'room-$count',
        code: 'AB12C',
        hostUid: 'a',
        maxPlayers: count,
        participantUids: const ['a'],
        readyUids: const <String>{},
        status: PrivateRoomStatus.lobby,
        createdAt: DateTime.utc(2026, 1, 1),
        expiresAt: DateTime.utc(2026, 1, 1, 1),
      );
      expect(() => PrivateRoomPolicy.validate(room), returnsNormally);
    }

    final invalid = PrivateRoom(
      id: 'room-3',
      code: 'AB12C',
      hostUid: 'a',
      maxPlayers: 3,
      participantUids: const ['a'],
      readyUids: const <String>{},
      status: PrivateRoomStatus.lobby,
      createdAt: DateTime.utc(2026, 1, 1),
      expiresAt: DateTime.utc(2026, 1, 1, 1),
    );
    expect(() => PrivateRoomPolicy.validate(invalid), throwsArgumentError);
  });

  test('party can start only at 2, 4, or 6 members', () {
    Party party(int size) => Party(
          id: 'p$size',
          leaderUid: 'u0',
          memberUids: List.generate(size, (i) => 'u$i'),
          createdAt: DateTime.utc(2026, 1, 1),
          updatedAt: DateTime.utc(2026, 1, 1),
        );

    expect(PartyPolicy.canStartMatch(party(1)), isFalse);
    expect(PartyPolicy.canStartMatch(party(2)), isTrue);
    expect(PartyPolicy.canStartMatch(party(3)), isFalse);
    expect(PartyPolicy.canStartMatch(party(4)), isTrue);
    expect(PartyPolicy.canStartMatch(party(5)), isFalse);
    expect(PartyPolicy.canStartMatch(party(6)), isTrue);
  });

  test('multi-player placement follows progress score accuracy mistakes time', () {
    final ranked = MultiplayerResultPolicy.rank([
      player(
        'less-progress',
        games: 7,
        score: 9999,
        accuracy: 1,
        elapsedMs: 1,
      ),
      player(
        'score-winner',
        games: 8,
        score: 900,
        accuracy: .7,
        mistakes: 3,
        elapsedMs: 90000,
      ),
      player(
        'accuracy-winner',
        games: 8,
        score: 800,
        accuracy: .95,
        mistakes: 4,
        elapsedMs: 80000,
      ),
      player(
        'mistakes-winner',
        games: 8,
        score: 800,
        accuracy: .90,
        mistakes: 1,
        elapsedMs: 85000,
      ),
      player(
        'time-winner',
        games: 8,
        score: 800,
        accuracy: .90,
        mistakes: 2,
        elapsedMs: 70000,
      ),
      player(
        'time-loser',
        games: 8,
        score: 800,
        accuracy: .90,
        mistakes: 2,
        elapsedMs: 80000,
      ),
    ]);

    expect(
      ranked.map((e) => e.uid).toList(),
      [
        'score-winner',
        'accuracy-winner',
        'mistakes-winner',
        'time-winner',
        'time-loser',
        'less-progress',
      ],
    );
    expect(ranked.map((e) => e.position).toList(), [1, 2, 3, 4, 5, 6]);
  });

  test('private and party modes never award rank points', () {
    expect(
      MultiplayerMatchPolicy.awardsRankPoints(MatchMode.privateRoom),
      isFalse,
    );
    expect(MultiplayerMatchPolicy.awardsRankPoints(MatchMode.party), isFalse);
    expect(MultiplayerMatchPolicy.awardsRankPoints(MatchMode.ranked), isTrue);
    expect(
      MultiplayerMatchPolicy.usesReducedSocialRewards(MatchMode.privateRoom),
      isTrue,
    );
    expect(
      MultiplayerMatchPolicy.usesReducedSocialRewards(MatchMode.party),
      isTrue,
    );
  });

  test('room invite uses the Android app-native deep-link contract', () {
    final uri = RoomInvitePolicy.buildUri('ab12c');
    expect(uri.scheme, 'threeminutes');
    expect(uri.host, 'join');
    expect(uri.pathSegments, ['AB12C']);
    expect(uri.toString(), 'threeminutes://join/AB12C');
  });
}
