import os

path = "lib/features/minigames/presentation/find_differences/find_differences_game.dart"
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

old_logic = "if (difference.hitBox.contains(Offset(logicalX, logicalY))) {"
new_logic = "if (difference.hitBox.inflate(30.0).contains(Offset(logicalX, logicalY))) {"

content = content.replace(old_logic, new_logic)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)
