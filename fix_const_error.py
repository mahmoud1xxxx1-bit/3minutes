import re

with open("lib/features/minigames/presentation/hidden_pigeon/hidden_pigeon_game.dart", "r", encoding="utf-8") as f:
    content = f.read()

# Fix the const errors
content = content.replace(
    "const Icon(Icons.search, color: Colors.white.withOpacity(0.75), size: 32)",
    "Icon(Icons.search, color: Colors.white.withOpacity(0.75), size: 32)"
)

content = content.replace(
    "const TextStyle(color: Colors.white.withOpacity(0.75),",
    "TextStyle(color: Colors.white.withOpacity(0.75),"
)

with open("lib/features/minigames/presentation/hidden_pigeon/hidden_pigeon_game.dart", "w", encoding="utf-8") as f:
    f.write(content)
