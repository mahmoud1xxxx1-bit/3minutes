import os
import re

path = "lib/features/minigames/presentation/mole_strike/mole_strike_game.dart"
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace("import 'mini_game_copy.dart';", "import '../mini_game_copy.dart';")

old_row = """      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _StatusPill(label: '${copy.moleStrikeHits}: $_hits/${MoleStrikePlan.goal}'),
        const SizedBox(width: 8), _StatusPill(label: 'F$family'),
      ]),"""

new_row = """      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _StatusPill(label: '${copy.followCupCorrect}: $_hits/${MoleStrikePlan.goal}'),
        const SizedBox(width: 8),
        _StatusPill(label: '${copy.findDifferencesMistakes}: $_mistakes'),
      ]),"""

content = content.replace(old_row, new_row)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)
