import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/minigames/data/game_registry.dart';

void main() {
  test('approved mini-game library includes Mole Strike V6', () {
    expect(GameRegistry.games.length, 11);
    expect(GameRegistry.version, 4);
    expect(
      GameRegistry.games.where((game) => game.id == 'mole_strike').length,
      1,
    );
  });
}
