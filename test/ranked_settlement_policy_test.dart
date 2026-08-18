import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/competition/domain/rank_tier.dart';
import 'package:game/features/competition/domain/ranked_reward_policy.dart';
import 'package:game/features/competition/domain/ranked_settlement_policy.dart';
import 'package:game/features/progression/domain/player_progression.dart';

void main() {
  test('win settlement updates rp tier xp and coins together', () {
    final preview = RankedSettlementPolicy.previewPlayer(
      uid: 'p1',
      result: RankedResult.win,
      currentRp: 490,
      currentProgression: const PlayerProgression(level: 1, xp: 90),
      currentCoins: 100,
    );

    expect(preview.player.previousRp, 490);
    expect(preview.player.nextRp, 520);
    expect(preview.player.previousTier, RankTier.bronze);
    expect(preview.player.nextTier, RankTier.silver);
    expect(preview.progression.level, 2);
    expect(preview.progression.xp, 110);
    expect(preview.coins, 130);
  });

  test('loss settlement clamps rp at zero', () {
    final preview = RankedSettlementPolicy.previewPlayer(
      uid: 'p2',
      result: RankedResult.loss,
      currentRp: 5,
      currentProgression: const PlayerProgression(level: 1, xp: 0),
      currentCoins: 0,
    );

    expect(preview.player.nextRp, 0);
    expect(preview.player.rpDelta, -5);
    expect(preview.coins, greaterThanOrEqualTo(0));
  });
}
