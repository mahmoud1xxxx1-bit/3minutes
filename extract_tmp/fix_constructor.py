import glob
import re

paths = glob.glob(r"lib/features/minigames/presentation/mirror_control/painter_a*.dart")

for p in paths:
    with open(p, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original = content
    
    # Fix constructor
    content = re.sub(r'(\{required this\.engine\}\);)', r'{required this.engine, this.images});', content)
    
    # Add field
    if 'final Map<String, ui.Image>? images;' not in content:
        content = re.sub(r'(final GameEngine engine;)', r'\1\n  final Map<String, ui.Image>? images;', content)
        
    if content != original:
        with open(p, 'w', encoding='utf-8') as f:
            f.write(content)

print("Fixed missing images field in all files!")
