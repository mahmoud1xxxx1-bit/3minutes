import 'package:flutter/material.dart';

import '../domain/mini_game_contract.dart';
import 'legacy_mini_game_host.dart' as legacy;
import 'mole_strike_game.dart';

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
    if (game.id == 'mole_strike') {
      return MoleStrikeGame(
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
