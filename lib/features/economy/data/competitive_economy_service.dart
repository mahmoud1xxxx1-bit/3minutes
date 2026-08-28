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

  Future<WagerEntryResult> enterWager({
    required int wager,
    required String displayName,
    required String avatarId,
  }) async {
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
}

class DailyGoldClaimResult {
  const DailyGoldClaimResult({required this.amount, required this.gold, required this.dayKey});
  final int amount;
  final int gold;
  final String dayKey;
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
