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
    // We have 20 chapters. Pick one based on the seed.
    // Each chapter has 3 rounds. We want to skip round 1 and play rounds 2 and 3.
    final chapter = (widget.config.seed % 20) + 1;
    final startRound = ((chapter - 1) * 3) + 2;

    return TrollGame(
      startRound: startRound,
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
    );
  }
}
