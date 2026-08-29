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
    onComplete(finalResult);
  }

  @override
  Widget build(BuildContext context) {
    switch (game.id) {
      case 'find_differences':
        return FindDifferencesGame(
          key: ValueKey('${game.id}-${config.seed}'),
          config: config,
          onComplete: _handleComplete,
        );
      case 'follow_the_cup':
        return FollowTheCupGame(
          key: ValueKey('${game.id}-${config.seed}'),
          config: config,
          onComplete: _handleComplete,
        );
      case 'key_escape':
        return KeyEscapeGame(
          key: ValueKey('${game.id}-${config.seed}'),
          config: config,
          onComplete: _handleComplete,
        );
      case 'level_devil':
        return LevelDevilHost(
          key: ValueKey('${game.id}-${config.seed}'),
          config: config,
          onComplete: _handleComplete,
        );
      case 'mirror_control':
        return MirrorControlMiniGame(
          key: ValueKey('${game.id}-${config.seed}'),
          config: config,
          onComplete: _handleComplete,
        );
      case 'mole_strike':
        return MoleStrikeGame(
          key: ValueKey('${game.id}-${config.seed}'),
          config: config,
          onComplete: _handleComplete,
        );
      case 'ninja_slice':
        return NinjaSliceGame(
          key: ValueKey('${game.id}-${config.seed}'),
          config: config,
          onComplete: _handleComplete,
        );
      case 'onet_connect':
        return OnetConnectGame(
          key: ValueKey('${game.id}-${config.seed}'),
          config: config,
          onComplete: _handleComplete,
        );
      case 'path_rush':
        return PathRushGame(
          key: ValueKey('${game.id}-${config.seed}'),
          config: config,
          onComplete: _handleComplete,
        );
      case 'traffic_loop':
        return TrafficLoopGame(
          key: ValueKey('${game.id}-${config.seed}'),
          config: config,
          onComplete: _handleComplete,
        );
    }

    return const Center(child: Text('Game not found'));
  }
}