import '../../competition/domain/ranked_settlement_player.dart';
import '../../profile/domain/player_profile.dart';
import '../domain/match_progress.dart';
import '../domain/match_session.dart';
import '../domain/match_ticket.dart';

abstract class MatchBackend {
  Future<void> joinQueue(PlayerProfile profile);

  Future<void> leaveQueue(String uid);

  Future<void> clearTicket(String uid);

  Future<void> moveTicketToMatch({
    required String uid,
    required String matchId,
  });

  Stream<MatchTicket?> watchTicket(String uid);

  Stream<MatchSession?> watchMatch(String matchId);

  Future<List<MatchSession>> loadHistory(String uid);

  Future<void> markReady({
    required String matchId,
    required String uid,
  });

  Future<void> cancelMatch({
    required String matchId,
    required String uid,
  });

  Future<void> finalizeMatch({
    required String matchId,
    required String uid,
  });

  /// Finalizes a ranked match and returns the authoritative settlement payload
  /// when the active backend supports it. Spark fallback implementations may
  /// safely return null after finalizing because they do not award Ranked RP.
  Future<RankedSettlementPlayer?> finalizeMatchWithResult({
    required String matchId,
    required String uid,
  }) async {
    await finalizeMatch(matchId: matchId, uid: uid);
    return null;
  }

  Future<void> requestRematch({
    required String matchId,
    required String uid,
  });

  Future<void> cancelRematchRequest({
    required String matchId,
    required String uid,
  });

  Future<void> submitProgress({
    required String matchId,
    required String uid,
    required MatchProgress progress,
    required int gameCount,
  });
}
