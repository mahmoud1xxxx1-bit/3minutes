import 'package:flutter_test/flutter_test.dart';
import 'package:three_minutes/features/competition/domain/ranked_settlement_player.dart';
import 'package:three_minutes/features/match/domain/ranked_wager.dart';

void main() {
  test('ranked wagers are exactly 100 250 and 500 gold', () {
    expect(RankedWager.values.map((wager) => wager.gold).toList(), [100, 250, 500]);
    expect(RankedWager.fromGold(100), RankedWager.gold100);
    expect(RankedWager.fromGold(250), RankedWager.gold250);
    expect(RankedWager.fromGold(500), RankedWager.gold500);
    expect(RankedWager.fromGold(50), isNull);
  });

  test('winner preview receives full pool and net profit equals own wager', () {
    final preview = GoldWagerSettlementPreview.win(RankedWager.gold250);
    expect(preview.poolGold, 500);
    expect(preview.creditGold, 500);
    expect(preview.netGold, 250);
  });

  test('double fail preview returns only half of the wager', () {
    final preview = GoldWagerSettlementPreview.doubleFail(RankedWager.gold500);
    expect(preview.creditGold, 250);
    expect(preview.netGold, -250);
  });

  test('ranked settlement receipt parses authoritative gold fields', () {
    final receipt = RankedSettlementPlayer.fromPayload(
      {
        'uid': 'player-a',
        'previousRp': 1200,
        'nextRp': 1230,
        'rpDelta': 30,
        'previousTier': 'gold',
        'nextTier': 'gold',
        'xpAwarded': 120,
        'coinsAwarded': 30,
        'wagerGold': 250,
        'goldCredited': 500,
        'goldNetDelta': 250,
        'goldBalanceAfter': 1750,
      },
      uid: 'player-a',
    );

    expect(receipt, isNotNull);
    expect(receipt!.hasGoldSettlement, isTrue);
    expect(receipt.wagerGold, 250);
    expect(receipt.goldCredited, 500);
    expect(receipt.goldNetDelta, 250);
    expect(receipt.goldBalanceAfter, 1750);
  });

  test('receipt rejects inconsistent gold arithmetic', () {
    final receipt = RankedSettlementPlayer.fromPayload(
      {
        'uid': 'player-a',
        'previousRp': 1200,
        'nextRp': 1230,
        'rpDelta': 30,
        'previousTier': 'gold',
        'nextTier': 'gold',
        'xpAwarded': 120,
        'coinsAwarded': 30,
        'wagerGold': 250,
        'goldCredited': 500,
        'goldNetDelta': 100,
        'goldBalanceAfter': 1750,
      },
      uid: 'player-a',
    );

    expect(receipt, isNull);
  });
}
