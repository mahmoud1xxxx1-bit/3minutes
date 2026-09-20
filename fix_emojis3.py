import re

with open('lib/features/minigames/presentation/ninja_slice/ninja_slice_game.dart', 'r', encoding='utf-8') as f:
    code = f.read()

# Replace any garbled emojis with the correct ones
# We know the method is _getEmoji
# Let's just rewrite that specific function body

func_pattern = r'String _getEmoji\(ItemType type\) \{.*?\n  \}'
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
