import 'dart:math';

import '../domain/mini_game_contract.dart';

class GameRegistry {
  const GameRegistry._();

  static const int version = 1;

  static const List<MiniGameDescriptor> games = [
    MiniGameDescriptor(id: 'tap_target', title: 'Tap Target'),
    MiniGameDescriptor(id: 'quick_math', title: 'Quick Math'),
    MiniGameDescriptor(id: 'color_match', title: 'Color Match'),
    MiniGameDescriptor(id: 'odd_one_out', title: 'Odd One Out'),
    MiniGameDescriptor(id: 'memory_flash', title: 'Memory Flash'),
    MiniGameDescriptor(id: 'direction_swipe', title: 'Direction Swipe'),
    MiniGameDescriptor(id: 'number_order', title: 'Number Order'),
    MiniGameDescriptor(id: 'shape_count', title: 'Shape Count'),
    MiniGameDescriptor(id: 'reaction_stop', title: 'Reaction Stop'),
    MiniGameDescriptor(id: 'symbol_pair', title: 'Symbol Pair'),
  ];

  static List<MiniGameDescriptor> sequence({
    required int seed,
    required int count,
  }) {
    if (count < 1 || count > games.length) {
      throw ArgumentError.value(count, 'count', 'Must fit the registry size.');
    }

    final shuffled = List<MiniGameDescriptor>.of(games);
    shuffled.shuffle(Random(seed));
    return List<MiniGameDescriptor>.unmodifiable(shuffled.take(count));
  }
}
