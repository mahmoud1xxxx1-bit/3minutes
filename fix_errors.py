import re

with open("lib/features/minigames/domain/hidden_pigeon_plan.dart", "r", encoding="utf-8") as f:
    content = f.read()

# Add seed to HiddenPigeonPlan
if "final int seed;" not in content:
    content = content.replace(
        "class HiddenPigeonPlan {",
        "class HiddenPigeonPlan {\n  final int seed;"
    )
    content = content.replace(
        "HiddenPigeonPlan({required this.rounds});",
        "HiddenPigeonPlan({required this.seed, required this.rounds});"
    )
    content = content.replace(
        "return HiddenPigeonPlan(",
        "return HiddenPigeonPlan(seed: seed,"
    )

with open("lib/features/minigames/domain/hidden_pigeon_plan.dart", "w", encoding="utf-8") as f:
    f.write(content)

# Fix test_hidden_pigeon_x.dart
with open("lib/test_hidden_pigeon_x.dart", "r", encoding="utf-8") as f:
    content2 = f.read()

content2 = content2.replace("'X\\',", "'X',")
if "import 'package:game/features/minigames/domain/mini_game_contract.dart';" not in content2:
    content2 = content2.replace(
        "import 'features/minigames/domain/mini_game_contract.dart';",
        "import 'features/minigames/domain/mini_game_contract.dart';\nimport 'features/minigames/domain/mini_game_config.dart';"
    )

with open("lib/test_hidden_pigeon_x.dart", "w", encoding="utf-8") as f:
    f.write(content2)
