import '../domain/achievement.dart';
import '../domain/mission.dart';

enum SeasonPassClaimTrack { free, premium }

class PlayerSeasonPassState {
  const PlayerSeasonPassState({
    required this.seasonXp,
    required this.premiumUnlocked,
    required this.claimedFreeLevels,
    required this.claimedPremiumLevels,
  });

  final int seasonXp;
  final bool premiumUnlocked;
  final Set<int> claimedFreeLevels;
  final Set<int> claimedPremiumLevels;
}

abstract class ProgressionBackend {
  Stream<Map<String, PlayerAchievement>> watchAchievements(String uid);

  Stream<Map<String, PlayerMissionState>> watchMissions(String uid);

  Stream<PlayerSeasonPassState> watchSeasonPass(String uid);

  Future<void> claimMissionReward(String missionId);

  Future<void> claimAchievementReward(String achievementId);

  Future<void> claimSeasonPassReward({
    required int level,
    required SeasonPassClaimTrack track,
  });
}
