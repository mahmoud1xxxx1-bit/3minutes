import glob
paths = glob.glob(r"lib/features/minigames/presentation/mirror_control/painter_a*.dart")
missing_enemy = []
missing_player = []
for p in paths:
    with open(p, 'r', encoding='utf-8') as f:
        content = f.read()
    if "images!['enemy']" not in content:
        missing_enemy.append(p)
    if "images!['player']" not in content:
        missing_player.append(p)
print(f"Missing enemy: {missing_enemy}")
print(f"Missing player: {missing_player}")
