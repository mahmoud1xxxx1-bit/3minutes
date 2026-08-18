import '../domain/ranked_settlement.dart';

abstract class RankedAuthorityBackend {
  /// Requests authoritative settlement for a completed match.
  ///
  /// The implementation must validate the authenticated player, match state,
  /// deterministic game contract, duplicate settlement, season, and anti-cheat
  /// checks before any RP/XP/coin writes are committed.
  Future<RankedMatchSettlement> settleMatch(String matchId);
}
