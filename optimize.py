import glob
import re

paths = glob.glob(r"lib/features/minigames/presentation/mirror_control/painter_a*.dart")

for p in paths:
    with open(p, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original = content
    
    # Increase small steps in for loops
    # matches: for(double x = 0; x < 1000; x+=5)
    def replacer(m):
        var = m.group(1)
        step = int(m.group(2))
        if step <= 2: new_step = 10
        elif step <= 10: new_step = 40
        elif step <= 25: new_step = 60
        else: new_step = step
        return f"{var}+={new_step}"
    
    content = re.sub(r'([a-zA-Z0-9_]+)\s*\+=\s*(\d+)', replacer, content)
    
    # Also optimize MaskFilter.blur which is extremely heavy
    # MaskFilter.blur(BlurStyle.normal, 15) -> MaskFilter.blur(BlurStyle.normal, 2)
    def blur_replacer(m):
        val = float(m.group(1))
        if val > 5:
            return f"MaskFilter.blur(BlurStyle.normal, 3)"
        return m.group(0)
        
    content = re.sub(r'MaskFilter\.blur\([^,]+,\s*([0-9.]+)\)', blur_replacer, content)
    
    if content != original:
        with open(p, 'w', encoding='utf-8') as f:
            f.write(content)

print("Optimized loops and blurs in all files!")
