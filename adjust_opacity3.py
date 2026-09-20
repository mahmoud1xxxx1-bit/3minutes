import re

with open("lib/features/minigames/presentation/hidden_pigeon/hidden_pigeon_game.dart", "r", encoding="utf-8") as f:
    content = f.read()

content = content.replace(
    "opacity: 0.8,",
    "opacity: 1.0,"
)

with open("lib/features/minigames/presentation/hidden_pigeon/hidden_pigeon_game.dart", "w", encoding="utf-8") as f:
    f.write(content)
