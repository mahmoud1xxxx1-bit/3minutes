import 'package:flutter_test/flutter_test.dart';

import '../lib/features/minigames/presentation/level_devil/troll_engine.dart';
import '../lib/features/minigames/presentation/level_devil/troll_stage_plan.dart';

void main() {
  test('Season 6 follows the canonical 20-old + 5-new structure', () {
    for (int stageId = 101; stageId <= 175; stageId++) {
      final plan = TrollStagePlan.fromStageId(stageId);
      final engine = TrollEngine(
        round: plan.localStage,
        maxRounds: 1,
        levelsPerMechanic: plan.levelsPerMechanic,
        mechanicOffset: plan.mechanicOffset,
      );

      expect(plan.season, 6);
      expect(plan.levelsPerMechanic, 3);
      expect(plan.difficulty, inInclusiveRange(1, 3));
      expect(engine.player.rect.w, greaterThan(0));
      expect(engine.player.rect.h, greaterThan(0));
      expect(engine.entities, isNotEmpty);

      final expectedMechanic = ((stageId - 101) ~/ 3) + 1;
      expect(plan.mechanicId, expectedMechanic);
    }

    expect(
      TrollStagePlan.fromStageId(101).mechanicId,
      1,
    );
    expect(
      TrollStagePlan.fromStageId(160).mechanicId,
      20,
    );
    expect(
      TrollStagePlan.fromStageId(161).mechanicId,
      21,
    );
    expect(
      TrollStagePlan.fromStageId(175).mechanicId,
      25,
    );
  });

  test('Each Season 6 mechanic has Easy, Medium, Hard in order', () {
    for (int group = 0; group < 25; group++) {
      final base = 101 + group * 3;
      expect(TrollStagePlan.fromStageId(base).difficulty, 1);
      expect(TrollStagePlan.fromStageId(base + 1).difficulty, 2);
      expect(TrollStagePlan.fromStageId(base + 2).difficulty, 3);
    }
  });
}
