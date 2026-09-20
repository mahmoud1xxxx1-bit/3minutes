import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/minigames/presentation/level_devil/troll_stage_plan.dart';

void main() {
  test('maps all 175 stages without changing stage numbering', () {
    for (var stage = 1; stage <= 175; stage++) {
      final plan = TrollStagePlan.fromStageId(stage);
      expect(plan.stageId, stage);
    }
  });

  test('seasons 1-5 keep 20 stages and 2E/2M/1H', () {
    for (var season = 1; season <= 5; season++) {
      final start = ((season - 1) * 20) + 1;
      for (var local = 1; local <= 20; local++) {
        final plan = TrollStagePlan.fromStageId(start + local - 1);
        expect(plan.season, season);
        expect(plan.localStage, local);
        expect(plan.levelsPerMechanic, 5);
        final localMechanicStage = ((local - 1) % 5) + 1;
        expect(plan.difficulty,
            localMechanicStage <= 2 ? 1 : localMechanicStage <= 4 ? 2 : 3);
      }
    }
  });

  test('season 6 keeps 75 stages and 1E/1M/1H per mechanic', () {
    for (var local = 1; local <= 75; local++) {
      final plan = TrollStagePlan.fromStageId(100 + local);
      expect(plan.season, 6);
      expect(plan.localStage, local);
      expect(plan.levelsPerMechanic, 3);
      expect(plan.difficulty, ((local - 1) % 3) + 1);
      expect(plan.mechanicId, ((local - 1) ~/ 3) + 21);
    }
  });
}
