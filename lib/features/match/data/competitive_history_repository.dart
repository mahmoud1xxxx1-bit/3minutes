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
    required this.myTotalScore,
    required this.opponentTotalScore,
    required this.games,
    required this.completedAt,
  });

  factory CompetitiveHistoryEntry.fromMap(Map<String, dynamic> data) {
    final completedAtMs = (data['completedAtMs'] as num?)?.toInt();
    final rawGames = data['gameResults'];
    final games = rawGames is List
        ? rawGames
            .whereType<Map>()
            .map((item) => CompetitiveHistoryGame.fromMap(Map<String, dynamic>.from(item)))
            .toList(growable: false)
        : const <CompetitiveHistoryGame>[];
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
      myTotalScore: (data['myTotalScore'] as num?)?.toInt() ?? 0,
      opponentTotalScore: (data['opponentTotalScore'] as num?)?.toInt() ?? 0,
      games: games,
      completedAt: completedAtMs == null ? null : DateTime.fromMillisecondsSinceEpoch(completedAtMs),
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
  final int myTotalScore;
  final int opponentTotalScore;
  final List<CompetitiveHistoryGame> games;
  final DateTime? completedAt;
}

class CompetitiveHistoryGame {
  const CompetitiveHistoryGame({
    required this.gameId,
    required this.gameIndex,
    required this.myScore,
    required this.opponentScore,
    required this.result,
  });

  factory CompetitiveHistoryGame.fromMap(Map<String, dynamic> data) => CompetitiveHistoryGame(
        gameId: data['gameId'] as String? ?? '',
        gameIndex: (data['gameIndex'] as num?)?.toInt() ?? 0,
        myScore: (data['myScore'] as num?)?.toInt() ?? 0,
        opponentScore: (data['opponentScore'] as num?)?.toInt() ?? 0,
        result: data['result'] as String? ?? 'tie',
      );

  final String gameId;
  final int gameIndex;
  final int myScore;
  final int opponentScore;
  final String result;
}
