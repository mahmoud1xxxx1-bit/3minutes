from PIL import Image
import os

out_dir = r'C:/Users/loved/3minutes/assets/images/onet_full'
template = Image.open('template.png').convert('RGBA')

def process_row(img_path, tile_ids):
    img = Image.open(img_path).convert('RGBA')
    w, h = img.size
    
    # Find the safe y to scan for gaps by looking for white face near x=30
    safe_y = 5
    for y in range(0, 15):
        p = img.getpixel((30, y))
        if p[0] > 240 and p[1] > 240 and p[2] > 240:
            safe_y = y + 1
            break
            
    print(f'Using safe_y={safe_y} for {img_path}')
    
    in_border = False
    start_x = 0
    borders = []
    for x in range(w):
        p = img.getpixel((x, safe_y))
        # The gap is dark green, but the white face is white.
        # Any pixel that is NOT white and NOT the animal (because safe_y is above animal) is a gap!
        # Actually, the gap is < 100, 150, 100
        is_gap = p[0] < 100 and p[1] < 150 and p[2] < 100
        if is_gap and not in_border:
            in_border = True
            start_x = x
        elif not is_gap and in_border:
            in_border = False
            borders.append((start_x, x - 1))
            
    if len(borders) > 0 and borders[0][0] > 10:
        borders.insert(0, (0, 0))
    if len(borders) > 0 and borders[-1][1] < w - 10:
        borders.append((w-1, w-1))
        
    print(f'Found {len(borders)} borders: {borders}')
        
    for i, t_id in enumerate(tile_ids):
        if t_id is None: continue
        if i + 1 >= len(borders): break
        
        cx = (borders[i][1] + borders[i+1][0]) // 2
        
        # Find the start of the white face (y_start) for this specific cx
        y_start = 0
        for y in range(0, 15):
            p = img.getpixel((cx, y))
            if p[0] > 240 and p[1] > 240 and p[2] > 240:
                y_start = y
                break
                
        # Crop the 52x63 white face + animal
        # cx-26 is 52 wide
        face = img.crop((cx - 26, y_start, cx + 26, y_start + 63))
        
        # Paste into a fresh copy of the template at (4, 2)
        new_tile = template.copy()
        new_tile.paste(face, (4, 2), face)
        
        new_tile.save(os.path.join(out_dir, f'tile_{t_id}.png'))
        print(f'Saved PERFECT tile_{t_id}.png! (cx={cx}, y_start={y_start})')

process_row(r'C:/Users/loved/.gemini/antigravity/brain/14eb05f0-e654-49e3-8d08-001f2e289eae/.user_uploaded/media_1787934627474.png', [1, 2, 3, 4, 5, 6, 7, 8])
process_row(r'C:/Users/loved/.gemini/antigravity/brain/14eb05f0-e654-49e3-8d08-001f2e289eae/.user_uploaded/media_1787934638462.png', [9, 10, None, None, None, None, None, 11])
process_row(r'C:/Users/loved/.gemini/antigravity/brain/14eb05f0-e654-49e3-8d08-001f2e289eae/.user_uploaded/media_1787934649948.png', [12, 13, 14, None, 15])

