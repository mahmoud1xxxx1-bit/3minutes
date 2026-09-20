import re

with open("lib/features/minigames/presentation/mini_game_host.dart", "r", encoding="utf-8") as f:
    content = f.read()

if "import 'hidden_pigeon/hidden_pigeon_game.dart';" not in content:
    content = content.replace(
        "import 'traffic_loop/traffic_loop_game.dart';",
        "import 'traffic_loop/traffic_loop_game.dart';\nimport 'hidden_pigeon/hidden_pigeon_game.dart';"
    )

content = re.sub(
    r"case 'traffic_loop':\n\s*child = FlawlessTrafficEngine\(config: config, onComplete: _handleComplete\);\n\s*break;",
    "case 'traffic_loop':\n        child = FlawlessTrafficEngine(config: config, onComplete: _handleComplete);\n        break;\n      case 'hidden_pigeon':\n        child = HiddenPigeonGame(config: config, onComplete: _handleComplete);\n        break;",
    content
)

with open("lib/features/minigames/presentation/mini_game_host.dart", "w", encoding="utf-8") as f:
    f.write(content)
