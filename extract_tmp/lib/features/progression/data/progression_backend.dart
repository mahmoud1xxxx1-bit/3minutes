import '../domain/achievement.dart';
import '../domain/mission.dart';

enum SeasonPassClaimTrack { free, premium }

class PlayerSeasonPassState {
  const PlayerSeasonPassState({
    required this.seasonId,
    required this.seasonXp,
    required this.premiumUnlocked,
    required this.claimedFreeLevels,
    required this.claimedPremiumLevels,
  });

  final String seasonId;
  final int seasonXp;
  final bool premiumUnlocked;
  final Set<int> claimedFreeLevels;
  final Set<int> claimedPremiumLevels;
}

abstract class ProgressionBackend {
  Stream<Map<String, PlayerAchievement>> watchAchievements(String uid);

  Stream<Map<String, PlayerMissionState>> watchMissions(
    String uid, {
    required String seasonId,
  });

  Stream<PlayerSeasonPassState> watchSeasonPass(
    String uid, {
    required String seasonId,
  });

  Future<void> claimMissionReward({
    required String missionId,
    required String seasonId,
  });

  Future<void> claimAchievementReward(String achievementId);

  Future<void> claimSeasonPassReward({
    required String seasonId,
    required int level,
    required SeasonPassClaimTrack track,
  });
}
