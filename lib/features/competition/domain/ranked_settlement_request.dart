import 'mini_game_evidence.dart';

class RankedSettlementRequest {
  const RankedSettlementRequest({
    required this.matchId,
    required this.evidence,
  });

  final String matchId;
  final List<MiniGameEvidence> evidence;
}
