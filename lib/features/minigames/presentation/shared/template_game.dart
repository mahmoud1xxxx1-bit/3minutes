import 'package:flutter/material.dart';
import '../../domain/mini_game_contract.dart';

/// Phase 6 Integration Contract Template
/// 
/// Copy this template to create a new mini-game. 
/// It guarantees zero interference with the Match/Settlement engine.
class TemplateGame extends StatefulWidget {
  const TemplateGame({
    super.key,
    required this.config,
    required this.onComplete,
  });

  final MiniGameConfig config;
  final ValueChanged<MiniGameResult> onComplete;

  @override
  State<TemplateGame> createState() => _TemplateGameState();
}

class _TemplateGameState extends State<TemplateGame> {
  final Stopwatch _stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    // Initialize deterministic game state using widget.config.seed
    _stopwatch.start();
  }

  void _finishGame() {
    _stopwatch.stop();
    // Emit the contract result. The Match Engine handles the rest.
    widget.onComplete(
      MiniGameResult(
        completed: true,
        score: 5000, // Range: 0 - 10000
        accuracy: 1.0, // Range: 0.0 - 1.0
        mistakes: 0,
        duration: _stopwatch.elapsed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Template Game')),
      body: Center(
        child: ElevatedButton(
          onPressed: _finishGame,
          child: const Text('Complete Game'),
        ),
      ),
    );
  }
}
