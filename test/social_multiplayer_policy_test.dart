import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/match/domain/match_progress.dart';
import 'package:game/features/match/domain/multiplayer_match.dart';
import 'package:game/features/match/domain/multiplayer_result.dart';
import 'package:game/features/social/domain/friendship.dart';
import 'package:game/features/social/domain/party.dart';
import 'package:game/features/social/domain/private_room.dart';
import 'package:game/features/social/domain/social_reward_policy.dart';

void main() {
  const empty = MatchProgress(
    completedGames: 0,
    totalScore: 0,
    accuracyTotal: 0,
    mistakes: 0,
    elapsedMs: 0,
  );

  test('only 2 4 and 6 player rooms are supported', () {
    expect(MultiplayerMatchPolicy.supportedPlayerCounts, {2, 4, 6});
  });

  test('ranked launch mode cannot be four player', () {
    final match = MultiplayerMatch(
      id: 'm1',
      mode: MatchMode.ranked,
      hostUid: 'u1',
      maxPlayers: 4,
      seed: 1,
      registryVersion: 3,
      participants: const [
        MatchParticipant(uid: 'u1', displayName: 'A', progress: empty),
      ],
    );
    expect(() => MultiplayerMatchPolicy.validate(match), throwsStateError);
  });

  test('multiplayer result ranks progress before score', () {
    final placements = MultiplayerResultPolicy.rank(const [
      MatchParticipant(
        uid: 'a',
        displayName: 'A',
        progress: MatchProgress(
          completedGames: 8,
          totalScore: 100,
          accuracyTotal: 7,
          mistakes: 2,
          elapsedMs: 60000,
        ),
      ),
      MatchParticipant(
        uid: 'b',
        displayName: 'B',
        progress: MatchProgress(
          completedGames: 7,
          totalScore: 9999,
          accuracyTotal: 7,
          mistakes: 0,
          elapsedMs: 10000,
        ),
      ),
    ]);
    expect(placements.first.uid, 'a');
  });

  test('friend pair id is stable regardless of order', () {
    expect(FriendshipPolicy.pairId('b', 'a'), FriendshipPolicy.pairId('a', 'b'));
  });

  test('party match sizes are 2 4 or 6', () {
    final now = DateTime.utc(2026, 8, 18);
    final party = Party(
      id: 'p1',
      leaderUid: 'u1',
      memberUids: const ['u1', 'u2', 'u3', 'u4'],
      createdAt: now,
      updatedAt: now,
    );
    PartyPolicy.validate(party);
    expect(PartyPolicy.canStartMatch(party), isTrue);
  });

  test('room invite uses canonical join URL', () {
    expect(
      RoomInvitePolicy.buildUri('AB12C').toString(),
      'https://3minutes.game/join/AB12C',
    );
  });

  test('repeated friend matches eventually stop coin farming', () {
    expect(SocialRewardPolicy.applyCoinMultiplier(baseCoins: 100, matchesTogetherToday: 0), 100);
    expect(SocialRewardPolicy.applyCoinMultiplier(baseCoins: 100, matchesTogetherToday: 6), 35);
    expect(SocialRewardPolicy.applyCoinMultiplier(baseCoins: 100, matchesTogetherToday: 10), 0);
    expect(SocialRewardPolicy.awardsRankPointsForFriendLobby(), isFalse);
  });
}
