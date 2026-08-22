import os

files = [
    "lib/features/minigames/presentation/follow_the_cup/follow_the_cup_game.dart",
    "lib/features/minigames/presentation/mole_strike/mole_strike_game.dart",
    "lib/features/minigames/presentation/path_rush/path_rush_game.dart"
]

for path in files:
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Replace single dot relative imports with double dot
    content = content.replace("import '../domain/", "import '../../domain/")
    
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)
