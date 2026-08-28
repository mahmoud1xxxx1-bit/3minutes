import 'package:cloud_functions/cloud_functions.dart';

class CompetitiveHistoryRepository {
  CompetitiveHistoryRepository({FirebaseFunctions? functions})
      : _functions = functions ?? FirebaseFunctions.instanceFor(region: 'me-central2');

  final FirebaseFunctions _functions;

  Future<List<CompetitiveHistoryEntry>> load({int limit = 20}) async {
    final result = await _functions.httpsCallable('getCompetitiveMatchHistory').call<Object?>(
      <String, Object?>{'limit': limit},
    );
    final data = Map<String, dynamic>.from(result.data! as Map);
    final rawMatches = data['matches'];
    if (rawMatches is! List) return const <CompetitiveHistoryEntry>[];
    return rawMatches
        .whereType<Map>()
        .map((item) => CompetitiveHistoryEntry.fromMap(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }
}

class CompetitiveHistoryEntry {
  const CompetitiveHistoryEntry({
    required this.matchId,
    required this.result,
    required this.opponentName,
    required this.opponentAvatarId,
    required this.wager,
    required this.pot,
    required this.goldDelta,
    required this.coinsDelta,
    required this.rpDelta,
    required this.completedAt,
  });

  factory CompetitiveHistoryEntry.fromMap(Map<String, dynamic> data) {
    final completedAtMs = (data['completedAtMs'] as num?)?.toInt();
    return CompetitiveHistoryEntry(
      matchId: data['matchId'] as String? ?? '',
      result: data['result'] as String? ?? 'tie',
      opponentName: data['opponentName'] as String? ?? 'Player',
      opponentAvatarId: data['opponentAvatarId'] as String? ?? 'default_01',
      wager: (data['wager'] as num?)?.toInt() ?? 0,
      pot: (data['pot'] as num?)?.toInt() ?? 0,
      goldDelta: (data['goldDelta'] as num?)?.toInt() ?? 0,
      coinsDelta: (data['coinsDelta'] as num?)?.toInt() ?? 0,
      rpDelta: (data['rpDelta'] as num?)?.toInt() ?? 0,
      completedAt: completedAtMs == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(completedAtMs),
    );
  }

  final String matchId;
  final String result;
  final String opponentName;
  final String opponentAvatarId;
  final int wager;
  final int pot;
  final int goldDelta;
  final int coinsDelta;
  final int rpDelta;
  final DateTime? completedAt;
}
