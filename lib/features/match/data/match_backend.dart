import '../../competition/domain/ranked_settlement_player.dart';
import '../../minigames/domain/mini_game_contract.dart';
import '../../profile/domain/player_profile.dart';
import '../domain/match_progress.dart';
import '../domain/match_session.dart';
import '../domain/match_ticket.dart';
import '../domain/ranked_wager.dart';

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

/// Capability implemented by Ranked authority only. Quick and social modes stay
/// outside the Gold wager economy.
abstract interface class RankedWagerQueueBackend {
  Future<void> joinRankedQueueWithWager(
    PlayerProfile profile, {
    required RankedWager wager,
  });
}

abstract interface class MatchGameSelectionBackend {
  Future<void> submitGameSelection({
    required String matchId,
    required String uid,
    required List<String> gameIds,
  });
}

/// Ranked authority receives the complete mini-game result contract so it can
/// preserve completion, discrete progress, mistakes and duration verbatim.
abstract interface class DetailedGameResultBackend {
  Future<void> submitMiniGameResult({
    required String matchId,
    required String uid,
    required MiniGameResult result,
    required int gameCount,
  });
}

/// Ranked settlement is a strict MatchBackend subtype so Dart can safely
/// promote a backend after the runtime capability check.
abstract interface class RankedSettlementResultBackend implements MatchBackend {
  Future<RankedSettlementPlayer?> finalizeMatchWithResult({
    required String matchId,
    required String uid,
  });
}
