import 'package:cloud_functions/cloud_functions.dart';

class CompetitiveEconomyService {
  CompetitiveEconomyService({FirebaseFunctions? functions})
      : _functions = functions ?? FirebaseFunctions.instanceFor(region: 'me-central2');

  final FirebaseFunctions _functions;

  Future<DailyGoldClaimResult> claimDailyGold() async {
    final result = await _functions.httpsCallable('claimDailyGold').call<Object?>();
    final data = Map<String, dynamic>.from(result.data! as Map);
    return DailyGoldClaimResult(
      amount: (data['amount'] as num).toInt(),
      gold: (data['gold'] as num).toInt(),
      dayKey: data['dayKey'] as String,
    );
  }

  Future<CompetitiveRecoveryResult> recoverQueue() async {
    final result = await _functions.httpsCallable('recoverCompetitiveQueue').call<Object?>();
    final data = Map<String, dynamic>.from(result.data! as Map);
    return CompetitiveRecoveryResult(
      status: data['status'] as String? ?? 'none',
      released: (data['released'] as num?)?.toInt() ?? 0,
      matchId: data['matchId'] as String?,
      wager: (data['wager'] as num?)?.toInt(),
    );
  }

  Future<WagerEntryResult> enterWager({
    required int wager,
    required String displayName,
    required String avatarId,
  }) async {
    await recoverQueue();
    final result = await _functions.httpsCallable('enterGoldWager').call<Object?>(
      <String, Object?>{
        'wager': wager,
        'displayName': displayName,
        'avatarId': avatarId,
      },
    );
    final data = Map<String, dynamic>.from(result.data! as Map);
    return WagerEntryResult(
      wager: (data['wager'] as num).toInt(),
      pot: (data['pot'] as num).toInt(),
      status: data['status'] as String? ?? 'searching',
      matchId: data['matchId'] as String?,
    );
  }

  Future<int> leaveWager() async {
    final result = await _functions.httpsCallable('leaveGoldWager').call<Object?>();
    final data = Map<String, dynamic>.from(result.data! as Map);
    return (data['released'] as num).toInt();
  }

  Future<void> selectGames({
    required String matchId,
    required List<String> gameIds,
  }) async {
    await _functions.httpsCallable('selectCompetitiveGames').call<Object?>(
      <String, Object?>{'matchId': matchId, 'gameIds': gameIds},
    );
  }

  Future<CompetitiveReadyResult> markReady(String matchId) async {
    final result = await _functions.httpsCallable('markCompetitiveReady').call<Object?>(
      <String, Object?>{'matchId': matchId},
    );
    final data = Map<String, dynamic>.from(result.data! as Map);
    return CompetitiveReadyResult(
      status: data['status'] as String? ?? 'waitingReady',
      bothReady: data['bothReady'] as bool? ?? false,
    );
  }

  Future<void> cancelMatch(String matchId) async {
    await _functions.httpsCallable('cancelCompetitiveMatch').call<Object?>(
      <String, Object?>{'matchId': matchId},
    );
  }

  Future<void> forfeitMatch(String matchId) async {
    await _functions.httpsCallable('forfeitCompetitiveMatch').call<Object?>(
      <String, Object?>{'matchId': matchId},
    );
  }

  Future<void> submitGameResult({
    required String matchId,
    required String gameId,
    required int gameIndex,
    required num rawScore,
    required int normalizedScore,
    required bool completed,
    required double progress,
    required Duration elapsed,
    Map<String, num> stats = const <String, num>{},
  }) async {
    await _functions.httpsCallable('submitCompetitiveGameResult').call<Object?>(
      <String, Object?>{
        'matchId': matchId,
        'gameId': gameId,
        'gameIndex': gameIndex,
        'rawScore': rawScore,
        'normalizedScore': normalizedScore,
        'completed': completed,
        'progress': progress,
        'elapsedMs': elapsed.inMilliseconds,
        'stats': stats,
      },
    );
  }

  Future<CompetitiveFinalizedResult> finalizeResults(String matchId) async {
    final response = await _functions.httpsCallable('finalizeCompetitiveResults').call<Object?>(
      <String, Object?>{'matchId': matchId},
    );
    final data = Map<String, dynamic>.from(response.data! as Map);
    final games = (data['gameResults'] as List? ?? const <Object?>[])
        .whereType<Map>()
        .map((entry) => CompetitiveGameComparison.fromMap(Map<String, dynamic>.from(entry)))
        .toList(growable: false);
    return CompetitiveFinalizedResult(
      status: data['status'] as String? ?? 'awaitingSettlement',
      outcome: data['outcome'] as String? ?? 'tie',
      totalScoreA: (data['totalScoreA'] as num?)?.toInt() ?? 0,
      totalScoreB: (data['totalScoreB'] as num?)?.toInt() ?? 0,
      games: games,
    );
  }

