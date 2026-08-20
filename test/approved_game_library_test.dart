import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/minigames/data/game_registry.dart';

void main() {
  test('approved mini-game library includes all four approved production games', () {
    expect(GameRegistry.games.length, 14);
    expect(GameRegistry.version, 6);
    for (final id in [
      'mole_strike',
      'follow_the_cup',
      'path_rush',
      'find_differences',
    ]) {
      expect(GameRegistry.games.where((game) => game.id == id).length, 1);
    }
  });
}
