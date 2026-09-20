import re

with open('lib/features/minigames/presentation/mole_strike/mole_strike_game.dart', 'r', encoding='utf-8') as f:
    code = f.read()

# I will fix the fuzzy match mistake.
old = '''          Center(
            child: Transform.translate(
              offset: Offset(shake, 0),
                    mainAxisSpacing: 30,
                    childAspectRatio: 1.0,
                  ),'''

new = '''          Center(
            child: Transform.translate(
              offset: Offset(shake, 0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double boardSize = math.min(constraints.maxWidth, constraints.maxHeight);
                  boardSize = math.min(boardSize * 0.9, 600);
                  return Container(
                    width: boardSize,
                    height: boardSize,
                    padding: const EdgeInsets.all(10),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4, 
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 30,
                        childAspectRatio: 1.0,
                      ),'''

code = code.replace(old, new)

# And close the LayoutBuilder
old_end = '''                  },
                ),
              ),
            ),
            
            for (var m in _mallets)'''

new_end = '''                  },
                ),
                  );
                },
              ),
            ),
            ),
            
            for (var m in _mallets)'''

code = code.replace(old_end, new_end)

with open('lib/features/minigames/presentation/mole_strike/mole_strike_game.dart', 'w', encoding='utf-8') as f:
    f.write(code)
