import glob

paths = glob.glob(r"lib/features/minigames/presentation/mirror_control/painter_a*.dart")
missing_aura = []

for p in paths:
    with open(p, 'r', encoding='utf-8') as f:
        content = f.read()
    if "redAccent" not in content:
        missing_aura.append(p)

missing_aura.sort()
print(f"Stages missing redAccent aura: {len(missing_aura)}")
for m in missing_aura:
    print(m)
