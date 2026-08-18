import '../../profile/domain/player_profile.dart';
import '../domain/match_progress.dart';
import '../domain/match_session.dart';
import '../domain/match_ticket.dart';

abstract class MatchBackend {
  Future<void> joinQueue(PlayerProfile profile);

  Future<void> leaveQueue(String uid);

  Stream<MatchTicket?> watchTicket(String uid);

  Stream<MatchSession?> watchMatch(String matchId);

  Future<void> markReady({
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
