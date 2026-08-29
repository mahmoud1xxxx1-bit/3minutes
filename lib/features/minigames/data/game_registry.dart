import '../../../core/random/deterministic_rng.dart';
import '../domain/mini_game_contract.dart';

class GameRegistry {
  const GameRegistry._();

  static const int version = 10;

  static const List<MiniGameDescriptor> games = [
    MiniGameDescriptor(id: 'find_differences', title: 'Find Differences', category: MiniGameCategory.precision),
    MiniGameDescriptor(id: 'follow_the_cup', title: 'Follow The Cup', category: MiniGameCategory.memory),
    MiniGameDescriptor(id: 'key_escape', title: 'Key Escape', category: MiniGameCategory.precision),
    MiniGameDescriptor(id: 'level_devil', title: 'Level Devil', category: MiniGameCategory.reaction),
    MiniGameDescriptor(id: 'mirror_control', title: 'Mirror Control', category: MiniGameCategory.precision),
    MiniGameDescriptor(id: 'mole_strike', title: 'Mole Strike', category: MiniGameCategory.reaction),
    MiniGameDescriptor(id: 'ninja_slice', title: 'Ninja Slice', category: MiniGameCategory.reaction),
    MiniGameDescriptor(id: 'onet_connect', title: 'Onet Connect', category: MiniGameCategory.logic),
    MiniGameDescriptor(id: 'path_rush', title: 'Path Rush', category: MiniGameCategory.logic),
    MiniGameDescriptor(id: 'traffic_loop', title: 'Traffic Loop', category: MiniGameCategory.logic),
  ];

  static List<MiniGameDescriptor> sequence({required int seed, required int count}) {
    if (count < 1) {
      throw ArgumentError.value(count, 'count', 'Must be at least 1.');
    }
    final random = DeterministicRng(seed);
    final selected = <MiniGameDescriptor>[];
    
    while (selected.length < count) {
      final bag = List<MiniGameDescriptor>.of(games);
      random.shuffle(bag);
      
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
