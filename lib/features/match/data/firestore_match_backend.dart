import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/config/app_config.dart';
import '../../minigames/data/game_registry.dart';
import '../../profile/domain/player_profile.dart';
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
      final seed = Random.secure().nextInt(0x7fffffff);

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

          transaction.set(matchRef, {
            'playerAId': candidateUid,
            'playerAName': candidateData['gameName'] as String? ?? 'Player',
            'playerAAvatarId':
                candidateData['avatarId'] as String? ?? 'default_01',
            'playerBId': profile.uid,
            'playerBName': profile.gameName,
            'playerBAvatarId': profile.avatarId,
            'seed': seed,
            'gameCount': AppConfig.gamesPerMatch,
            'registryVersion': GameRegistry.version,
            'status': MatchStatus.waitingReady.name,
            'readyA': false,
            'readyB': false,
            'countdownStartedAt': null,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

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

    final data = snapshot.data();
    if (data?['status'] == MatchTicketStatus.waiting.name) {
      await ref.delete();
    }
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

  @override
  Stream<MatchSession?> watchMatch(String matchId) {
    return _matches.doc(matchId).snapshots().map((snapshot) {
      final data = snapshot.data();
      if (!snapshot.exists || data == null) return null;

      final countdownTimestamp = data['countdownStartedAt'];
      return MatchSession(
        id: snapshot.id,
        playerAId: data['playerAId'] as String? ?? '',
        playerAName: data['playerAName'] as String? ?? 'Player',
        playerAAvatarId: data['playerAAvatarId'] as String? ?? 'default_01',
        playerBId: data['playerBId'] as String? ?? '',
        playerBName: data['playerBName'] as String? ?? 'Player',
        playerBAvatarId: data['playerBAvatarId'] as String? ?? 'default_01',
        seed: (data['seed'] as num?)?.toInt() ?? 0,
        gameCount: (data['gameCount'] as num?)?.toInt() ?? AppConfig.gamesPerMatch,
        registryVersion:
            (data['registryVersion'] as num?)?.toInt() ?? GameRegistry.version,
        status: MatchStatus.fromWire(
          data['status'] as String? ?? MatchStatus.waitingReady.name,
        ),
        readyA: data['readyA'] as bool? ?? false,
        readyB: data['readyB'] as bool? ?? false,
        countdownStartedAt: countdownTimestamp is Timestamp
            ? countdownTimestamp.toDate()
            : null,
      );
    });
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
}
