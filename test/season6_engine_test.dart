import 'package:flutter_test/flutter_test.dart';

import '../lib/features/minigames/presentation/level_devil/troll_engine.dart';
import '../lib/features/minigames/presentation/level_devil/troll_stage_plan.dart';

void main() {
  test('Season 6 generates every one of its 75 stages', () {
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
      expect(plan.mechanicId, inInclusiveRange(21, 45));
      expect(plan.difficulty, inInclusiveRange(1, 3));
      expect(engine.player.rect.w, greaterThan(0));
      expect(engine.player.rect.h, greaterThan(0));
      expect(engine.entities, isNotEmpty);
    }
  });
}
