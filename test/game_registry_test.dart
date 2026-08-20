import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/minigames/data/game_registry.dart';
import 'package:game/features/minigames/domain/mini_game_contract.dart';
import 'package:game/features/minigames/domain/mini_game_engine.dart';

void main() {
  test('registry ids are unique and all categories are represented', () {
    final ids = GameRegistry.games.map((game) => game.id).toList();
    final categories = GameRegistry.games.map((game) => game.category).toSet();
    expect(ids.toSet().length, ids.length);
    expect(categories, containsAll(MiniGameCategory.values));
    for (final game in GameRegistry.games) {
      expect(() => MiniGameEngineRegistry.engineFor(game.id), returnsNormally);
    }
  });

  test('same seed produces the same balanced eight-game sequence', () {
    final first = GameRegistry.sequence(seed: 20260818, count: 8);
    final second = GameRegistry.sequence(seed: 20260818, count: 8);
    final categories = first.map((game) => game.category).toSet();
    expect(first.map((game) => game.id), second.map((game) => game.id));
    expect(first.length, 8);
    expect(first.map((game) => game.id).toSet().length, 8);
    expect(categories, containsAll(MiniGameCategory.values));
  });

  test('registry v6 sequence matches the cross-platform vector', () {
    final sequence = GameRegistry.sequence(seed: 20260818, count: 8);
    expect(sequence.map((game) => game.id).toList(), const [
      'number_order',
      'color_match',
      'odd_one_out',
      'follow_the_cup',
      'symbol_pair',
      'tap_target',
      'quick_math',
      'reaction_stop',
    ]);
  });
}
