import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../../core/config/app_config.dart';
import '../../../core/firebase/server_collections.dart';
import '../../competition/domain/match_integrity_policy.dart';
import '../../minigames/data/game_registry.dart';
import '../domain/match_progress.dart';
import '../domain/multiplayer_match.dart';
import 'social_match_backend.dart';

class FirestoreSocialMatchBackend implements SocialMatchBackend {
  FirestoreSocialMatchBackend({
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _functions = functions ?? FirebaseFunctions.instanceFor(region: 'me-central2');

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  CollectionReference<Map<String, dynamic>> get _matches =>
      _firestore.collection(ServerCollections.socialMatches);

  @override
  Stream<MultiplayerMatch?> watchMatch(String matchId) {
    return _matches.doc(matchId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return _fromDoc(doc);
    });
  }

  @override
  Future<MultiplayerMatch> createMatch({
    required String roomId,
    required String roomCode,
    required String hostUid,
    required int maxPlayers,
    required List<MatchParticipant> participants,
  }) async {
    if (!MultiplayerMatchPolicy.supportedPlayerCounts.contains(maxPlayers)) {
      throw ArgumentError('Only 2, 4, or 6 player matches are supported.');
    }
    if (participants.length != maxPlayers) {
      throw StateError('A social match can start only when the room is full.');
    }
    if (participants.map((p) => p.uid).toSet().length != participants.length) {
      throw StateError('Duplicate participants are not allowed.');
    }
    if (!participants.any((p) => p.uid == hostUid)) {
      throw StateError('Host must be a match participant.');
    }

    final ref = _matches.doc(roomId);
    final now = DateTime.now().toUtc();
    final seed = Random.secure().nextInt(0x7fffffff);

    final result = await _firestore.runTransaction<MultiplayerMatch>((tx) async {
      final existing = await tx.get(ref);
      if (existing.exists) return _fromDoc(existing);

      final normalizedParticipants = participants
          .map(
            (p) => MatchParticipant(
              uid: p.uid,
              displayName: p.displayName,
              avatarId: p.avatarId,
              isReady: true,
              progress: const MatchProgress.empty(),
            ),
          )
          .toList(growable: false);

      final match = MultiplayerMatch(
        id: roomId,
        mode: MatchMode.privateRoom,
        hostUid: hostUid,
        maxPlayers: maxPlayers,
        seed: seed,
        registryVersion: GameRegistry.version,
        participants: normalizedParticipants,
        roomCode: roomCode,
        countdownStartedAt: now,
      );
      MultiplayerMatchPolicy.validate(match);

      tx.set(ref, {
        'mode': MatchMode.privateRoom.name,
        'hostUid': hostUid,
        'maxPlayers': maxPlayers,
        'seed': seed,
        'registryVersion': GameRegistry.version,
        'gameCount': AppConfig.gamesPerMatch,
        'roomCode': roomCode,
        'participantOrder': normalizedParticipants.map((p) => p.uid).toList(),
        'participants': {
          for (final p in normalizedParticipants) p.uid: _participantToMap(p),
        },
        'countdownStartedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      return match;
    });

    return result;
  }

  @override
  Future<void> submitProgress({
    required String matchId,
    required String uid,
    required MatchProgress progress,
  }) async {
    final report = MatchIntegrityPolicy.validateProgress(
      progress: progress,
      gameCount: AppConfig.gamesPerMatch,
    );
    if (!report.valid) {
      throw StateError('Invalid social match progress: ${report.reasons.join(',')}');
    }

    final ref = _matches.doc(matchId);
    await _firestore.runTransaction((tx) async {
      final doc = await tx.get(ref);
      if (!doc.exists) throw StateError('Social match not found.');
      final data = doc.data()!;
      final participants = Map<String, dynamic>.from(
        data['participants'] as Map<String, dynamic>? ?? const {},
      );
      final raw = participants[uid];
      if (raw is! Map) throw StateError('Player is not a match participant.');
      final participant = _participantFromMap(
        uid,
        Map<String, dynamic>.from(raw),
      );
      final current = participant.progress;
      if (progress.completedGames < current.completedGames ||
          progress.totalScore < current.totalScore ||
          progress.elapsedMs < current.elapsedMs) {
        throw StateError('Social match progress cannot move backwards.');
      }

      participants[uid] = _participantToMap(
        MatchParticipant(
          uid: participant.uid,
          displayName: participant.displayName,
          avatarId: participant.avatarId,
          isReady: participant.isReady,
          connectionState: participant.connectionState,
          progress: progress,
          finishedAt: progress.completedGames >= AppConfig.gamesPerMatch
              ? (progress.completedAt ?? DateTime.now().toUtc())
              : participant.finishedAt,
        ),
      );
      tx.update(ref, {'participants': participants});
    });
  }

  @override
  Future<void> setConnectionState({
    required String matchId,
    required String uid,
    required ParticipantConnectionState state,
  }) async {
    final ref = _matches.doc(matchId);
    await _firestore.runTransaction((tx) async {
      final doc = await tx.get(ref);
      if (!doc.exists) return;
      final data = doc.data()!;
      final participants = Map<String, dynamic>.from(
        data['participants'] as Map<String, dynamic>? ?? const {},
      );
      final raw = participants[uid];
      if (raw is! Map) return;
      final participant = _participantFromMap(
        uid,
        Map<String, dynamic>.from(raw),
      );
      participants[uid] = _participantToMap(
        MatchParticipant(
          uid: participant.uid,
          displayName: participant.displayName,
          avatarId: participant.avatarId,
          isReady: participant.isReady,
          connectionState: state,
          progress: participant.progress,
          finishedAt: participant.finishedAt,
        ),
      );
      tx.update(ref, {'participants': participants});
    });
  }

  @override
  Future<void> settleMatch(String matchId) async {
    if (AppConfig.backendPhase != BackendPhase.blaze) return;
    await _functions.httpsCallable('settleSocialMatch').call<void>({
      'matchId': matchId,
    });
  }

  MultiplayerMatch _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    final participantMap = Map<String, dynamic>.from(
      data['participants'] as Map<String, dynamic>? ?? const {},
    );
    final order = (data['participantOrder'] as List<dynamic>?)
            ?.whereType<String>()
            .toList(growable: false) ??
        participantMap.keys.toList(growable: false);
    final participants = <MatchParticipant>[
      for (final uid in order)
        if (participantMap[uid] is Map)
          _participantFromMap(
            uid,
            Map<String, dynamic>.from(participantMap[uid] as Map),
          ),
    ];
    final modeName = data['mode'] as String?;
    return MultiplayerMatch(
      id: doc.id,
      mode: MatchMode.values.firstWhere(
        (value) => value.name == modeName,
        orElse: () => MatchMode.privateRoom,
      ),
      hostUid: (data['hostUid'] as String?) ?? '',
      maxPlayers: (data['maxPlayers'] as num?)?.toInt() ?? 2,
      seed: (data['seed'] as num?)?.toInt() ?? 0,
      registryVersion: (data['registryVersion'] as num?)?.toInt() ?? 0,
      participants: participants,
      roomCode: data['roomCode'] as String?,
      countdownStartedAt:
          (data['countdownStartedAt'] as Timestamp?)?.toDate(),
    );
  }

  static Map<String, dynamic> _participantToMap(MatchParticipant participant) {
    return {
      'displayName': participant.displayName,
      'avatarId': participant.avatarId,
      'isReady': participant.isReady,
      'connectionState': participant.connectionState.name,
      'progress': _progressToMap(participant.progress),
      'finishedAt': participant.finishedAt == null
          ? null
          : Timestamp.fromDate(participant.finishedAt!),
    };
  }

  static MatchParticipant _participantFromMap(
    String uid,
    Map<String, dynamic> data,
  ) {
    final connectionName = data['connectionState'] as String?;
    final progressData = data['progress'];
    return MatchParticipant(
      uid: uid,
      displayName: (data['displayName'] as String?) ?? 'Player',
      avatarId: data['avatarId'] as String?,
      isReady: data['isReady'] == true,
      connectionState: ParticipantConnectionState.values.firstWhere(
        (value) => value.name == connectionName,
        orElse: () => ParticipantConnectionState.connected,
      ),
      progress: progressData is Map
          ? _progressFromMap(Map<String, dynamic>.from(progressData))
          : const MatchProgress.empty(),
      finishedAt: (data['finishedAt'] as Timestamp?)?.toDate(),
    );
  }

  static Map<String, dynamic> _progressToMap(MatchProgress progress) {
    return {
      'completedGames': progress.completedGames,
      'totalScore': progress.totalScore,
      'accuracyTotal': progress.accuracyTotal,
      'mistakes': progress.mistakes,
      'elapsedMs': progress.elapsedMs,
      'completedAt': progress.completedAt == null
          ? null
          : Timestamp.fromDate(progress.completedAt!),
    };
  }

  static MatchProgress _progressFromMap(Map<String, dynamic> data) {
    return MatchProgress(
      completedGames: (data['completedGames'] as num?)?.toInt() ?? 0,
      totalScore: (data['totalScore'] as num?)?.toInt() ?? 0,
      accuracyTotal: (data['accuracyTotal'] as num?)?.toDouble() ?? 0,
      mistakes: (data['mistakes'] as num?)?.toInt() ?? 0,
      elapsedMs: (data['elapsedMs'] as num?)?.toInt() ?? 0,
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
    );
  }
}
