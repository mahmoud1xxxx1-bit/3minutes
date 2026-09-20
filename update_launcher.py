import re

with open("lib/test_all_games_1_10.dart", "r", encoding="utf-8") as f:
    content = f.read()

# Add import
if "import 'features/minigames/presentation/hidden_pigeon/hidden_pigeon_game.dart';" not in content:
    content = content.replace(
        "import 'features/minigames/presentation/traffic_loop/traffic_loop_game.dart';",
        "import 'features/minigames/presentation/traffic_loop/traffic_loop_game.dart';\nimport 'features/minigames/presentation/hidden_pigeon/hidden_pigeon_game.dart';"
    )

# Add to the games list
content = re.sub(
    r"\('traffic_loop', 'Traffic Loop', Icons\.all_inclusive\),",
    "('traffic_loop', 'Traffic Loop', Icons.all_inclusive),\n    ('hidden_pigeon', 'Hidden Pigeon', Icons.search),",
    content
)

# Add to the switch statement
content = re.sub(
    r"case 'traffic_loop':\n          child = FlawlessTrafficEngine\(config: config, onComplete: \(r\) \{.*?\};\n          break;",
    r"case 'traffic_loop':\n          child = FlawlessTrafficEngine(config: config, onComplete: (r) {});\n          break;\n        case 'hidden_pigeon':\n          child = HiddenPigeonGame(config: config, onComplete: (r) { print(r); });\n          break;",
    content, flags=re.DOTALL
)

with open("lib/test_all_games_1_10.dart", "w", encoding="utf-8") as f:
    f.write(content)
