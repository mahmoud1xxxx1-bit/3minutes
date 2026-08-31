import 'package:flutter/material.dart';

import '../../domain/mini_game_contract.dart';
import 'path_rush_game.dart';

/// Competitive adapter for Path Rush.
///
/// The legacy visual game always reported `completed: true` after its three
/// questions. In Ranked, the objective is stricter: the player must win all
/// three rounds. Wrong answers remain diagnostics and never become partial
/// match points.
class PathRushCompetitiveGame extends StatelessWidget {
  const PathRushCompetitiveGame({
    super.key,
    required this.config,
    required this.onComplete,
  });

  final MiniGameConfig config;
  final ValueChanged<MiniGameResult> onComplete;

  @override
  Widget build(BuildContext context) {
    return PathRushGame(
      config: config,
      onComplete: (raw) {
        final clearedAllRounds = raw.accuracy >= 1.0;
        final correctRounds = (raw.accuracy * 3).round().clamp(0, 3);
        onComplete(
          MiniGameResult(
            completed: clearedAllRounds,
            score: clearedAllRounds ? 1000 : 0,
            accuracy: raw.accuracy,
            mistakes: raw.mistakes,
            duration: raw.duration,
            progressStep: correctRounds,
            progressStepCount: 3,
          ),
        );
      },
    );
  }
}
