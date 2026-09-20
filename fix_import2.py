import re

with open("lib/test_hidden_pigeon_x.dart", "r", encoding="utf-8") as f:
    content = f.read()

content = content.replace("import 'features/minigames/domain/mini_game_config.dart';\n", "")

with open("lib/test_hidden_pigeon_x.dart", "w", encoding="utf-8") as f:
    f.write(content)
