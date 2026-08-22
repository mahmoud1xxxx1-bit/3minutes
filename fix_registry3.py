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

# We need to replace `CustomPainter _getPainterForTheme(String theme) { ... }` up to the next method or end of class.
# Actually, wait. Let's just strip everything from `CustomPainter _getPainterForTheme` to `Widget build(BuildContext context)`

start_idx = content.find("CustomPainter _getPainterForTheme(String theme) {")
end_idx = content.find("  @override", start_idx)

cases = []
for i in range(1, 106):
    file = [f for f in keep if re.match(rf'painter_a{i}(_.*)?\.dart', f)]
    if file:
        f = file[0]
        with open(os.path.join("lib/features/minigames/presentation/mirror_control", f), 'r', encoding='utf-8') as text:
            m = re.search(r'class\s+(GamePainterA\d+[a-zA-Z0-9_]*)\s+extends', text.read())
            if m:
                cases.append(f"    if (theme == 'a{i}') return {m.group(1)}(engine: engine, images: _images);")

new_func = "  CustomPainter _getPainterForTheme(String theme) {\n" + '\n'.join(cases) + "\n    return GamePainterA1Forest(engine: engine, images: _images);\n  }\n\n"

content = content[:start_idx] + new_func + content[end_idx:]

# And we need to remove that hallucinated switch block at the bottom
bad_idx = content.find("} \n  CustomPainter getPainter() {\n    switch (_stageIndex) {")
if bad_idx != -1:
    content = content[:bad_idx] + "}\n"

with open(minigame_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Fixed _getPainterForTheme!")
