import re

with open('lib/features/minigames/presentation/key_escape/key_escape_game.dart', 'r', encoding='utf-8') as f:
    code = f.read()

# Replace the broken part
old_part = '''                const SizedBox(height: 30),
                
                        decoration: BoxDecoration(
                          color: const Color(0xFF23143F),
                          borderRadius: BorderRadius.circular(20),'''

new_part = '''                const SizedBox(height: 30),
                
                Expanded(
                  child: Center(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        double boardSize = math.min(math.min(constraints.maxWidth * 0.9, constraints.maxHeight * 0.9), 450);
                        double cellSize = boardSize / 6;
      
                        return Container(
                          width: boardSize + 24,
                          height: boardSize,
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: boardSize,
                            height: boardSize,
                            decoration: BoxDecoration(
                              color: const Color(0xFF23143F),
                              borderRadius: BorderRadius.circular(20),'''

code = code.replace(old_part, new_part)

# Also need to add the closing tags for Expanded and Center at the end
old_end = '''                      ),
                    );
                  },
                ),
              ],'''

new_end = '''                      ),
                    );
                  },
                ),
                ),
                ),
              ],'''

code = code.replace(old_end, new_end)

with open('lib/features/minigames/presentation/key_escape/key_escape_game.dart', 'w', encoding='utf-8') as f:
    f.write(code)
