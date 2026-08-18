import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/config/app_config.dart';
import '../../minigames/data/game_registry.dart';
import '../../profile/domain/player_profile.dart';
import '../domain/match_progress.dart';
import '../domain/match_session.dart';
import '../domain/match_ticket.dart';
import 'match_backend.dart';

class FirestoreMatchBackend implements MatchBackend {
  FirestoreMatchBackend({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _queue =>
      _firestore.collection('matchmaking');

  CollectionReference<Map<String, dynamic>> get _matches =>
      _firestore.collection('matches');

  Map<String, dynamic> get _emptyProgress => {
        'completedGames': 0,
        'totalScore': 0,
        'accuracyTotal': 0.0,
        'mistakes': 0,
        'elapsedMs': 0,
        'completedAt': null,
      };

  Map<String, dynamic> _newMatchData({
    required String playerAId,
    required String playerAName,
    required String playerAAvatarId,
    required String playerBId,
    required String playerBName,
    required String playerBAvatarId,
  }) {
    return {
      'playerAId': playerAId,
      'playerAName': playerAName,
      'playerAAvatarId': playerAAvatarId,
      'playerBId': playerBId,
      'playerBName': playerBName,
      'playerBAvatarId': playerBAvatarId,
      'seed': Random.secure().nextInt(0x7fffffff),
      'gameCount': AppConfig.gamesPerMatch,
      'registryVersion': GameRegistry.version,
      'status': MatchStatus.waitingReady.name,
      'readyA': false,
      'readyB': false,
      'progressA': _emptyProgress,
      'progressB': _emptyProgress,
      'rematchA': false,
      'rematchB': false,
      'rematchMatchId': null,
      'cancelledBy': null,
      'countdownStartedAt': null,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  @override
  Future<void> joinQueue(PlayerProfile profile) async {
    final ownRef = _queue.doc(profile.uid);
    final existing = await ownRef.get();
    if (existing.exists) {
      await ownRef.delete();
    }

    await ownRef.set({
      'uid': profile.uid,
      'gameName': profile.gameName,
      'avatarId': profile.avatarId,
      'status': MatchTicketStatus.waiting.name,
      'matchId': null,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final candidates = await _queue
        .where('status', isEqualTo: MatchTicketStatus.waiting.name)
        .limit(20)
        .get();

    for (final candidate in candidates.docs) {
      if (candidate.id == profile.uid) continue;

      final matchRef = _matches.doc();

      try {
        await _firestore.runTransaction((transaction) async {
          final ownSnapshot = await transaction.get(ownRef);
          final candidateSnapshot = await transaction.get(candidate.reference);
          final ownData = ownSnapshot.data();
          final candidateData = candidateSnapshot.data();

          if (ownData == null || candidateData == null) {
            throw StateError('Queue ticket disappeared.');
          }
          if (ownData['status'] != MatchTicketStatus.waiting.name ||
              candidateData['status'] != MatchTicketStatus.waiting.name) {
            throw StateError('Queue ticket already claimed.');
          }

          final candidateUid = candidateData['uid'] as String? ?? candidate.id;
          if (candidateUid == profile.uid) {
            throw StateError('Cannot match a player with themselves.');
          }

          transaction.set(
            matchRef,
            _newMatchData(
              playerAId: candidateUid,
              playerAName: candidateData['gameName'] as String? ?? 'Player',
              playerAAvatarId:
                  candidateData['avatarId'] as String? ?? 'default_01',
              playerBId: profile.uid,
              playerBName: profile.gameName,
              playerBAvatarId: profile.avatarId,
            ),
          );

          transaction.update(ownRef, {
            'status': MatchTicketStatus.matched.name,
            'matchId': matchRef.id,
            'updatedAt': FieldValue.serverTimestamp(),
          });
          transaction.update(candidate.reference, {
            'status': MatchTicketStatus.matched.name,
            'matchId': matchRef.id,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        });
        return;
      } catch (_) {
        // Another player may have claimed this ticket first. Try the next one.
      }
    }
  }

  @override
  Future<void> leaveQueue(String uid) async {
    final ref = _queue.doc(uid);
    final snapshot = await ref.get();
    if (!snapshot.exists) return;
    if (snapshot.data()?['status'] == MatchTicketStatus.waiting.name) {
      await ref.delete();
    }
  }

  @override
  Future<void> clearTicket(String uid) => _queue.doc(uid).delete();

  @override
  Future<void> moveTicketToMatch({
    required String uid,
    required String matchId,
  }) async {
    final ref = _queue.doc(uid);
    final snapshot = await ref.get();
    if (!snapshot.exists) return;
    await ref.update({
      'status': MatchTicketStatus.matched.name,
      'matchId': matchId,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Stream<MatchTicket?> watchTicket(String uid) {
    return _queue.doc(uid).snapshots().map((snapshot) {
      final data = snapshot.data();
      if (!snapshot.exists || data == null) return null;
      return MatchTicket(
        uid: uid,
        status: MatchTicketStatus.fromWire(
          data['status'] as String? ?? MatchTicketStatus.waiting.name,
        ),
        matchId: data['matchId'] as String?,
      );
    });
  }

  MatchSession _sessionFromDoc(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? const <String, dynamic>{};
    final countdownTimestamp = data['countdownStartedAt'];
    final createdTimestamp = data['createdAt'];
    return MatchSession(
      id: snapshot.id,
      playerAId: data['playerAId'] as String? ?? '',
      playerAName: data['playerAName'] as String? ?? 'Player',
      playerAAvatarId: data['playerAAvatarId'] as String? ?? 'default_01',
      playerBId: data['playerBId'] as String? ?? '',
      playerBName: data['playerBName'] as String? ?? 'Player',
      playerBAvatarId: data['playerBAvatarId'] as String? ?? 'default_01',
      seed: (data['seed'] as num?)?.toInt() ?? 0,
      gameCount:
          (data['gameCount'] as num?)?.toInt() ?? AppConfig.gamesPerMatch,
      registryVersion:
          (data['registryVersion'] as num?)?.toInt() ?? GameRegistry.version,
      status: MatchStatus.fromWire(
        data['status'] as String? ?? MatchStatus.waitingReady.name,
      ),
      readyA: data['readyA'] as bool? ?? false,
      readyB: data['readyB'] as bool? ?? false,
      progressA: _progressFrom(data['progressA']),
      progressB: _progressFrom(data['progressB']),
      rematchA: data['rematchA'] as bool? ?? false,
      rematchB: data['rematchB'] as bool? ?? false,
      rematchMatchId: data['rematchMatchId'] as String?,
      cancelledBy: data['cancelledBy'] as String?,
      countdownStartedAt: countdownTimestamp is Timestamp
          ? countdownTimestamp.toDate()
          : null,
      createdAt: createdTimestamp is Timestamp ? createdTimestamp.toDate() : null,
    );
  }

  @override
  Stream<MatchSession?> watchMatch(String matchId) {
    return _matches.doc(matchId).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return _sessionFromDoc(snapshot);
    });
  }

  @override
  Future<List<MatchSession>> loadHistory(String uid) async {
    final asA = await _matches.where('playerAId', isEqualTo: uid).limit(20).get();
    final asB = await _matches.where('playerBId', isEqualTo: uid).limit(20).get();
    final byId = <String, MatchSession>{};
    for (final doc in [...asA.docs, ...asB.docs]) {
      byId[doc.id] = _sessionFromDoc(doc);
    }
    final items = byId.values.toList()
      ..sort((a, b) {
        final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      });
    return items.take(20).toList(growable: false);
  }

  MatchProgress _progressFrom(dynamic value) {
    final map = value is Map<String, dynamic> ? value : <String, dynamic>{};
    final completedTimestamp = map['completedAt'];
    return MatchProgress(
      completedGames: (map['completedGames'] as num?)?.toInt() ?? 0,
      totalScore: (map['totalScore'] as num?)?.toInt() ?? 0,
      accuracyTotal: (map['accuracyTotal'] as num?)?.toDouble() ?? 0,
      mistakes: (map['mistakes'] as num?)?.toInt() ?? 0,
      elapsedMs: (map['elapsedMs'] as num?)?.toInt() ?? 0,
      completedAt: completedTimestamp is Timestamp
          ? completedTimestamp.toDate()
          : null,
    );
  }

  @override
  Future<void> markReady({
    required String matchId,
    required String uid,
  }) async {
    final ref = _matches.doc(matchId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);
      final data = snapshot.data();
      if (data == null) throw StateError('Match not found.');

      final playerAId = data['playerAId'] as String?;
      final playerBId = data['playerBId'] as String?;
      if (uid != playerAId && uid != playerBId) {
        throw StateError('Player is not part of this match.');
      }
      final status = MatchStatus.fromWire(
        data['status'] as String? ?? MatchStatus.waitingReady.name,
      );
      if (status != MatchStatus.waitingReady) return;

      var readyA = data['readyA'] as bool? ?? false;
      var readyB = data['readyB'] as bool? ?? false;
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (uid == playerAId) {
        readyA = true;
        updates['readyA'] = true;
      } else {
        readyB = true;
        updates['readyB'] = true;
      }
      if (readyA && readyB) {
        updates['status'] = MatchStatus.countdown.name;
        updates['countdownStartedAt'] = FieldValue.serverTimestamp();
      }
      transaction.update(ref, updates);
    });
  }

  @override
  Future<void> cancelMatch({
    required String matchId,
    required String uid,
  }) async {
    final ref = _matches.doc(matchId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);
      final data = snapshot.data();
      if (data == null) return;
      if (uid != data['playerAId'] && uid != data['playerBId']) {
        throw StateError('Player is not part of this match.');
      }
      if (data['status'] != MatchStatus.waitingReady.name) return;
      transaction.update(ref, {
        'status': MatchStatus.cancelled.name,
        'cancelledBy': uid,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Future<void> finalizeMatch({
    required String matchId,
    required String uid,
  }) async {
    final ref = _matches.doc(matchId);
    final snapshot = await ref.get();
    final data = snapshot.data();
    if (data == null) return;
    if (uid != data['playerAId'] && uid != data['playerBId']) {
      throw StateError('Player is not part of this match.');
    }
    if (data['status'] == MatchStatus.cancelled.name ||
        data['status'] == MatchStatus.finished.name) {
      return;
    }
    await ref.update({
      'status': MatchStatus.finished.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> requestRematch({
    required String matchId,
    required String uid,
  }) async {
    final ref = _matches.doc(matchId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);
      final data = snapshot.data();
      if (data == null) throw StateError('Match not found.');

      final playerAId = data['playerAId'] as String? ?? '';
      final playerBId = data['playerBId'] as String? ?? '';
      if (uid != playerAId && uid != playerBId) {
        throw StateError('Player is not part of this match.');
      }
      if (data['status'] == MatchStatus.cancelled.name) return;
      if (data['rematchMatchId'] is String) return;

      var rematchA = data['rematchA'] as bool? ?? false;
      var rematchB = data['rematchB'] as bool? ?? false;
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (uid == playerAId) {
        rematchA = true;
        updates['rematchA'] = true;
      } else {
        rematchB = true;
        updates['rematchB'] = true;
      }

      if (rematchA && rematchB) {
        final newMatchRef = _matches.doc();
        transaction.set(
          newMatchRef,
          _newMatchData(
            playerAId: playerAId,
            playerAName: data['playerAName'] as String? ?? 'Player',
            playerAAvatarId:
                data['playerAAvatarId'] as String? ?? 'default_01',
            playerBId: playerBId,
            playerBName: data['playerBName'] as String? ?? 'Player',
            playerBAvatarId:
                data['playerBAvatarId'] as String? ?? 'default_01',
          ),
        );
        updates['rematchMatchId'] = newMatchRef.id;
      }
      transaction.update(ref, updates);
    });
  }

  @override
  Future<void> submitProgress({
    required String matchId,
    required String uid,
    required MatchProgress progress,
    required int gameCount,
  }) async {
    final ref = _matches.doc(matchId);
    final snapshot = await ref.get();
    final data = snapshot.data();
    if (data == null) throw StateError('Match not found.');

    final playerAId = data['playerAId'] as String?;
    final playerBId = data['playerBId'] as String?;
    if (uid != playerAId && uid != playerBId) {
      throw StateError('Player is not part of this match.');
    }
    final field = uid == playerAId ? 'progressA' : 'progressB';
    await ref.update({
      field: {
        'completedGames': progress.completedGames,
        'totalScore': progress.totalScore,
        'accuracyTotal': progress.accuracyTotal,
        'mistakes': progress.mistakes,
        'elapsedMs': progress.elapsedMs,
        'completedAt': progress.completedGames >= gameCount
            ? FieldValue.serverTimestamp()
            : null,
      },
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
