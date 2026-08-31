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

/// Capability implemented only by server-authoritative Ranked matchmaking.
/// Local/Spark fallbacks intentionally do not accept Coin wagers because a
/// wager must never be settled by a writable client datastore.
abstract interface class RankedWagerMatchBackend {
  Future<void> joinQueueWithWager(
    PlayerProfile profile, {
    required int wagerCoins,
  });
}

/// Optional capability implemented only by ranked backends that can return the
/// server-authoritative settlement receipt. Spark fallbacks intentionally do
/// not implement this interface because they do not award Ranked RP.
abstract interface class RankedSettlementResultBackend {
  Future<RankedSettlementPlayer?> finalizeMatchWithResult({
    required String matchId,
    required String uid,
  });
}
