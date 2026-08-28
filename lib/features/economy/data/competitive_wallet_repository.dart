import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/competitive_wallet.dart';
import '../domain/daily_gold_mail.dart';

class CompetitiveWalletRepository {
  CompetitiveWalletRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _wallet(String uid) =>
      _firestore.collection('competitiveWallets').doc(uid);

  Stream<CompetitiveWallet> watchWallet(String uid) {
    return _wallet(uid).snapshots().map((snapshot) {
      final data = snapshot.data() ?? const <String, dynamic>{};
      return CompetitiveWallet(
        coins: 0,
        gold: (data['gold'] as num?)?.toInt() ?? 0,
        heldGold: (data['heldGold'] as num?)?.toInt() ?? 0,
      );
    });
  }

  Stream<DailyGoldMail?> watchTodayMail(String uid) {
    final key = DateTime.now().toUtc().toIso8601String().substring(0, 10);
    return _wallet(uid).collection('dailyGoldMail').doc(key).snapshots().map((snapshot) {
      final data = snapshot.data();
      if (!snapshot.exists || data == null) return null;
      DateTime? readTime(Object? value) => value is Timestamp ? value.toDate() : null;
      return DailyGoldMail(
        id: snapshot.id,
        dayKey: data['dayKey'] as String? ?? key,
        createdAt: readTime(data['createdAt']) ?? DateTime.now(),
        claimed: data['claimed'] as bool? ?? false,
        claimedAt: readTime(data['claimedAt']),
        amount: (data['amount'] as num?)?.toInt() ?? 1000,
      );
    });
  }
}
