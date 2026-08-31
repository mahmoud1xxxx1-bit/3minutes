import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/competition/domain/rank_tier.dart';
import 'package:game/features/competition/domain/ranked_settlement_player.dart';
import 'package:game/features/match/presentation/ranked_reward_receipt.dart';

Widget _host(RankedSettlementPlayer settlement) => MaterialApp(
      home: Scaffold(
        body: RankedRewardReceipt(settlement: settlement),
      ),
    );

void main() {
  testWidgets('shows standard coins and wager payout separately', (tester) async {
    const settlement = RankedSettlementPlayer(
      uid: 'winner',
      previousRp: 1000,
      nextRp: 1030,
      rpDelta: 30,
      previousTier: RankTier.silver,
      nextTier: RankTier.silver,
      xpAwarded: 120,
      coinsAwarded: 30,
      wagerPayoutCoins: 200,
    );

    await tester.pumpWidget(_host(settlement));

    expect(find.text('+30'), findsNWidgets(2));
    expect(find.text('+120'), findsOneWidget);
    expect(find.text('+200'), findsOneWidget);
    expect(find.text('+230'), findsOneWidget);
    expect(find.byKey(const ValueKey('wager-payout-row')), findsOneWidget);
    expect(find.byKey(const ValueKey('total-coins-row')), findsOneWidget);
  });

  testWidgets('shows loss RP and zero wager payout without hiding it', (tester) async {
    const settlement = RankedSettlementPlayer(
      uid: 'loser',
      previousRp: 1000,
      nextRp: 982,
      rpDelta: -18,
      previousTier: RankTier.silver,
      nextTier: RankTier.silver,
      xpAwarded: 55,
      coinsAwarded: 10,
      wagerPayoutCoins: 0,
    );

    await tester.pumpWidget(_host(settlement));

    expect(find.text('-18'), findsOneWidget);
    expect(find.text('+55'), findsOneWidget);
    expect(find.text('+10'), findsNWidgets(2));
    expect(find.text('+0'), findsOneWidget);
  });
}
