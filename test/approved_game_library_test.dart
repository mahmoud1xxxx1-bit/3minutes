import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/minigames/data/game_registry.dart';

void main() {
  test('approved mini-game library remains at ten games', () {
    expect(GameRegistry.games.length, 10);
  });
}
