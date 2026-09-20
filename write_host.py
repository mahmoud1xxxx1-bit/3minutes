code = '''import 'package:flutter/material.dart';

import '../domain/mini_game_contract.dart';
import 'find_differences/find_differences_game.dart';
import 'follow_the_cup/follow_the_cup_game.dart';
import 'key_escape/key_escape_game.dart';
import 'level_devil/level_devil_host.dart';
import 'mirror_control/mirror_control_minigame.dart';
import 'mole_strike/mole_strike_game.dart';
import 'ninja_slice/ninja_slice_game.dart';
import 'onet_connect/onet_connect_game.dart';
import 'path_rush/path_rush_game.dart';
import 'shared/unified_game_scaffold.dart';
import 'traffic_loop/traffic_loop_game.dart';

class MiniGameHost extends StatefulWidget {
  final MiniGameDescriptor game;
  final MiniGameConfig config;
  final Function(MiniGameResult) onComplete;

  const MiniGameHost({
    super.key,
    required this.game,
    required this.config,
    required this.onComplete,
  });

  @override
  State<MiniGameHost> createState() => _MiniGameHostState();
}

class _MiniGameHostState extends State<MiniGameHost> {
  void _handleComplete(MiniGameResult originalResult) {
    // CAP THE SCORE AT 1000 AS REQUESTED BY THE USER
    final int clampedScore = originalResult.score > 1000 ? 1000 : (originalResult.score < 0 ? 0 : originalResult.score);
    final finalResult = MiniGameResult(
      completed: originalResult.completed,
      score: clampedScore,
      accuracy: originalResult.accuracy,
      mistakes: originalResult.mistakes,
      duration: originalResult.duration,
    );
    widget.onComplete(finalResult);
  }

  @override
  Widget build(BuildContext context) {
    Widget gameWidget;

    switch (widget.game.id) {
      case 'find_differences':
        gameWidget = FindDifferencesGame(key: ValueKey('\-\'), config: widget.config, onComplete: _handleComplete);
        break;
      case 'follow_the_cup':
        gameWidget = FollowTheCupGame(key: ValueKey('\-\'), config: widget.config, onComplete: _handleComplete);
        break;
      case 'key_escape':
        gameWidget = KeyEscapeGame(key: ValueKey('\-\'), config: widget.config, onComplete: _handleComplete);
        break;
      case 'level_devil':
        gameWidget = LevelDevilHost(key: ValueKey('\-\'), config: widget.config, onComplete: _handleComplete);
        break;
      case 'mirror_control':
        gameWidget = MirrorControlMinigame(key: ValueKey('\-\'), config: widget.config, onComplete: _handleComplete);
        break;
      case 'mole_strike':
        gameWidget = MoleStrikeGame(key: ValueKey('\-\'), config: widget.config, onComplete: _handleComplete);
        break;
      case 'ninja_slice':
        gameWidget = NinjaSliceGame(key: ValueKey('\-\'), config: widget.config, onComplete: _handleComplete);
        break;
      case 'onet_connect':
        gameWidget = OnetConnectGame(key: ValueKey('\-\'), config: widget.config, onComplete: _handleComplete);
        break;
      case 'path_rush':
        gameWidget = PathRushGame(key: ValueKey('\-\'), config: widget.config, onComplete: _handleComplete);
        break;
      case 'traffic_loop':
        gameWidget = TrafficLoopGame(key: ValueKey('\-\'), config: widget.config, onComplete: _handleComplete);
        break;
      default:
        gameWidget = const Center(
          child: Text('Game not implemented yet', style: TextStyle(color: Colors.white)),
        );
    }

    return UnifiedGameScaffold(
      title: widget.game.title,
      category: widget.game.category,
      timeLimit: const Duration(seconds: 60),
      onTimeUp: () {
        _handleComplete(MiniGameResult(
          completed: false,
          score: 0,
          accuracy: 0.0,
          mistakes: 0,
          duration: const Duration(seconds: 60),
        ));
      },
      child: gameWidget,
    );
  }
}
'''

with open('lib/features/minigames/presentation/mini_game_host.dart', 'w', encoding='utf-8') as f:
    f.write(code)
