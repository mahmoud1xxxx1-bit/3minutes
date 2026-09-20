import os
import glob
import re

keep = []
paths = glob.glob(r"lib/features/minigames/presentation/mirror_control/painter_a*.dart")
files = [os.path.basename(p) for p in paths]

for f in files:
    keep.append(f)

minigame_path = r"lib/features/minigames/presentation/mirror_control/mirror_control_minigame.dart"
with open(minigame_path, 'r', encoding='utf-8') as f:
    content = f.read()

# First, clean out all old imports
content = re.sub(r'import \'painter_a\d+.*\.dart\';\n', '', content)
imports = []
cases = []
for i in range(1, 106):
    file = [f for f in keep if re.match(rf'painter_a{i}(_.*)?\.dart', f)]
    if file:
        f = file[0]
        with open(os.path.join("lib/features/minigames/presentation/mirror_control", f), 'r', encoding='utf-8') as text:
            m = re.search(r'class\s+(GamePainterA\d+[a-zA-Z0-9_]*)\s+extends', text.read())
            if m:
                imports.append(f"import '{f}';")
                cases.append(f"      case {i}: return {m.group(1)}(engine: engine, images: _images);")
            else:
                print("COULD NOT FIND CLASS IN " + f)

import_block = '\n'.join(imports) + '\n'
content = content.replace("import 'game_engine.dart';", "import 'game_engine.dart';\n" + import_block)

# The default return is at the bottom. We also need to fix that because it returned GamePainterA1 instead of GamePainterA1Forest!
default_class = "GamePainterA1"
for c in cases:
    if "case 1:" in c:
        default_class = c.split("return ")[1].split("(")[0]

# Replace switch block entirely
start_idx = content.find("switch (_stageIndex) {")
end_idx = content.find("    }", start_idx)

new_switch = "switch (_stageIndex) {\n" + '\n'.join(cases) + "\n      default: return " + default_class + "(engine: engine, images: _images);\n"

content = content[:start_idx] + new_switch + content[end_idx:]

with open(minigame_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Fixed registry with proper class names!")
