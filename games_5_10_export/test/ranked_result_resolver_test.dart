import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/competition/domain/ranked_result_resolver.dart';
import 'package:game/features/competition/domain/ranked_reward_policy.dart';
import 'package:game/features/match/domain/match_outcome.dart';

void main() {
  test('player A win maps to A win and B loss', () {
    expect(
      RankedResultResolver.forPlayerA(MatchOutcome.playerA),
      RankedResult.win,
    );
    expect(
      RankedResultResolver.forPlayerB(MatchOutcome.playerA),
      RankedResult.loss,
    );
  });

  test('tie maps to tie for both players', () {
    expect(
      RankedResultResolver.forPlayerA(MatchOutcome.tie),
      RankedResult.tie,
    );
    expect(
      RankedResultResolver.forPlayerB(MatchOutcome.tie),
      RankedResult.tie,
    );
  });
}
