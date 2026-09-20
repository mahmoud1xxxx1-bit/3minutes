import re

with open("lib/features/minigames/presentation/hidden_pigeon/hidden_pigeon_game.dart", "r", encoding="utf-8") as f:
    content = f.read()

content = content.replace(
    "opacity: roundIndex == 0 ? 0.7 : (roundIndex == 1 ? 0.5 : 0.3),",
    "opacity: roundIndex == 0 ? 0.8 : (roundIndex == 1 ? 0.7 : 0.6),"
)

with open("lib/features/minigames/presentation/hidden_pigeon/hidden_pigeon_game.dart", "w", encoding="utf-8") as f:
    f.write(content)