  Future<CompetitiveSettlementResult> settleMatch(String matchId) async {
    final result = await _functions.httpsCallable('settleCompetitiveMatch').call<Object?>(
      <String, Object?>{'matchId': matchId},
    );
    final data = Map<String, dynamic>.from(result.data! as Map);
    final playerA = Map<String, dynamic>.from(data['playerA'] as Map? ?? const <String, dynamic>{});
    final playerB = Map<String, dynamic>.from(data['playerB'] as Map? ?? const <String, dynamic>{});
    return CompetitiveSettlementResult(
      matchId: data['matchId'] as String? ?? matchId,
      outcome: data['outcome'] as String? ?? 'tie',
      wager: (data['wager'] as num?)?.toInt() ?? 0,
      playerA: CompetitiveSettlementPlayer.fromMap(playerA),
      playerB: CompetitiveSettlementPlayer.fromMap(playerB),
    );
  }
}

class DailyGoldClaimResult {
  const DailyGoldClaimResult({required this.amount, required this.gold, required this.dayKey});
  final int amount;
  final int gold;
  final String dayKey;
}

class CompetitiveRecoveryResult {
  const CompetitiveRecoveryResult({
    required this.status,
    required this.released,
    required this.matchId,
    required this.wager,
  });
  final String status;
  final int released;
  final String? matchId;
  final int? wager;

  bool get hasActiveMatch => status == 'matched' && matchId != null && wager != null;
}

class WagerEntryResult {
  const WagerEntryResult({
    required this.wager,
    required this.pot,
    required this.status,
    required this.matchId,
  });
  final int wager;
  final int pot;
  final String status;
  final String? matchId;

  bool get matched => status == 'matched' && matchId != null;
}

class CompetitiveReadyResult {
  const CompetitiveReadyResult({required this.status, required this.bothReady});
  final String status;
  final bool bothReady;
}

class CompetitiveFinalizedResult {
  const CompetitiveFinalizedResult({
    required this.status,
    required this.outcome,
    required this.totalScoreA,
    required this.totalScoreB,
    required this.games,
  });

  final String status;
  final String outcome;
  final int totalScoreA;
  final int totalScoreB;
  final List<CompetitiveGameComparison> games;
}

class CompetitiveGameComparison {
  const CompetitiveGameComparison({
    required this.gameId,
    required this.gameIndex,
    required this.playerAScore,
    required this.playerBScore,
    required this.winner,
  });

  factory CompetitiveGameComparison.fromMap(Map<String, dynamic> data) {
    return CompetitiveGameComparison(
      gameId: data['gameId'] as String? ?? '',
      gameIndex: (data['gameIndex'] as num?)?.toInt() ?? 0,
      playerAScore: (data['playerAScore'] as num?)?.toInt() ?? 0,
      playerBScore: (data['playerBScore'] as num?)?.toInt() ?? 0,
      winner: data['winner'] as String? ?? 'tie',
    );
  }

  final String gameId;
  final int gameIndex;
  final int playerAScore;
  final int playerBScore;
  final String winner;
}

class CompetitiveSettlementResult {
  const CompetitiveSettlementResult({
    required this.matchId,
    required this.outcome,
    required this.wager,
    required this.playerA,
    required this.playerB,
  });

  final String matchId;
  final String outcome;
  final int wager;
  final CompetitiveSettlementPlayer playerA;
  final CompetitiveSettlementPlayer playerB;
}

class CompetitiveSettlementPlayer {
  const CompetitiveSettlementPlayer({
    required this.uid,
    required this.goldDelta,
    required this.coinsDelta,
    required this.rpDelta,
  });

  factory CompetitiveSettlementPlayer.fromMap(Map<String, dynamic> data) {
    return CompetitiveSettlementPlayer(
      uid: data['uid'] as String? ?? '',
      goldDelta: (data['goldDelta'] as num?)?.toInt() ?? 0,
      coinsDelta: (data['coinsDelta'] as num?)?.toInt() ?? 0,
      rpDelta: (data['rpDelta'] as num?)?.toInt() ?? 0,
    );
  }

  final String uid;
  final int goldDelta;
  final int coinsDelta;
  final int rpDelta;
}
