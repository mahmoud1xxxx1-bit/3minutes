import '../domain/achievement.dart';
import '../domain/mission.dart';

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
}
