class Party {
  const Party({
    required this.id,
    required this.leaderUid,
    required this.memberUids,
    required this.createdAt,
    required this.updatedAt,
    this.pendingInviteUids = const <String>[],
    this.activeRoomId,
  });

  final String id;
  final String leaderUid;
  final List<String> memberUids;
  final List<String> pendingInviteUids;
  final String? activeRoomId;
  final DateTime createdAt;
  final DateTime updatedAt;

  int get size => memberUids.length;
  bool isMember(String uid) => memberUids.contains(uid);
  bool isInvited(String uid) => pendingInviteUids.contains(uid);
}

class PartyPolicy {
  const PartyPolicy._();

  static const int maxMembers = 6;

  static void validate(Party party) {
    if (party.memberUids.isEmpty || party.memberUids.length > maxMembers) {
      throw StateError('Party size must be between 1 and 6 players.');
    }
    if (party.memberUids.toSet().length != party.memberUids.length) {
      throw StateError('Duplicate party members are not allowed.');
    }
    if (party.pendingInviteUids.toSet().length != party.pendingInviteUids.length) {
      throw StateError('Duplicate party invitations are not allowed.');
    }
    if (party.pendingInviteUids.any(party.memberUids.contains)) {
      throw StateError('Party members cannot also have pending invitations.');
    }
    if (!party.memberUids.contains(party.leaderUid)) {
      throw StateError('Party leader must be a party member.');
    }
  }

  static bool canStartMatch(Party party) =>
      const <int>{2, 4, 6}.contains(party.memberUids.length);
}
