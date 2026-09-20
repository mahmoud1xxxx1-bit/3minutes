import '../../match/domain/match_outcome.dart';
import 'ranked_reward_policy.dart';

class RankedResultResolver {
  const RankedResultResolver._();

  static RankedResult forPlayerA(MatchOutcome outcome) {
    return switch (outcome) {
      MatchOutcome.playerA => RankedResult.win,
      MatchOutcome.playerB => RankedResult.loss,
      MatchOutcome.tie => RankedResult.tie,
    };
  }

  static RankedResult forPlayerB(MatchOutcome outcome) {
    return switch (outcome) {
      MatchOutcome.playerA => RankedResult.loss,
      MatchOutcome.playerB => RankedResult.win,
      MatchOutcome.tie => RankedResult.tie,
    };
  }
}
