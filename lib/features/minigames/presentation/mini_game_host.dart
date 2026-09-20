import 'package:flutter/material.dart';

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
import 'traffic_loop/traffic_loop_game.dart';
import 'hidden_pigeon/hidden_pigeon_game.dart';
import 'shared/minigame_environment.dart';
import 'shared/unified_game_scaffold.dart';

class MiniGameHost extends StatefulWidget {
  const MiniGameHost({
    super.key,
    required this.game,
    required this.config,
    required this.onComplete,
  });

  final MiniGameDescriptor game;
  final MiniGameConfig config;
  final ValueChanged<MiniGameResult> onComplete;

  @override
  State<MiniGameHost> createState() => _MiniGameHostState();
}

class _MiniGameHostState extends State<MiniGameHost> {
  late MinigameEnvironmentController _envController;

  @override
  void initState() {
    super.initState();
    _envController = MinigameEnvironmentController();
  }

  @override
  void dispose() {
    _envController.dispose();
    super.dispose();
  }

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
        gameWidget = FindDifferencesGame(key: ValueKey('-'), config: widget.config, onComplete: _handleComplete);
        break;
      case 'follow_the_cup':
        gameWidget = FollowTheCupGame(key: ValueKey('-'), config: widget.config, onComplete: _handleComplete);
        break;
      case 'key_escape':
        gameWidget = KeyEscapeGame(key: ValueKey('-'), config: widget.config, onComplete: _handleComplete);
        break;
      case 'level_devil':
        gameWidget = LevelDevilHost(key: ValueKey('-'), config: widget.config, onComplete: _handleComplete);
        break;
      case 'mirror_control':
        gameWidget = MirrorControlMiniGame(key: ValueKey('-'), config: widget.config, onComplete: _handleComplete);
        break;
      case 'mole_strike':
        gameWidget = MoleStrikeGame(key: ValueKey('-'), config: widget.config, onComplete: _handleComplete);
        break;
      case 'ninja_slice':
        gameWidget = NinjaSliceGame(key: ValueKey('-'), config: widget.config, onComplete: _handleComplete);
        break;
      case 'onet_connect':
        gameWidget = OnetConnectGame(key: ValueKey('-'), config: widget.config, onComplete: _handleComplete);
        break;
      case 'path_rush':
        gameWidget = PathRushGame(key: ValueKey('-'), config: widget.config, onComplete: _handleComplete);
        break;
      case 'traffic_loop':
        gameWidget = TrafficLoopGame(key: ValueKey('-'), config: widget.config, onComplete: _handleComplete);
        break;
      case 'hidden_pigeon':
        gameWidget = HiddenPigeonGame(config: widget.config, onComplete: _handleComplete);
        break;
      default:
        gameWidget = const Center(child: Text('Game not found'));
    }

    return MinigameEnvironment(
      controller: _envController,
      child: UnifiedGameScaffold(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          switchInCurve: Curves.easeOutBack,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: FadeTransition(opacity: animation, child: child)),
          child: gameWidget,
        ),
      ),
    );
  }
}
