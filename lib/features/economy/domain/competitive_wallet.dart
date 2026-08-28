enum WalletCurrency { coins, gold }

enum WalletEntryKind {
  dailyGold,
  wagerHold,
  wagerRelease,
  wagerWin,
  matchCoins,
  shopPurchase,
  adjustment,
}

class CompetitiveWallet {
  const CompetitiveWallet({
    required this.coins,
    required this.gold,
    this.heldGold = 0,
  });

  final int coins;
  final int gold;
  final int heldGold;

  int get availableGold => gold - heldGold;
  bool canWager(int amount) => amount > 0 && availableGold >= amount;
}

class WalletLedgerEntry {
  const WalletLedgerEntry({
    required this.id,
    required this.currency,
    required this.kind,
    required this.amount,
    required this.createdAt,
    this.matchId,
    this.referenceId,
  });

  final String id;
  final WalletCurrency currency;
  final WalletEntryKind kind;
  final int amount;
  final DateTime createdAt;
  final String? matchId;
  final String? referenceId;
}
