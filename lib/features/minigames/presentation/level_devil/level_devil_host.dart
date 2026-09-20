import 'package:flutter/material.dart';
import '../../domain/mini_game_contract.dart';
import 'troll_game.dart';
import 'troll_stage_plan.dart';

class LevelDevilHost extends StatefulWidget {
  const LevelDevilHost({
    super.key,
    required this.config,
    required this.onComplete,
  });

  final MiniGameConfig config;
  final ValueChanged<MiniGameResult> onComplete;

  @override
  State<LevelDevilHost> createState() => _LevelDevilHostState();
}

class _LevelDevilHostState extends State<LevelDevilHost> {
  late DateTime _startTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    // The config seed is the existing global stage number. Keep the stage
    // identity exactly as defined by the game design: 1..175.
    final stageId = widget.config.seed.clamp(1, TrollStagePlan.totalStages);
    final plan = TrollStagePlan.fromStageId(stageId);

    return TrollGame(
      startRound: plan.localStage,
      maxRounds: 1, // Single stage in host mode
      levelsPerMechanic: plan.levelsPerMechanic,
      mechanicOffset: plan.mechanicOffset,
      onWin: (int score) {
        final duration = DateTime.now().difference(_startTime);
        widget.onComplete(
          MiniGameResult(
            completed: true,
            score: score,
            accuracy: 1.0,
            mistakes: 0,
            duration: duration,
          ),
        );
      },
      onFail: () {
        final duration = DateTime.now().difference(_startTime);
        widget.onComplete(
          MiniGameResult(
            completed: false,
            score: 0,
            accuracy: 0.0,
            mistakes: 1,
            duration: duration,
          ),
        );
      },
    );
  }
}
