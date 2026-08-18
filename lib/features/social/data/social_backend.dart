import '../domain/friendship.dart';
import '../domain/player_friend_code.dart';

abstract class SocialBackend {
  Stream<List<Friendship>> watchFriendships(String uid);

  Future<PlayerFriendCode?> findByFriendCode(String code);

  Future<void> ensureFriendCode(PlayerFriendCode friendCode);

  Future<void> sendFriendRequest({
    required String requesterUid,
    required String recipientUid,
  });

  Future<void> acceptFriendRequest({
    required String friendshipId,
    required String actingUid,
  });

  Future<void> removeFriendship({
    required String friendshipId,
    required String actingUid,
  });

  Future<void> blockPlayer({
    required String actingUid,
    required String blockedUid,
  });

  Future<List<RecentPlayer>> loadRecentPlayers(String uid, {int limit = 30});
}
