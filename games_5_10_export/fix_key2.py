import re

with open('lib/features/minigames/presentation/key_escape/key_escape_game.dart', 'r', encoding='utf-8') as f:
    code = f.read()

# Let's find the Column that has the game UI
code = re.sub(
    r'Center\(\s*child: Column\(\s*mainAxisAlignment: MainAxisAlignment\.center,\s*children: \[',
    'Center(\n            child: Column(\n              mainAxisAlignment: MainAxisAlignment.center,\n              children: [',
    code
)

# Replace the broken LayoutBuilder logic:
code = re.sub(
    r'const SizedBox\(height: 30\),\s*clipBehavior: Clip\.none,',
    '''const SizedBox(height: 30),
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
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFF5D2E8C), width: 6),
                              boxShadow: [
                                BoxShadow(color: const Color(0xFF5D2E8C).withOpacity(0.5), blurRadius: 30, spreadRadius: 10),
                              ],
                            ),
                            child: Stack(
                              clipBehavior: Clip.none,''',
    code
)

code = re.sub(
    r'                     \],\n\s*\),\n\s*\],\n\s*\);\n\s*\}\n',
    '''                          ],
                        ),
                      ),
                    );
                  },
                ),
                ),
                ),
              ],
            ),
          ),
        ],
      );
    }
''',
    code
)

with open('lib/features/minigames/presentation/key_escape/key_escape_game.dart', 'w', encoding='utf-8') as f:
    f.write(code)
