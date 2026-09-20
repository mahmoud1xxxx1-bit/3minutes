import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/competition/domain/rank_tier.dart';
import 'package:game/features/competition/domain/ranked_settlement_player.dart';
import 'package:game/features/competition/presentation/rank_promotion_reveal.dart';

void main() {
  test('authoritative settlement detects promotion', () {
    final settlement = RankedSettlementPlayer.fromPayload(
      {
        'uid': 'u1',
        'previousRp': 1180,
        'nextRp': 1220,
        'rpDelta': 40,
        'previousTier': 'silver',
        'nextTier': 'gold',
        'xpAwarded': 100,
        'coinsAwarded': 80,
      },
      uid: 'u1',
    );

    expect(settlement, isNotNull);
    expect(settlement!.promoted, isTrue);
    expect(settlement.demoted, isFalse);
    expect(settlement.nextTier, RankTier.gold);
  });

  test('forged or inconsistent settlement payload is rejected', () {
    expect(
      RankedSettlementPlayer.fromPayload(
        {
          'uid': 'other',
          'previousRp': 500,
          'nextRp': 540,
          'rpDelta': 999,
          'previousTier': 'silver',
          'nextTier': 'silver',
          'xpAwarded': 10,
          'coinsAwarded': 10,
        },
        uid: 'u1',
      ),
      isNull,
    );
  });

  testWidgets('rank promotion reveal renders the promoted tier safely', (tester) async {
    const settlement = RankedSettlementPlayer(
      uid: 'u1',
      previousRp: 4950,
      nextRp: 5050,
      rpDelta: 100,
      previousTier: RankTier.diamond,
      nextTier: RankTier.master,
      xpAwarded: 100,
      coinsAwarded: 80,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: RankPromotionReveal(settlement: settlement),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 1000));

    expect(tester.takeException(), isNull);
    expect(find.text('RANK PROMOTION'), findsOneWidget);
    expect(find.text('Master'), findsOneWidget);
    expect(find.text('4950 → 5050 RP'), findsOneWidget);
  });
}
