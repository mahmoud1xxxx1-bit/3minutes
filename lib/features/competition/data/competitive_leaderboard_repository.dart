import 'package:cloud_firestore/cloud_firestore.dart';

enum CompetitiveLeaderboardType { rp, gold }

class CompetitiveLeaderboardRepository {
  CompetitiveLeaderboardRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<CompetitiveLeaderboardEntry>> watchTop(
    CompetitiveLeaderboardType type, {
    int limit = 100,
  }) {
    final board = type == CompetitiveLeaderboardType.rp ? 'rp' : 'gold';
    return _firestore
        .collection('competitiveLeaderboards')
        .doc(board)
        .collection('entries')
        .orderBy('value', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CompetitiveLeaderboardEntry.fromMap(doc.id, doc.data()))
            .toList(growable: false));
  }
}

class CompetitiveLeaderboardEntry {
  const CompetitiveLeaderboardEntry({
    required this.uid,
    required this.displayName,
    required this.avatarId,
    required this.value,
  });

  factory CompetitiveLeaderboardEntry.fromMap(String uid, Map<String, dynamic> data) {
    return CompetitiveLeaderboardEntry(
      uid: uid,
      displayName: data['displayName'] as String? ?? 'Player',
      avatarId: data['avatarId'] as String? ?? 'default_01',
      value: (data['value'] as num?)?.toInt() ?? 0,
    );
  }

  final String uid;
  final String displayName;
  final String avatarId;
  final int value;
}
