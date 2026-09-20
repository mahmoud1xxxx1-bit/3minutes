import re

file_path = r"c:\Users\loved\3minutes\lib\features\minigames\presentation\mirror_control\mirror_control_minigame.dart"
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Add the import
import_stmt = "import '../../domain/mini_game_contract.dart';\n"
if import_stmt not in content:
    content = content.replace("import 'game_engine.dart';", "import 'game_engine.dart';\n" + import_stmt)

# Remove Dummy Classes using regex that matches the specific known bodies
content = re.sub(r'class MiniGameConfig\s*\{.*?\n\}\n', '', content, flags=re.DOTALL)
content = re.sub(r'class MiniGameResult\s*\{.*?\n\}\n', '', content, flags=re.DOTALL)

# Also fix the asset path to point to the new location
content = content.replace("'assets/images/a1/player.png'", "'assets/mirror_control/player.png'")
content = content.replace("'assets/images/a1/enemy.png'", "'assets/mirror_control/enemy.png'")
content = content.replace("'assets/images/a1/target.png'", "'assets/mirror_control/target.png'")

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Fixed imports and assets path!")
