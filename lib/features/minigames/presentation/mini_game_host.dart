import 'package:flutter/material.dart';

import '../domain/mini_game_contract.dart';
import 'find_differences/find_differences_game.dart';
import 'follow_the_cup/follow_the_cup_game.dart';
import 'mole_strike/mole_strike_game.dart';
import 'path_rush/path_rush_game.dart';
import 'traffic_loop/traffic_loop_game.dart';
import 'mirror_control/mirror_control_minigame.dart';


class MiniGameHost extends StatelessWidget {
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
  Widget build(BuildContext context) {
    switch (game.id) {
      case 'mirror_control':
        return MirrorControlMiniGame(
          key: ValueKey('${game.id}-${config.seed}'),
          config: config,
          onComplete: onComplete,
        );
      case 'mole_strike':
        return MoleStrikeGame(
          key: ValueKey('${game.id}-${config.seed}'),
          config: config,
          onComplete: onComplete,
        );
      case 'traffic_loop':
        return TrafficLoopGame(
          key: ValueKey('${game.id}-${config.seed}'),
          config: config,
          onComplete: onComplete,
        );
      case 'follow_the_cup':
        return FollowTheCupGame(
          key: ValueKey('${game.id}-${config.seed}'),
          config: config,
          onComplete: onComplete,
        );
      case 'path_rush':
        return PathRushGame(
          key: ValueKey('${game.id}-${config.seed}'),
          config: config,
          onComplete: onComplete,
        );
      case 'find_differences':
        return FindDifferencesGame(
          key: ValueKey('${game.id}-${config.seed}'),
          config: config,
          onComplete: onComplete,
        );
    }

    return const Center(child: Text('Game not found'));
  }
}
