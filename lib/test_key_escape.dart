import 'package:flutter/material.dart';
import 'features/minigames/presentation/key_escape/key_escape_game.dart';

import 'features/minigames/domain/mini_game_contract.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: KeyEscapeGame(
      config: MiniGameConfig(
        seed: 1234,
        difficulty: 1,
      ),
      onComplete: _ignoreResult,
    ),
  ));
}

void _ignoreResult(MiniGameResult result) {}
