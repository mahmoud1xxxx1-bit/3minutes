import re

with open("lib/test_hidden_pigeon_x.dart", "r", encoding="utf-8") as f:
    content = f.read()

content = content.replace("difficulty: MiniGameDifficulty.high", "difficulty: 2")

with open("lib/test_hidden_pigeon_x.dart", "w", encoding="utf-8") as f:
    f.write(content)
