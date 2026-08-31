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

  void _complete(MiniGameResult raw) {
    // Compatibility boundary for the existing game catalog. Mini-games may
    // keep their internal counters for UI/reporting, but competitive match
    // points are deliberately binary and universal: objective clear = 1000,
    // objective failed = 0. This keeps old games from inventing their own
    // economy/score formula while allowing future games to adopt the contract
    // directly without touching MatchEngine.
    final stepCount = raw.progressStepCount < 1 ? 1 : raw.progressStepCount;
    final normalizedProgress = raw.completed
        ? stepCount
        : raw.progressStep.clamp(0, stepCount - 1).toInt();

    onComplete(
      MiniGameResult(
        completed: raw.completed,
        score: raw.completed ? 1000 : 0,
        accuracy: raw.accuracy.clamp(0.0, 1.0).toDouble(),
        mistakes: raw.mistakes < 0 ? 0 : raw.mistakes,
        duration: raw.duration.isNegative ? Duration.zero : raw.duration,
        progressStep: normalizedProgress,
        progressStepCount: stepCount,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (game.id) {
      case 'find_differences':
        return FindDifferencesGame(
          key: _runtimeKey,
          config: config,
          onComplete: _complete,
        );
      case 'follow_the_cup':
        return FollowTheCupGame(
          key: _runtimeKey,
          config: config,
          onComplete: _complete,
        );
      case 'key_escape':
        return KeyEscapeGame(
          key: _runtimeKey,
          config: config,
          onComplete: _complete,
        );
      case 'level_devil':
        return LevelDevilGame(
          key: _runtimeKey,
          config: config,
          onComplete: _complete,
        );
      case 'mirror_control':
        return MirrorControlMinigame(
          key: _runtimeKey,
          config: config,
          onComplete: _complete,
        );
      case 'mole_strike':
        return MoleStrikeGame(
          key: _runtimeKey,
          config: config,
          onComplete: _complete,
        );
      case 'ninja_slice':
        return NinjaSliceGame(
          key: _runtimeKey,
          config: config,
          onComplete: _complete,
        );
      case 'onet_connect':
        return OnetConnectGame(
          key: _runtimeKey,
          config: config,
          onComplete: _complete,
        );
      case 'path_rush':
        return PathRushGame(
          key: _runtimeKey,
          config: config,
          onComplete: _complete,
        );
      case 'traffic_loop':
        return TrafficLoopGame(
          key: _runtimeKey,
          config: config,
          onComplete: _complete,
        );
      case 'hidden_pigeon':
        return HiddenPigeonGame(
          key: _runtimeKey,
          config: config,
          onComplete: _complete,
        );
    }

    return legacy.MiniGameHost(
      game: game,
      config: config,
      onComplete: _complete,
    );
  }
}
