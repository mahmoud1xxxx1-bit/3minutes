import glob, re
paths = glob.glob(r"lib/features/minigames/presentation/mirror_control/painter_a*.dart")
keys = set()
for p in paths:
    with open(p, 'r', encoding='utf-8') as f:
        content = f.read()
    matches = re.findall(r"images\[['\"](.*?)['\"]\]", content)
    if matches:
        for m in matches:
            keys.add(m)
print(f"Used keys: {keys}")
