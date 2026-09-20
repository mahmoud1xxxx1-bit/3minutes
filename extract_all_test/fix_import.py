import re
file_path = r"lib/features/minigames/presentation/mirror_control/game_engine.dart"
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace("import 'mock/deterministic_rng.dart';", "import '../../../../core/random/deterministic_rng.dart';")

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
