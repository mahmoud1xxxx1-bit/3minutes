enum RankedWager {
  gold100(100),
  gold250(250),
  gold500(500);

  const RankedWager(this.gold);
  final int gold;

  static RankedWager fromGold(int value) => switch (value) {
        100 => RankedWager.gold100,
        250 => RankedWager.gold250,
        500 => RankedWager.gold500,
        _ => throw ArgumentError.value(value, 'value', 'Unsupported ranked Gold wager'),
      };
}

class GoldWagerSettlementPreview {
  const GoldWagerSettlementPreview({
    required this.playerARefund,
    required this.playerBRefund,
    required this.playerAPayout,
    required this.playerBPayout,
    required this.burnedGold,
  });

  final int playerARefund;
  final int playerBRefund;
  final int playerAPayout;
  final int playerBPayout;
  final int burnedGold;

  static GoldWagerSettlementPreview winner({
    required RankedWager wager,
    required bool playerAWon,
  }) {
    final pool = wager.gold * 2;
    return GoldWagerSettlementPreview(
      playerARefund: 0,
      playerBRefund: 0,
      playerAPayout: playerAWon ? pool : 0,
      playerBPayout: playerAWon ? 0 : pool,
      burnedGold: 0,
    );
  }

  static GoldWagerSettlementPreview doubleFail(RankedWager wager) {
    final refund = wager.gold ~/ 2;
    return GoldWagerSettlementPreview(
      playerARefund: refund,
      playerBRefund: refund,
      playerAPayout: 0,
      playerBPayout: 0,
      burnedGold: wager.gold * 2 - refund * 2,
    );
  }
}
