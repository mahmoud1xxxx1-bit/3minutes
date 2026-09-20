import re

with open('lib/features/minigames/presentation/key_escape/key_escape_game.dart', 'r', encoding='utf-8') as f:
    code = f.read()

# I will replace the broken part with the correct Expanded structure
code = code.replace('''                const SizedBox(height: 30),
                        double cellSize = boardSize / 6;
        
                          return Container(
                            width: boardSize + 24,''', '''                const SizedBox(height: 30),
                Expanded(
                  child: Center(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        double boardSize = math.min(math.min(constraints.maxWidth * 0.9, constraints.maxHeight * 0.9), 450);
                        double cellSize = boardSize / 6;
      
                        return Container(
                          width: boardSize + 24,''')

with open('lib/features/minigames/presentation/key_escape/key_escape_game.dart', 'w', encoding='utf-8') as f:
    f.write(code)
