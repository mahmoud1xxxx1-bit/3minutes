class PurchaseReceipt {
  const PurchaseReceipt({
    required this.transactionId,
    required this.uid,
    required this.cosmeticId,
    required this.coinPrice,
    required this.remainingCoins,
    required this.purchasedAt,
  });

  final String transactionId;
  final String uid;
  final String cosmeticId;
  final int coinPrice;
  final int remainingCoins;
  final DateTime purchasedAt;
}
