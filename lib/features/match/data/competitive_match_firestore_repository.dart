import 'package:cloud_firestore/cloud_firestore.dart';

class CompetitiveMatchFirestoreRepository {
  CompetitiveMatchFirestoreRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<CompetitiveQueueTicket?> watchQueueTicket(String uid) {
    return _firestore.collection('competitiveQueue').doc(uid).snapshots().map((snapshot) {
      final data = snapshot.data();
      if (!snapshot.exists || data == null) return null;
      return CompetitiveQueueTicket(
        uid: uid,
        wager: (data['wager'] as num?)?.toInt() ?? 0,
        status: data['status'] as String? ?? 'searching',
        matchId: data['matchId'] as String?,
      );
    });
  }

  Stream<CompetitiveMatchSnapshot?> watchMatch(String matchId) {
    return _firestore.collection('competitiveMatches').doc(matchId).snapshots().map((snapshot) {
      final data = snapshot.data();
      if (!snapshot.exists || data == null) return null;
      return CompetitiveMatchSnapshot.fromMap(matchId, data);
    });
  }
}

class CompetitiveQueueTicket {
  const CompetitiveQueueTicket({
    required this.uid,
    required this.wager,
    required this.status,
    required this.matchId,
  });

  final String uid;
  final int wager;
  final String status;
  final String? matchId;

  bool get matched => status == 'matched' && matchId != null;
}

class CompetitiveMatchSnapshot {
  const CompetitiveMatchSnapshot({
    required this.id,
    required this.playerAId,
    required this.playerAName,
    required this.playerAAvatarId,
    required this.playerBId,
    required this.playerBName,
    required this.playerBAvatarId,
    required this.wager,
    required this.pot,
    required this.status,
    required this.playerASelectedGames,
    required this.playerBSelectedGames,
    required this.readyA,
    required this.readyB,
    required this.gameOrder,
    required this.startsAt,
    required this.deadline,
  });

  factory CompetitiveMatchSnapshot.fromMap(String id, Map<String, dynamic> data) {
    DateTime? readTime(Object? value) => value is Timestamp ? value.toDate() : null;
    List<String> readIds(Object? value) =>
        value is List ? value.whereType<String>().toList(growable: false) : const <String>[];

    return CompetitiveMatchSnapshot(
      id: id,
      playerAId: data['playerAId'] as String? ?? '',
      playerAName: data['playerAName'] as String? ?? 'Player',
      playerAAvatarId: data['playerAAvatarId'] as String? ?? 'default_01',
      playerBId: data['playerBId'] as String? ?? '',
      playerBName: data['playerBName'] as String? ?? 'Player',
      playerBAvatarId: data['playerBAvatarId'] as String? ?? 'default_01',
      wager: (data['wager'] as num?)?.toInt() ?? 0,
      pot: (data['pot'] as num?)?.toInt() ?? 0,
      status: data['status'] as String? ?? 'selectingGames',
      playerASelectedGames: readIds(data['playerASelectedGames']),
      playerBSelectedGames: readIds(data['playerBSelectedGames']),
      readyA: data['readyA'] as bool? ?? false,
      readyB: data['readyB'] as bool? ?? false,
      gameOrder: readIds(data['gameOrder']),
      startsAt: readTime(data['startsAt']),
      deadline: readTime(data['deadline']),
    );
  }

  final String id;
  final String playerAId;
  final String playerAName;
  final String playerAAvatarId;
  final String playerBId;
  final String playerBName;
  final String playerBAvatarId;
  final int wager;
  final int pot;
  final String status;
  final List<String> playerASelectedGames;
  final List<String> playerBSelectedGames;
  final bool readyA;
  final bool readyB;
  final List<String> gameOrder;
  final DateTime? startsAt;
  final DateTime? deadline;

  bool isPlayerA(String uid) => uid == playerAId;
  String opponentNameFor(String uid) => isPlayerA(uid) ? playerBName : playerAName;
  List<String> myPicks(String uid) => isPlayerA(uid) ? playerASelectedGames : playerBSelectedGames;
  List<String> opponentPicks(String uid) => isPlayerA(uid) ? playerBSelectedGames : playerASelectedGames;
  bool myReady(String uid) => isPlayerA(uid) ? readyA : readyB;
  bool opponentReady(String uid) => isPlayerA(uid) ? readyB : readyA;
}
