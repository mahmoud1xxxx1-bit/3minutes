import 'package:flutter/material.dart';

import '../domain/mini_game_contract.dart';
import 'find_differences/find_differences_game.dart';
import 'ninja_slice/ninja_slice_game.dart';
import 'follow_the_cup/follow_the_cup_game.dart';
import 'mole_strike/mole_strike_game.dart';
import 'path_rush/path_rush_game.dart';
import 'traffic_loop/traffic_loop_game.dart';
import 'mirror_control/mirror_control_minigame.dart';
import 'key_escape/key_escape_game.dart';
import 'level_devil/level_devil_host.dart';
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
    _envController = MinigameEnvironmentController()..setTitle(widget.game.title);
  }

  @override
  void didUpdateWidget(MiniGameHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.game.title != widget.game.title) {
      _envController.setTitle(widget.game.title);
    }
  }

  @override
  void dispose() {
    _envController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget gameWidget;
    switch (widget.game.id) {
      case 'level_devil':
        gameWidget = LevelDevilHost(key: ValueKey('${widget.game.id}-${widget.config.seed}'), config: widget.config, onComplete: widget.onComplete);
        break;
      case 'mirror_control':
        gameWidget = MirrorControlMiniGame(key: ValueKey('${widget.game.id}-${widget.config.seed}'), config: widget.config, onComplete: widget.onComplete);
        break;
      case 'mole_strike':
        gameWidget = MoleStrikeGame(key: ValueKey('${widget.game.id}-${widget.config.seed}'), config: widget.config, onComplete: widget.onComplete);
        break;
      case 'traffic_loop':
        gameWidget = TrafficLoopGame(key: ValueKey('${widget.game.id}-${widget.config.seed}'), config: widget.config, onComplete: widget.onComplete);
        break;
      case 'follow_the_cup':
        gameWidget = FollowTheCupGame(key: ValueKey('${widget.game.id}-${widget.config.seed}'), config: widget.config, onComplete: widget.onComplete);
        break;
      case 'path_rush':
        gameWidget = PathRushGame(key: ValueKey('${widget.game.id}-${widget.config.seed}'), config: widget.config, onComplete: widget.onComplete);
        break;
      case 'find_differences':
        gameWidget = FindDifferencesGame(key: ValueKey('${widget.game.id}-${widget.config.seed}'), config: widget.config, onComplete: widget.onComplete);
        break;
            case 'ninja_slice':
        gameWidget = NinjaSliceGame(key: ValueKey('${widget.game.id}-${widget.config.seed}'), config: widget.config, onComplete: widget.onComplete);
        break;
      case 'key_escape':
        gameWidget = KeyEscapeGame(key: ValueKey('${widget.game.id}-${widget.config.seed}'), config: widget.config, onComplete: widget.onComplete);
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

