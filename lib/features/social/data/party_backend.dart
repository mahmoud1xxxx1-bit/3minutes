import '../domain/party.dart';

abstract class PartyBackend {
  Stream<Party?> watchParty(String partyId);

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
