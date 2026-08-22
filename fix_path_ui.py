import os
import re

path = "lib/features/minigames/presentation/path_rush/path_rush_game.dart"
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace("import 'mini_game_copy.dart';", "import '../mini_game_copy.dart';")

old_row = """          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PathPill(label: '${copy.pathRushRound}: ${_roundIndex + 1}/3'),
              const SizedBox(width: 8),
              _PathPill(label: 'F$family'),
            ],
          ),"""

new_row = """          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PathPill(label: '${copy.followCupCorrect}: ${_correct}/3'),
              const SizedBox(width: 8),
              _PathPill(label: '${copy.findDifferencesMistakes}: $_mistakes'),
            ],
          ),"""

content = content.replace(old_row, new_row)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)
