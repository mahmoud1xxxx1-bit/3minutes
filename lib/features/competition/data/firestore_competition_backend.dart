import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/leaderboard_entry.dart';
import '../domain/leaderboard_policy.dart';
import '../domain/season.dart';
import 'competition_backend.dart';

class FirestoreCompetitionBackend implements CompetitionBackend {
  FirestoreCompetitionBackend({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _seasons =>
      _firestore.collection('seasons');

  @override
  Stream<Season?> watchCurrentSeason() {
    return _seasons
        .where('active', isEqualTo: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return _seasonFromDoc(snapshot.docs.first);
    });
  }

  @override
  Future<List<LeaderboardEntry>> loadLeaderboard({int limit = 100}) async {
    final current = await _seasons.where('active', isEqualTo: true).limit(1).get();
    if (current.docs.isEmpty) return const [];

    final seasonId = current.docs.first.id;
    final safeLimit = limit.clamp(1, 100).toInt();
    final snapshot = await _firestore
        .collection('leaderboards')
        .doc(seasonId)
        .collection('entries')
        .orderBy('rankPoints', descending: true)
        .limit(safeLimit)
        .get();

    final entries = snapshot.docs.map(_leaderboardFromDoc);
    return LeaderboardPolicy.sorted(entries);
  }

  @override
  Stream<LeaderboardEntry?> watchPlayerCompetition(String uid) {
    return watchCurrentSeason().asyncExpand((season) {
      if (season == null) return Stream<LeaderboardEntry?>.value(null);

      return _firestore
          .collection('leaderboards')
          .doc(season.id)
          .collection('entries')
          .doc(uid)
          .snapshots()
          .map((snapshot) {
        if (!snapshot.exists) return null;
        return _leaderboardFromDoc(snapshot);
      });
    });
  }

  Season _seasonFromDoc(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? const <String, dynamic>{};
    final startsAt = data['startsAt'];
    final endsAt = data['endsAt'];

    return Season(
      id: snapshot.id,
      startsAt: startsAt is Timestamp
          ? startsAt.toDate()
          : DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      endsAt: endsAt is Timestamp
          ? endsAt.toDate()
          : DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      number: (data['number'] as num?)?.toInt() ?? 0,
    );
  }

  LeaderboardEntry _leaderboardFromDoc(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? const <String, dynamic>{};
    return LeaderboardEntry(
      uid: snapshot.id,
      gameName: data['gameName'] as String? ?? 'Player',
      avatarId: data['avatarId'] as String? ?? 'default_01',
      rankPoints: (data['rankPoints'] as num?)?.toInt() ?? 0,
      stars: (data['stars'] as num?)?.toInt() ?? 0,
      wins: (data['wins'] as num?)?.toInt() ?? 0,
      losses: (data['losses'] as num?)?.toInt() ?? 0,
    );
  }
}
