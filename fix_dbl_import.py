import re

with open("lib/features/minigames/presentation/hidden_pigeon/hidden_pigeon_game.dart", "r", encoding="utf-8") as f:
    content = f.read()

content = content.replace("import 'hidden_pigeon_backgrounds.dart';\nimport 'hidden_pigeon_backgrounds.dart';", "import 'hidden_pigeon_backgrounds.dart';")

with open("lib/features/minigames/presentation/hidden_pigeon/hidden_pigeon_game.dart", "w", encoding="utf-8") as f:
    f.write(content)
