import 'package:cloud_functions/cloud_functions.dart';

class CompetitiveEconomyService {
  CompetitiveEconomyService({FirebaseFunctions? functions})
      : _functions = functions ?? FirebaseFunctions.instance;

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

  Future<WagerEntryResult> enterWager(int wager) async {
    final result = await _functions.httpsCallable('enterGoldWager').call<Object?>({'wager': wager});
    final data = Map<String, dynamic>.from(result.data! as Map);
    return WagerEntryResult(
      wager: (data['wager'] as num).toInt(),
      pot: (data['pot'] as num).toInt(),
    );
  }

  Future<int> leaveWager() async {
    final result = await _functions.httpsCallable('leaveGoldWager').call<Object?>();
    final data = Map<String, dynamic>.from(result.data! as Map);
    return (data['released'] as num).toInt();
  }
}

class DailyGoldClaimResult {
  const DailyGoldClaimResult({required this.amount, required this.gold, required this.dayKey});
  final int amount;
  final int gold;
  final String dayKey;
}

class WagerEntryResult {
  const WagerEntryResult({required this.wager, required this.pot});
  final int wager;
  final int pot;
}
