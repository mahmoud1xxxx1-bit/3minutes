import re

with open("lib/features/minigames/presentation/hidden_pigeon/hidden_pigeon_game.dart", "r", encoding="utf-8") as f:
    content = f.read()

content = content.replace(
    "opacity: 0.8 - (_roundIndex * 0.2), // 0.8, 0.6, 0.4",
    "opacity: _roundIndex == 0 ? 0.5 : (_roundIndex == 1 ? 0.3 : 0.2),"
)

with open("lib/features/minigames/presentation/hidden_pigeon/hidden_pigeon_game.dart", "w", encoding="utf-8") as f:
    f.write(content)
