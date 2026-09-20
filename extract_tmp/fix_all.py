import os
import re

# 1. FIX THE TICKER SPEED ISSUE
path = "lib/features/minigames/presentation/mirror_control/mirror_control_minigame.dart"
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

if "Duration _lastTime" not in content:
    content = content.replace("late Ticker _ticker;", "late Ticker _ticker;\n  Duration _lastTime = Duration.zero;")

    old_ticker = """    _ticker = createTicker((elapsed) {
      if (!_assetsLoaded || _hasCompleted) return;
      
      final dt = 1.0 / 60.0;"""

    new_ticker = """    _ticker = createTicker((elapsed) {
      if (!_assetsLoaded || _hasCompleted) return;
      
      if (_lastTime == Duration.zero) {
        _lastTime = elapsed;
        return;
      }
      final dt = (elapsed - _lastTime).inMicroseconds / 1000000.0;
      _lastTime = elapsed;"""

    content = content.replace(old_ticker, new_ticker)
    
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)


# 2. FIX THE GAME REGISTRY (TETRIS BAG RANDOMIZER)
reg_path = "lib/features/minigames/data/game_registry.dart"
with open(reg_path, 'r', encoding='utf-8') as f:
    reg_content = f.read()

old_sequence = """  static List<MiniGameDescriptor> sequence({required int seed, required int count}) {
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
  }"""

new_sequence = """  static List<MiniGameDescriptor> sequence({required int seed, required int count}) {
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
  }"""

if old_sequence in reg_content:
    reg_content = reg_content.replace(old_sequence, new_sequence)
    with open(reg_path, 'w', encoding='utf-8') as f:
        f.write(reg_content)
else:
    print("WARNING: Could not find old sequence logic!")

print("All fixes applied!")
