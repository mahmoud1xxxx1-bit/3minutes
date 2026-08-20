import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/minigames/data/game_registry.dart';

void main() {
  test('approved mini-game library includes the three approved production games', () {
    expect(GameRegistry.games.length, 13);
    expect(GameRegistry.version, 5);
    for (final id in ['mole_strike', 'follow_the_cup', 'path_rush']) {
      expect(GameRegistry.games.where((game) => game.id == id).length, 1);
    }
  });
}
