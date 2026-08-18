import 'dart:math';

import '../domain/mini_game_contract.dart';

class GameRegistry {
  const GameRegistry._();

  static const int version = 1;

  static const List<MiniGameDescriptor> games = [
    MiniGameDescriptor(
      id: 'tap_target',
      title: 'Tap Target',
      category: MiniGameCategory.precision,
    ),
    MiniGameDescriptor(
      id: 'quick_math',
      title: 'Quick Math',
      category: MiniGameCategory.logic,
    ),
    MiniGameDescriptor(
      id: 'color_match',
      title: 'Color Match',
      category: MiniGameCategory.reaction,
    ),
    MiniGameDescriptor(
      id: 'odd_one_out',
      title: 'Odd One Out',
      category: MiniGameCategory.logic,
    ),
    MiniGameDescriptor(
      id: 'memory_flash',
      title: 'Memory Flash',
      category: MiniGameCategory.memory,
    ),
    MiniGameDescriptor(
      id: 'direction_swipe',
      title: 'Direction Swipe',
      category: MiniGameCategory.reaction,
    ),
    MiniGameDescriptor(
      id: 'number_order',
      title: 'Number Order',
      category: MiniGameCategory.memory,
    ),
    MiniGameDescriptor(
      id: 'shape_count',
      title: 'Shape Count',
      category: MiniGameCategory.logic,
    ),
    MiniGameDescriptor(
      id: 'reaction_stop',
      title: 'Reaction Stop',
      category: MiniGameCategory.reaction,
    ),
    MiniGameDescriptor(
      id: 'symbol_pair',
      title: 'Symbol Pair',
      category: MiniGameCategory.precision,
    ),
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
