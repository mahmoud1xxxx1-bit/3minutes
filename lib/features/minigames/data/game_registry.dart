import '../../../core/random/deterministic_rng.dart';
import '../domain/mini_game_contract.dart';

class GameRegistry {
  const GameRegistry._();

  static const int version = 8;

  static const List<MiniGameDescriptor> games = [
    MiniGameDescriptor(id: 'mole_strike', title: '', category: MiniGameCategory.reaction),
    MiniGameDescriptor(id: 'follow_the_cup', title: '', category: MiniGameCategory.memory),
    MiniGameDescriptor(id: 'path_rush', title: '', category: MiniGameCategory.logic),
    MiniGameDescriptor(id: 'find_differences', title: '', category: MiniGameCategory.precision),
  ];

  static List<MiniGameDescriptor> sequence({required int seed, required int count}) {
    if (count < 1) {
      throw ArgumentError.value(count, 'count', 'Must be at least 1.');
    }
    final random = DeterministicRng(seed);
    
    // If we need fewer games than categories, just shuffle all and take 'count'
    if (count < MiniGameCategory.values.length) {
      final shuffled = List<MiniGameDescriptor>.of(games);
      random.shuffle(shuffled);
      return List<MiniGameDescriptor>.unmodifiable(shuffled.take(count));
    }

    final selected = <MiniGameDescriptor>[];
    
    // Step 1: Ensure one of each category (if possible based on available games)
    final remaining = List<MiniGameDescriptor>.of(games);
    for (final category in MiniGameCategory.values) {
      final categoryGames = remaining.where((game) => game.category == category).toList(growable: false);
      if (categoryGames.isNotEmpty) {
        random.shuffle(categoryGames);
        final pick = categoryGames.first;
        selected.add(pick);
        remaining.removeWhere((game) => game.id == pick.id);
      }
    }
    
    // Step 2: Fill the remaining slots up to 'count'
    // Since count (e.g. 8) might be greater than games.length (4), we must allow duplicates.
    while (selected.length < count) {
      // Pick randomly from ALL available games to allow repeats
      final allShuffled = List<MiniGameDescriptor>.of(games);
      random.shuffle(allShuffled);
      final pick = allShuffled.first;
      selected.add(pick);
    }
    
    // Step 3: Shuffle the final sequence so the guaranteed category picks aren't always first
    random.shuffle(selected);
    return List<MiniGameDescriptor>.unmodifiable(selected.take(count));
  }
}
