import 'package:flutter/material.dart';

import '../domain/mini_game_contract.dart';
import 'find_differences/find_differences_game.dart';
import 'follow_the_cup/follow_the_cup_game.dart';
import 'hidden_pigeon/hidden_pigeon_game.dart';
import 'key_escape/key_escape_game.dart';
import 'legacy_mini_game_host.dart' as legacy;
import 'level_devil/level_devil_game.dart';
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

  Key get _runtimeKey => ValueKey('${game.id}-${config.seed}');

  @override
  Widget build(BuildContext context) {
    switch (game.id) {
      case 'find_differences':
        return FindDifferencesGame(
          key: _runtimeKey,
          config: config,
          onComplete: onComplete,
        );
      case 'follow_the_cup':
        return FollowTheCupGame(
          key: _runtimeKey,
          config: config,
          onComplete: onComplete,
        );
      case 'key_escape':
        return KeyEscapeGame(
          key: _runtimeKey,
          config: config,
          onComplete: onComplete,
        );
      case 'level_devil':
        return LevelDevilGame(
          key: _runtimeKey,
          config: config,
          onComplete: onComplete,
        );
      case 'mirror_control':
        return MirrorControlMinigame(
          key: _runtimeKey,
          config: config,
          onComplete: onComplete,
        );
      case 'mole_strike':
        return MoleStrikeGame(
          key: _runtimeKey,
          config: config,
          onComplete: onComplete,
        );
      case 'ninja_slice':
        return NinjaSliceGame(
          key: _runtimeKey,
          config: config,
          onComplete: onComplete,
        );
      case 'onet_connect':
        return OnetConnectGame(
          key: _runtimeKey,
          config: config,
          onComplete: onComplete,
        );
      case 'path_rush':
        return PathRushGame(
          key: _runtimeKey,
          config: config,
          onComplete: onComplete,
        );
      case 'traffic_loop':
        return TrafficLoopGame(
          key: _runtimeKey,
          config: config,
          onComplete: onComplete,
        );
      case 'hidden_pigeon':
        return HiddenPigeonGame(
          key: _runtimeKey,
          config: config,
          onComplete: onComplete,
        );
    }

    return legacy.MiniGameHost(
      game: game,
      config: config,
      onComplete: onComplete,
    );
  }
}
