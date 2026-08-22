import os
import glob
import re

keep = []
delete = []
paths = glob.glob(r"lib/features/minigames/presentation/mirror_control/painter_a*.dart")
files = [os.path.basename(p) for p in paths]

grouped = {}
for f in files:
    m = re.match(r'painter_a(\d+)', f)
    if m:
        num = int(m.group(1))
        if num not in grouped: grouped[num] = []
        grouped[num].append(f)

for num, group in grouped.items():
    if len(group) == 1: keep.append(group[0])
    else:
        for f in group:
            if re.match(r'painter_a\d+\.dart', f): delete.append(f)
            else: keep.append(f)

for d in delete:
    try:
        os.remove(os.path.join("lib/features/minigames/presentation/mirror_control", d))
        print(f"Deleted {d}")
    except: pass

minigame_path = r"lib/features/minigames/presentation/mirror_control/mirror_control_minigame.dart"
with open(minigame_path, 'r', encoding='utf-8') as f:
    content = f.read()

content = re.sub(r'import \'painter_a\d+.*\.dart\';\n', '', content)
imports = []
cases = []
for i in range(1, 106):
    file = [f for f in keep if re.match(rf'painter_a{i}(_.*)?\.dart', f)]
    if file:
        f = file[0]
        with open(os.path.join("lib/features/minigames/presentation/mirror_control", f), 'r', encoding='utf-8') as text:
            m = re.search(r'class\s+(GamePainterA\d+)\s+extends', text.read())
            if m:
                imports.append(f"import '{f}';")
                cases.append(f"      case {i}: return {m.group(1)}(engine: engine, images: _images);")

import_block = '\n'.join(imports) + '\n'
content = content.replace("import 'game_engine.dart';", "import 'game_engine.dart';\n" + import_block)

content = re.sub(r'switch \(_stageIndex\) \{.*?\n\s+default:', "switch (_stageIndex) {\n" + '\n'.join(cases) + "\n      default:", content, flags=re.DOTALL)

with open(minigame_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Updated mirror_control_minigame.dart")
