import re

with open("lib/features/minigames/presentation/hidden_pigeon/hidden_pigeon_game.dart", "r", encoding="utf-8") as f:
    content = f.read()

# Fix the import path. The file is in lib/features/minigames/presentation/hidden_pigeon/hidden_pigeon_game.dart
# We want lib/features/minigames_VBN/presentation/mini_game_copy.dart
content = content.replace(
    "import '../../../../minigames_VBN/presentation/mini_game_copy.dart';",
    "import '../../../minigames_VBN/presentation/mini_game_copy.dart';"
)

# Fix the syntax error ),,
content = content.replace("),,", "),")

with open("lib/features/minigames/presentation/hidden_pigeon/hidden_pigeon_game.dart", "w", encoding="utf-8") as f:
    f.write(content)
