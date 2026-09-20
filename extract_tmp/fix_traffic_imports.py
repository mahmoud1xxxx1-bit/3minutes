import os

path = "lib/features/minigames/presentation/traffic_loop/traffic_loop_game.dart"
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace("import '../../../core/ui/theme.dart';\n", "")
content = content.replace("final copy = MiniGameCopy.of(context);", "final copy = MiniGameCopy.fromContext(context);")

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)
