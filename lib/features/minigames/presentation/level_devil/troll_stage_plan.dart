/// Immutable mapping for the game's 175-stage architecture.
///
/// This class only maps an existing global stage number to its structural
/// metadata. It does not create, rename, reorder, or renumber stages.
class TrollStagePlan {
  static const int totalStages = 175;
  static const int mainSeasonCount = 5;
  static const int mainSeasonStages = 20;
  static const int season6Stages = 75;

  final int stageId;
  final int season;
  final int localStage;
  final int levelsPerMechanic;
  final int mechanicOffset;
  final int mechanicId;
  final int difficulty;

  const TrollStagePlan._({
    required this.stageId,
    required this.season,
    required this.localStage,
    required this.levelsPerMechanic,
    required this.mechanicOffset,
    required this.mechanicId,
    required this.difficulty,
  });

  factory TrollStagePlan.fromStageId(int stageId) {
    if (stageId < 1 || stageId > totalStages) {
      throw ArgumentError.value(stageId, 'stageId', 'Must be between 1 and 175.');
    }

    if (stageId <= 100) {
      final season = ((stageId - 1) ~/ mainSeasonStages) + 1;
      final localStage = ((stageId - 1) % mainSeasonStages) + 1;
      final mechanicOffset = (season - 1) * 4;
      final mechanicId = ((localStage - 1) ~/ 5) + 1 + mechanicOffset;
      final localMechanicStage = ((localStage - 1) % 5) + 1;
      final difficulty =
          localMechanicStage <= 2 ? 1 : localMechanicStage <= 4 ? 2 : 3;

      return TrollStagePlan._(
        stageId: stageId,
        season: season,
        localStage: localStage,
        levelsPerMechanic: 5,
        mechanicOffset: mechanicOffset,
        mechanicId: mechanicId,
        difficulty: difficulty,
      );
    }

    // Season 6 is structurally 25 mechanics × 3 stages = 75 stages.
    final localStage = stageId - 100;
    final mechanicId = ((localStage - 1) ~/ 3) + 21;
    final difficulty = ((localStage - 1) % 3) + 1;

    return TrollStagePlan._(
      stageId: stageId,
      season: 6,
      localStage: localStage,
      levelsPerMechanic: 3,
      mechanicOffset: 20,
      mechanicId: mechanicId,
      difficulty: difficulty,
    );
  }
}
