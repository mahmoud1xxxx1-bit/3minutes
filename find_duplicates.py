import os
import glob
import re

paths = glob.glob(r"lib/features/minigames/presentation/mirror_control/painter_a*.dart")
files = [os.path.basename(p) for p in paths]

keep = []
delete = []

grouped = {}
for f in files:
    m = re.match(r'painter_a(\d+)', f)
    if m:
        num = int(m.group(1))
        if num not in grouped:
            grouped[num] = []
        grouped[num].append(f)

for num, group in grouped.items():
    if len(group) == 1:
        keep.append(group[0])
    else:
        for f in group:
            if re.match(r'painter_a\d+\.dart', f):
                delete.append(f)
            else:
                keep.append(f)

print(f"Total keep: {len(keep)}")
print(f"Total delete: {len(delete)}")

imports = []
cases = []
for i in range(1, 106):
    file = [f for f in keep if re.match(rf'painter_a{i}(_.*)?\.dart', f)]
    if file:
        f = file[0]
        with open(os.path.join("lib/features/minigames/presentation/mirror_control", f), 'r', encoding='utf-8') as text:
            content = text.read()
            m = re.search(r'class\s+(GamePainterA\d+)\s+extends', content)
            if m:
                cls = m.group(1)
                imports.append(f"import '{f}';")
                cases.append(f"      case {i}: return {cls}(engine: engine, images: _images);")

with open('fix_registry.txt', 'w', encoding='utf-8') as f:
    f.write('\n'.join(imports) + '\n\n')
    f.write('\n'.join(cases))
    f.write('\n\nDelete:\n' + '\n'.join(delete))

print("Wrote fix_registry.txt")
