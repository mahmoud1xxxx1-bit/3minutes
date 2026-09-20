import re

with open("lib/features/minigames/presentation/hidden_pigeon/hidden_pigeon_game.dart", "r", encoding="utf-8") as f:
    content = f.read()

# Fix MinigameEnvironment and config
content = content.replace("import '../shared/minigame_environment.dart';", "")

content = re.sub(
    r"return MinigameEnvironment\(\n\s*config: widget\.config,\n\s*child: Column\(",
    "return Column(",
    content, flags=re.DOTALL
)

# Fix Result signature
content = re.sub(
    r"widget\.onComplete\(MiniGameResult\(stars: stars, timeMilliseconds: ms\)\);",
    "widget.onComplete(MiniGameResult(completed: true, score: 0, accuracy: 1.0, mistakes: _totalMistakes, duration: Duration(milliseconds: ms)));",
    content
)

# Fix string interpolation
content = content.replace("Text('\\'", "Text(''")
content = content.replace("Text('\\\\n", "Text('\\n")
content = content.replace("Text('\\'", "Text('\'")

with open("lib/features/minigames/presentation/hidden_pigeon/hidden_pigeon_game.dart", "w", encoding="utf-8") as f:
    f.write(content)
