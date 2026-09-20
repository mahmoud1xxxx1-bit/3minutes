code = open('lib/features/minigames/presentation/ninja_slice/ninja_slice_game.dart', 'r', encoding='utf-8').read()

bad_func = '''  String _getEmoji(ItemType type) {
    switch (type) {
      case ItemType.apple: return 'ðŸ Ž';
      case ItemType.watermelon: return 'ðŸ ‰';
      case ItemType.banana: return 'ðŸ Œ';
      case ItemType.coconut: return '🥥';
      case ItemType.freeze: return '🧊';
      case ItemType.frenzy: return '🌟';
      default: return '';
    }
  }'''

good_func = '''  String _getEmoji(ItemType type) {
    switch (type) {
      case ItemType.apple: return '🍎';
      case ItemType.watermelon: return '🍉';
      case ItemType.banana: return '🍌';
      case ItemType.coconut: return '🥥';
      case ItemType.freeze: return '🧊';
      case ItemType.frenzy: return '🌟';
      default: return '';
    }
  }'''

code = code.replace(bad_func, good_func)

with open('lib/features/minigames/presentation/ninja_slice/ninja_slice_game.dart', 'w', encoding='utf-8') as f:
    f.write(code)
