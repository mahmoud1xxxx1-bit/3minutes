import re

with open('lib/features/minigames/presentation/key_escape/key_escape_game.dart', 'r', encoding='utf-8') as f:
    code = f.read()

# Replace using regex to ignore exact whitespace
code = re.sub(
    r'const SizedBox\(height: 30\),\s*double cellSize = boardSize / 6;',
    '''const SizedBox(height: 30),
                Expanded(
                  child: Center(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        double boardSize = math.min(math.min(constraints.maxWidth * 0.9, constraints.maxHeight * 0.9), 450);
                        double cellSize = boardSize / 6;''',
    code
)

with open('lib/features/minigames/presentation/key_escape/key_escape_game.dart', 'w', encoding='utf-8') as f:
    f.write(code)
