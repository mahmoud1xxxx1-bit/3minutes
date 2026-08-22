import glob
paths = glob.glob(r"lib/features/minigames/presentation/mirror_control/painter_a*.dart")
missing = []
for p in paths:
    with open(p, 'r', encoding='utf-8') as f:
        content = f.read()
    if 'exitGate' not in content:
        missing.append(p)
print(f"Painters missing exitGate: {len(missing)}")
for m in missing:
    print(m)
