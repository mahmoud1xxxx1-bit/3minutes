import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/competition/domain/rank_tier.dart';
import 'package:game/features/competition/domain/ranked_settlement_player.dart';
import 'package:game/features/competition/presentation/rank_promotion_events.dart';
import 'package:game/features/competition/presentation/rank_promotion_overlay_host.dart';

const promoted = RankedSettlementPlayer(
  uid: 'u1',
  previousRp: 4950,
  nextRp: 5050,
  rpDelta: 100,
  previousTier: RankTier.diamond,
  nextTier: RankTier.master,
  xpAwarded: 100,
  coinsAwarded: 80,
);

const sameTier = RankedSettlementPlayer(
  uid: 'u1',
  previousRp: 5100,
  nextRp: 5140,
  rpDelta: 40,
  previousTier: RankTier.master,
  nextTier: RankTier.master,
  xpAwarded: 100,
  coinsAwarded: 80,
);

void main() {
  setUp(RankPromotionEvents.resetForTesting);
  tearDown(RankPromotionEvents.resetForTesting);

  test('promotion events ignore non-promotions and deduplicate by match', () {
    RankPromotionEvents.publish('m1', sameTier);
    expect(RankPromotionEvents.current.value, isNull);

    RankPromotionEvents.publish('m1', promoted);
    expect(RankPromotionEvents.current.value?.matchId, 'm1');

    RankPromotionEvents.dismiss();
    RankPromotionEvents.publish('m1', promoted);
    expect(RankPromotionEvents.current.value, isNull);

    RankPromotionEvents.publish('m2', promoted);
    expect(RankPromotionEvents.current.value?.matchId, 'm2');
  });

  testWidgets('promotion overlay appears once and can be dismissed', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: RankPromotionOverlayHost(
          child: Scaffold(body: Text('RESULT SCREEN')),
        ),
      ),
    );

    expect(find.text('RESULT SCREEN'), findsOneWidget);
    expect(find.text('RANK PROMOTION'), findsNothing);

    RankPromotionEvents.publish('match-42', promoted);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1000));

    expect(tester.takeException(), isNull);
    expect(find.text('RANK PROMOTION'), findsOneWidget);
    expect(find.text('Master'), findsOneWidget);
    expect(find.text('CONTINUE'), findsOneWidget);

    await tester.tap(find.text('CONTINUE'));
    await tester.pump();
    expect(find.text('RANK PROMOTION'), findsNothing);
  });
}
