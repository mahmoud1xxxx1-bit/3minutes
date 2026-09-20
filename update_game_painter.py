import re

with open("lib/features/minigames/presentation/hidden_pigeon/hidden_pigeon_game.dart", "r", encoding="utf-8") as f:
    content = f.read()

content = content.replace(
    "import 'hidden_pigeon_backgrounds.dart';",
    "import 'master_pigeon_painter.dart';"
)

content = content.replace(
    "painter: PigeonBackgroundPainter(_plan.seed, _roundIndex),",
    "painter: MasterPigeonPainter(_plan.seed, _roundIndex),"
)

with open("lib/features/minigames/presentation/hidden_pigeon/hidden_pigeon_game.dart", "w", encoding="utf-8") as f:
    f.write(content)
