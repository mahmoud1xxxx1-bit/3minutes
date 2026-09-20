import glob

paths = glob.glob(r"lib/features/minigames/presentation/mirror_control/painter_a*.dart")
heavy_loops = []

for p in paths:
    with open(p, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Check for dense loops like i += 10 or x += 5 up to fieldSize
    import re
    if re.search(r'for\s*\([^;]+;\s*[^;]+;\s*[a-zA-Z]+\s*\+=\s*(?:[1-9]|1[0-9])\s*\)', content):
        heavy_loops.append(p)
    elif "canvas.saveLayer" in content:
        # Save layer is heavy but maybe it's targeted? Let's flag ones with more than 1 saveLayer
        if content.count("canvas.saveLayer") > 1:
            heavy_loops.append(p)

heavy_loops.sort()
print(f"Stages with potentially heavy loops/rendering: {len(heavy_loops)}")
for m in heavy_loops:
    print(m)
