import 'mini_game_evidence.dart';

class RankedSettlementRequest {
  const RankedSettlementRequest({
    required this.matchId,
    required this.evidence,
  });

  final String matchId;
  final List<MiniGameEvidence> evidence;

  Map<String, Object> toMap() => {
        'matchId': matchId,
        'evidence': evidence.map((item) => item.toMap()).toList(growable: false),
      };

  factory RankedSettlementRequest.fromMap(Map<Object?, Object?> map) {
    final rawEvidence = map['evidence'];
    final evidence = rawEvidence is List
        ? rawEvidence
            .whereType<Map>()
            .map(
              (item) => MiniGameEvidence.fromMap(
                Map<Object?, Object?>.from(item),
              ),
            )
            .toList(growable: false)
        : const <MiniGameEvidence>[];

    return RankedSettlementRequest(
      matchId: map['matchId'] as String? ?? '',
      evidence: evidence,
    );
  }
}
