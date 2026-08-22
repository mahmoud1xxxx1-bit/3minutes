import os

path = "lib/features/minigames/presentation/find_differences/find_differences_game.dart"
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace("copy.findDifferencesFound", "copy.followCupCorrect")

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)
