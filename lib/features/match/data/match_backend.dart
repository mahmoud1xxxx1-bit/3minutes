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

  Future<void> requestRematch({
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
