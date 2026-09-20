import re

with open("lib/features/minigames/presentation/hidden_pigeon/hidden_pigeon_game.dart", "r", encoding="utf-8") as f:
    content = f.read()

content = content.replace(
    "final double pigeonSize = 40.0;",
    "final double pigeonSize = 40.0 - (_roundIndex * 6.0); // 40, 34, 28"
)

content = content.replace(
    "opacity: 0.8,",
    "opacity: 0.8 - (_roundIndex * 0.2), // 0.8, 0.6, 0.4"
)

with open("lib/features/minigames/presentation/hidden_pigeon/hidden_pigeon_game.dart", "w", encoding="utf-8") as f:
    f.write(content)
