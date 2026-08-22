import '../../../core/random/deterministic_rng.dart';
import '../domain/mini_game_contract.dart';

class GameRegistry {
  const GameRegistry._();

  static const int version = 9;

  static const List<MiniGameDescriptor> games = [
    MiniGameDescriptor(id: 'mole_strike', title: '', category: MiniGameCategory.reaction),
    MiniGameDescriptor(id: 'follow_the_cup', title: '', category: MiniGameCategory.memory),
    MiniGameDescriptor(id: 'path_rush', title: '', category: MiniGameCategory.logic),
    MiniGameDescriptor(id: 'find_differences', title: '', category: MiniGameCategory.precision),
    MiniGameDescriptor(id: 'mirror_control', title: '', category: MiniGameCategory.precision),
  ];

  static List<MiniGameDescriptor> sequence({required int seed, required int count}) {
    if (count < 1) {
      throw ArgumentError.value(count, 'count', 'Must be at least 1.');
    }
    final random = DeterministicRng(seed);
    final selected = <MiniGameDescriptor>[];
    
    // Tetris-style Bag Randomizer for perfect distribution
    // This ensures EVERY game appears evenly before any game repeats.
    while (selected.length < count) {
      final bag = List<MiniGameDescriptor>.of(games);
      random.shuffle(bag);
      
      // Prevent back-to-back duplicates across bags if possible
      if (selected.isNotEmpty && bag.isNotEmpty && selected.last.id == bag.first.id && bag.length > 1) {
        final temp = bag[0];
        bag[0] = bag[1];
        bag[1] = temp;
      }
      
      final needed = count - selected.length;
      if (bag.length > needed) {
        selected.addAll(bag.take(needed));
      } else {
        selected.addAll(bag);
      }
    }
    
    return List<MiniGameDescriptor>.unmodifiable(selected);
  }
}
