import 'package:flutter/material.dart';
import '../../domain/mini_game_contract.dart';
import 'troll_game.dart';

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
    // Map seed 1-100 directly to Season and Mechanics (5 seasons x 20 stages)
    int stage = widget.config.seed;
    if (stage < 1) stage = 1;
    if (stage > 100) stage = ((stage - 1) % 100) + 1;

    final seasonIndex = (stage - 1) ~/ 20; // 0 to 4
    final mechanicOffset = seasonIndex * 4;
    final localRound = ((stage - 1) % 20) + 1; // 1 to 20

    return TrollGame(
      startRound: localRound,
      maxRounds: 1, // Single stage in host mode
      levelsPerMechanic: 5,
      mechanicOffset: mechanicOffset,
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
