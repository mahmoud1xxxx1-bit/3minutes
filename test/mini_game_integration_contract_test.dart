import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/minigames/data/game_registry.dart';
import 'package:game/features/minigames/domain/mini_game_contract.dart';
import 'package:game/features/minigames/domain/mini_game_engine.dart';
import 'package:game/features/minigames/presentation/mini_game_host.dart';

// Dummy context to bypass build
class _DummyContext implements BuildContext {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('Phase 6: MiniGame Integration Contract', () {
    test('Every registered game has an Engine mapping', () {
      for (final game in GameRegistry.games) {
        expect(() => MiniGameEngineRegistry.engineFor(game.id), returnsNormally, reason: 'Game  lacks an engine mapping.');
      }
    });

    test('Every registered game is provided by MiniGameHost', () {
      final context = _DummyContext();
      for (final game in GameRegistry.games) {
        final config = const MiniGameConfig(seed: 12345, difficulty: 1);
        final host = MiniGameHost(
          game: game,
          config: config,
          onComplete: (result) {},
        );

        final widget = host.build(context);
        
        // Ensure the host doesn't fallback to Center -> Text('Game not found')
        if (widget is Center) {
          final child = widget.child;
          if (child is Text && child.data == 'Game not found') {
            fail('Game  is registered in GameRegistry but missing from MiniGameHost switch statement.');
          }
        }
      }
    });
  });
}
