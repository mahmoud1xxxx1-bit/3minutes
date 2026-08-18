import '../domain/ranked_settlement.dart';
import '../domain/ranked_settlement_request.dart';

abstract class RankedAuthorityBackend {
  /// Requests authoritative settlement for a completed match.
  ///
  /// The implementation must validate the authenticated player, match state,
  /// deterministic game contract, per-game evidence, duplicate settlement,
  /// season, and anti-cheat checks before any RP/XP/coin writes are committed.
  Future<RankedMatchSettlement> settleMatch(RankedSettlementRequest request);
}
