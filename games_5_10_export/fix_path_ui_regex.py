import os
import re

path = "lib/features/minigames/presentation/path_rush/path_rush_game.dart"
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

# Replace the specific UI lines for path rush using regex to ignore whitespace differences
content = re.sub(
    r"_PathPill\(label:\s*'\$\{copy\.pathRushRound\}:\s*\$\{_roundIndex\s*\+\s*1\}/3'\)",
    r"_PathPill(label: '${copy.followCupCorrect}: ${_correct}/3')",
    content
)

content = re.sub(
    r"_PathPill\(label:\s*'F\$family'\)",
    r"_PathPill(label: '${copy.findDifferencesMistakes}: $_mistakes')",
    content
)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)
