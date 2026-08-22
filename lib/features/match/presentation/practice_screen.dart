import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../minigames/domain/mini_game_contract.dart';
import '../../minigames/presentation/mini_game_host.dart';
import '../domain/match_runtime.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  late final MatchRuntime _runtime;

  @override
  void initState() {
    super.initState();
    _runtime = MatchRuntime(
      seed: math.Random().nextInt(999999),
      startedAt: DateTime.now(),
      gameCount: 8,
    );
  }

  void _onComplete(MiniGameResult result) {
    setState(() {
      _runtime.recordResult(result);
    });
    if (_runtime.allGamesCompleted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_runtime.allGamesCompleted) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final game = _runtime.currentGame!;
    final index = _runtime.progress.completedGames;
    // Combine match seed with round index to ensure deterministic but unique seed per game
    final gameSeed = _runtime.seed ^ index;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Practice Mode (${index + 1}/8)'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: MiniGameHost(
                  key: ValueKey('$index-${game.id}'),
                  game: game,
                  config: MiniGameConfig(
                    seed: gameSeed,
                    difficulty: 1,
                  ),
                  onComplete: _onComplete,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
