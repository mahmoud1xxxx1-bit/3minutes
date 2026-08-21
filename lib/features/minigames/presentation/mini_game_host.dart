import 'package:flutter/material.dart';

import '../domain/mini_game_contract.dart';
import 'find_differences/find_differences_game.dart';
import 'follow_the_cup_game.dart';
import 'legacy_mini_game_host.dart' as legacy;
import 'mole_strike_game.dart';
import 'path_rush_game.dart';

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
      case 'mole_strike':
        return MoleStrikeGame(
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

    return legacy.MiniGameHost(
      game: game,
      config: config,
      onComplete: onComplete,
    );
  }
}
