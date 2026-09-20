import re
code = open('lib/features/minigames/presentation/ninja_slice/ninja_slice_game.dart', 'r', encoding='utf-8').read()

func_pattern = r'String _getEmoji\(ItemType type\)\s*\{.*?\s*\}'
replacement = '''String _getEmoji(ItemType type) {
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

code = re.sub(func_pattern, replacement, code, flags=re.DOTALL)

with open('lib/features/minigames/presentation/ninja_slice/ninja_slice_game.dart', 'w', encoding='utf-8') as f:
    f.write(code)
