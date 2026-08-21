import '../../../core/random/deterministic_rng.dart';
import '../domain/mini_game_contract.dart';

class GameRegistry {
  const GameRegistry._();

  static const int version = 8;

  static const List<MiniGameDescriptor> games = [
    MiniGameDescriptor(id: 'tap_target', title: '', category: MiniGameCategory.precision),
    MiniGameDescriptor(id: 'quick_math', title: '', category: MiniGameCategory.logic),
    MiniGameDescriptor(id: 'color_match', title: '', category: MiniGameCategory.reaction),
    MiniGameDescriptor(id: 'odd_one_out', title: '', category: MiniGameCategory.logic),
    MiniGameDescriptor(id: 'memory_flash', title: '', category: MiniGameCategory.memory),
    MiniGameDescriptor(id: 'direction_swipe', title: '', category: MiniGameCategory.reaction),
    MiniGameDescriptor(id: 'number_order', title: '', category: MiniGameCategory.memory),
    MiniGameDescriptor(id: 'shape_count', title: '', category: MiniGameCategory.logic),
    MiniGameDescriptor(id: 'reaction_stop', title: '', category: MiniGameCategory.reaction),
    MiniGameDescriptor(id: 'symbol_pair', title: '', category: MiniGameCategory.precision),
    MiniGameDescriptor(id: 'mole_strike', title: '', category: MiniGameCategory.reaction),
    MiniGameDescriptor(id: 'follow_the_cup', title: '', category: MiniGameCategory.memory),
    MiniGameDescriptor(id: 'path_rush', title: '', category: MiniGameCategory.logic),
    MiniGameDescriptor(id: 'find_differences', title: '', category: MiniGameCategory.precision),
  ];

  static List<MiniGameDescriptor> sequence({required int seed, required int count}) {
    if (count < 1 || count > games.length) {
      throw ArgumentError.value(count, 'count', 'Must fit the registry size.');
    }
    final random = DeterministicRng(seed);
    if (count < MiniGameCategory.values.length) {
      final shuffled = List<MiniGameDescriptor>.of(games);
      random.shuffle(shuffled);
      return List<MiniGameDescriptor>.unmodifiable(shuffled.take(count));
    }
    final selected = <MiniGameDescriptor>[];
    final remaining = List<MiniGameDescriptor>.of(games);
    for (final category in MiniGameCategory.values) {
      final categoryGames = remaining.where((game) => game.category == category).toList(growable: false);
      random.shuffle(categoryGames);
      if (categoryGames.isEmpty) throw StateError('Registry is missing the ${category.name} category.');
      final pick = categoryGames.first;
      selected.add(pick);
      remaining.removeWhere((game) => game.id == pick.id);
    }
    random.shuffle(remaining);
    selected.addAll(remaining.take(count - selected.length));
    random.shuffle(selected);
    return List<MiniGameDescriptor>.unmodifiable(selected);
  }
}
