import os
import re

path = "lib/features/minigames/presentation/mini_game_host.dart"
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

# Update imports
content = content.replace("import 'follow_the_cup_game.dart';", "import 'follow_the_cup/follow_the_cup_game.dart';")
content = content.replace("import 'mole_strike_game.dart';", "import 'mole_strike/mole_strike_game.dart';")
content = content.replace("import 'path_rush_game.dart';", "import 'path_rush/path_rush_game.dart';")
content = content.replace("import 'legacy_mini_game_host.dart' as legacy;\n", "")

# Remove legacy fallback
old_fallback = """    return legacy.MiniGameHost(
      game: game,
      config: config,
      onComplete: onComplete,
    );"""
new_fallback = """    return const Center(child: Text('Game not found'));"""
content = content.replace(old_fallback, new_fallback)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)
