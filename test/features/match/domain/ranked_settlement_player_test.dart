import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/competition/domain/ranked_settlement_player.dart';

void main() {
  group('RankedSettlementPlayer', () {
    test('accepts a winner payload with authoritative Gold settlement', () {
      final receipt = RankedSettlementPlayer.fromPayload(
        {
          'uid': 'player-a',
          'previousRp': 1200,
          'nextRp': 1225,
          'rpDelta': 25,
          'previousTier': 'silver',
          'nextTier': 'silver',
          'xpAwarded': 120,
          'coinsAwarded': 80,
          'wagerGold': 250,
          'goldCredited': 500,
          'goldNetDelta': 250,
          'goldBalanceAfter': 900,
        },
        uid: 'player-a',
      );

      expect(receipt, isNotNull);
      expect(receipt!.hasGoldSettlement, isTrue);
      expect(receipt.wagerGold, 250);
      expect(receipt.goldCredited, 500);
      expect(receipt.goldNetDelta, 250);
      expect(receipt.goldBalanceAfter, 900);
    });

    test('accepts double-fail half refund as a negative net match delta', () {
      final receipt = RankedSettlementPlayer.fromPayload(
        {
          'uid': 'player-a',
          'previousRp': 1200,
          'nextRp': 1200,
          'rpDelta': 0,
          'previousTier': 'silver',
          'nextTier': 'silver',
          'xpAwarded': 40,
          'coinsAwarded': 20,
          'wagerGold': 500,
          'goldCredited': 250,
          'goldNetDelta': -250,
          'goldBalanceAfter': 750,
        },
        uid: 'player-a',
      );

      expect(receipt, isNotNull);
      expect(receipt!.goldNetDelta, -250);
    });

    test('rejects tampered Gold arithmetic', () {
      final receipt = RankedSettlementPlayer.fromPayload(
        {
          'uid': 'player-a',
          'previousRp': 1200,
          'nextRp': 1225,
          'rpDelta': 25,
          'previousTier': 'silver',
          'nextTier': 'silver',
          'xpAwarded': 120,
          'coinsAwarded': 80,
          'wagerGold': 250,
          'goldCredited': 500,
          'goldNetDelta': 999,
          'goldBalanceAfter': 900,
        },
        uid: 'player-a',
      );

      expect(receipt, isNull);
    });
  });
}
