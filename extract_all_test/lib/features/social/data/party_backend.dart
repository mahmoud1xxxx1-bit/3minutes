import '../domain/party.dart';

abstract class PartyBackend {
  Stream<Party?> watchParty(String partyId);

  Stream<Party?> watchMembership(String uid);

  Stream<List<Party>> watchInvitations(String uid);

  Future<Party> createParty({required String leaderUid});

  Future<void> inviteMember({
    required String partyId,
    required String leaderUid,
    required String invitedUid,
  });

  Future<void> acceptInvite({
    required String partyId,
    required String uid,
  });

  Future<void> declineInvite({
    required String partyId,
    required String uid,
  });

  Future<void> setActiveRoom({
    required String partyId,
    required String leaderUid,
    required String? roomId,
  });

  Future<void> leaveParty({
    required String partyId,
    required String uid,
  });

  Future<void> removeMember({
    required String partyId,
    required String leaderUid,
    required String memberUid,
  });
}
