import re

with open("lib/test_all_games_1_10.dart", "r", encoding="utf-8") as f:
    content = f.read()

content = content.replace("MiniGameCategory.observation", "MiniGameCategory.precision")

with open("lib/test_all_games_1_10.dart", "w", encoding="utf-8") as f:
    f.write(content)
