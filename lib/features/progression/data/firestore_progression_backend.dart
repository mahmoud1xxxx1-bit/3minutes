import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firebase/server_collections.dart';
import '../domain/achievement.dart';
import '../domain/mission.dart';
import 'progression_backend.dart';

class FirestoreProgressionBackend implements ProgressionBackend {
  FirestoreProgressionBackend({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Stream<Map<String, PlayerAchievement>> watchAchievements(String uid) {
    return _firestore
        .collection(ServerCollections.playerAchievements)
        .doc(uid)
        .snapshots()
        .map((doc) {
      final data = doc.data() ?? const <String, dynamic>{};
      final raw = data['states'];
      if (raw is! Map<String, dynamic>) return const <String, PlayerAchievement>{};
      final result = <String, PlayerAchievement>{};
      for (final entry in raw.entries) {
        final value = entry.value;
        if (value is! Map<String, dynamic>) continue;
        result[entry.key] = PlayerAchievement(
          achievementId: entry.key,
          progress: (value['progress'] as num?)?.toInt() ?? 0,
          completed: value['completed'] == true,
          completedAt: (value['completedAt'] as Timestamp?)?.toDate(),
          rewardClaimedAt: (value['rewardClaimedAt'] as Timestamp?)?.toDate(),
        );
      }
      return Map.unmodifiable(result);
    });
  }

  @override
  Stream<Map<String, PlayerMissionState>> watchMissions(String uid) {
    return _firestore
        .collection(ServerCollections.playerMissions)
        .doc(uid)
        .snapshots()
        .map((doc) {
      final data = doc.data() ?? const <String, dynamic>{};
      final raw = data['states'];
      if (raw is! Map<String, dynamic>) return const <String, PlayerMissionState>{};
      final result = <String, PlayerMissionState>{};
      for (final entry in raw.entries) {
        final value = entry.value;
        if (value is! Map<String, dynamic>) continue;
        result[entry.key] = PlayerMissionState(
          missionId: entry.key,
          windowId: (value['windowId'] as String?) ?? '',
          progress: (value['progress'] as num?)?.toInt() ?? 0,
          completed: value['completed'] == true,
          claimedAt: (value['claimedAt'] as Timestamp?)?.toDate(),
        );
      }
      return Map.unmodifiable(result);
    });
  }

  @override
  Stream<PlayerSeasonPassState> watchSeasonPass(String uid) {
    return _firestore
        .collection(ServerCollections.seasonPass)
        .doc(uid)
        .snapshots()
        .map((doc) {
      final data = doc.data() ?? const <String, dynamic>{};
      return PlayerSeasonPassState(
        seasonXp: (data['seasonXp'] as num?)?.toInt() ?? 0,
        premiumUnlocked: data['premiumUnlocked'] == true,
        claimedFreeLevels: _intSet(data['claimedFreeLevels']),
        claimedPremiumLevels: _intSet(data['claimedPremiumLevels']),
      );
    });
  }

  Set<int> _intSet(Object? value) {
    if (value is! List) return const <int>{};
    return Set<int>.unmodifiable(value.whereType<num>().map((item) => item.toInt()));
  }
}
