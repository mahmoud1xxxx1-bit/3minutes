import re

with open("lib/features/minigames/presentation/hidden_pigeon/hidden_pigeon_game.dart", "r", encoding="utf-8") as f:
    content = f.read()

# Add import
if "import 'hidden_pigeon_backgrounds.dart';" not in content:
    content = content.replace("import 'pigeon_painter.dart';", "import 'pigeon_painter.dart';\nimport 'hidden_pigeon_backgrounds.dart';")

# Replace Image.asset with CustomPaint
old_code = """                                // Temporary safe placeholders from user's assets
                                child: Image.asset(
                                  'assets/hidden_pigeon/round_.png',
                                  fit: BoxFit.cover,
                                ),"""

new_code = """                                child: CustomPaint(
                                  size: Size.infinite,
                                  painter: PigeonBackgroundPainter(_roundIndex),
                                ),"""

content = content.replace(old_code, new_code)

with open("lib/features/minigames/presentation/hidden_pigeon/hidden_pigeon_game.dart", "w", encoding="utf-8") as f:
    f.write(content)
