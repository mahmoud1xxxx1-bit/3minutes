enum FriendshipStatus {
  pending,
  accepted,
  blocked,
}

class Friendship {
  const Friendship({
    required this.id,
    required this.requesterUid,
    required this.recipientUid,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String requesterUid;
  final String recipientUid;
  final FriendshipStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool involves(String uid) => requesterUid == uid || recipientUid == uid;
}

class RecentPlayer {
  const RecentPlayer({
    required this.uid,
    required this.displayName,
    required this.lastPlayedAt,
    required this.matchId,
    this.avatarId,
  });

  final String uid;
  final String displayName;
  final String? avatarId;
  final DateTime lastPlayedAt;
  final String matchId;
}

class FriendshipPolicy {
  const FriendshipPolicy._();

  static String pairId(String uidA, String uidB) {
    if (uidA == uidB) {
      throw ArgumentError('A player cannot friend themselves.');
    }
    final ids = [uidA, uidB]..sort();
    return '${ids[0]}:${ids[1]}';
  }

  static bool canAccept({
    required Friendship friendship,
    required String actingUid,
  }) {
    return friendship.status == FriendshipStatus.pending &&
        friendship.recipientUid == actingUid;
  }
}
