import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/minigames/data/game_registry.dart';

void main() {
  test('approved mini-game library contains exact 11 games', () {
    expect(GameRegistry.games.length, 11);
    for (final id in [
      'find_differences',
      'follow_the_cup',
      'key_escape',
      'level_devil',
      'mirror_control',
      'mole_strike',
      'ninja_slice',
      'onet_connect',
      'path_rush',
      'traffic_loop',
      'hidden_pigeon'
    ]) {
      expect(GameRegistry.games.where((game) => game.id == id).length, 1);
    }
  });
}
