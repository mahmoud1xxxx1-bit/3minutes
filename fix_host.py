import re

host_code = """import 'package:flutter/material.dart';

import '../domain/mini_game_contract.dart';
import 'find_differences/find_differences_game.dart';
import 'follow_the_cup/follow_the_cup_game.dart';
import 'key_escape/key_escape_game.dart';
import 'level_devil/level_devil_game.dart';
import 'mirror_control/mirror_control_game.dart';
import 'mole_strike/mole_strike_game.dart';
import 'ninja_slice/ninja_slice_game.dart';
import 'onet_connect/onet_connect_game.dart';
import 'path_rush/path_rush_game.dart';
import 'traffic_loop/traffic_loop_game.dart';
import 'hidden_pigeon/hidden_pigeon_game.dart';

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
      case 'find_differences':
        return FindDifferencesGame(
          key: ValueKey('-'),
          config: config,
          onComplete: onComplete,
        );
      case 'follow_the_cup':
        return FollowTheCupGame(
          key: ValueKey('-'),
          config: config,
          onComplete: onComplete,
        );
      case 'key_escape':
        return KeyEscapeGame(
          key: ValueKey('-'),
          config: config,
          onComplete: onComplete,
        );
      case 'level_devil':
        return LevelDevilGame(
          key: ValueKey('-'),
          config: config,
          onComplete: onComplete,
        );
      case 'mirror_control':
        return MirrorControlGame(
          key: ValueKey('-'),
          config: config,
          onComplete: onComplete,
        );
      case 'mole_strike':
        return MoleStrikeGame(
          key: ValueKey('-'),
          config: config,
          onComplete: onComplete,
        );
      case 'ninja_slice':
        return NinjaSliceGame(
          key: ValueKey('-'),
          config: config,
          onComplete: onComplete,
        );
      case 'onet_connect':
        return OnetConnectGame(
          key: ValueKey('-'),
          config: config,
          onComplete: onComplete,
        );
      case 'path_rush':
        return PathRushGame(
          key: ValueKey('-'),
          config: config,
          onComplete: onComplete,
        );
      case 'traffic_loop':
        return TrafficLoopGame(
          key: ValueKey('-'),
          config: config,
          onComplete: onComplete,
        );
      case 'hidden_pigeon':
        return HiddenPigeonGame(
          key: ValueKey('-'),
          config: config,
          onComplete: onComplete,
        );
      default:
        return const Center(child: Text('Game not found'));
    }
  }
}
"""

with open(r"c:\Users\loved\3minutes\lib\features\minigames\presentation\mini_game_host.dart", "w", encoding="utf-8") as f:
    f.write(host_code)

print("Host updated")
