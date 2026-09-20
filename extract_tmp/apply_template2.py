from PIL import Image
import os

out_dir = r'C:/Users/loved/3minutes/assets/images/onet_full'
template = Image.open('template_fixed.png').convert('RGBA')

def find_gaps(img, cy=5):
    w, h = img.size
    in_border = False
    start_x = 0
    borders = []
    for x in range(w):
        p = img.getpixel((x, cy))
        is_gap = p[0] < 100 and p[1] < 150 and p[2] < 100
        if is_gap and not in_border:
            in_border = True
            start_x = x
        elif not is_gap and in_border:
            in_border = False
            borders.append((start_x, x - 1))
    if borders[0][0] > 10:
        borders.insert(0, (0, 0))
    if borders[-1][1] < w - 10:
        borders.append((w-1, w-1))
    return borders

def process_row(img_path, tile_ids):
    img = Image.open(img_path).convert('RGBA')
    safe_y = 5
    for y in range(0, 15):
        p = img.getpixel((30, y))
        if p[0] > 240 and p[1] > 240 and p[2] > 240:
            safe_y = y + 1
            break
            
    borders = find_gaps(img, cy=10) if '38462' in img_path or '49948' in img_path else find_gaps(img, cy=6)
    
    # Wait, using cy=10 was bad for row 2 because it hit the animals!
    # I MUST use safe_y for all of them!
    borders = find_gaps(img, cy=safe_y)
    
    for i, t_id in enumerate(tile_ids):
        if t_id is None: continue
        if i + 1 >= len(borders): break
        
        cx = (borders[i][1] + borders[i+1][0]) // 2
        
        y_start = 0
        for y in range(0, 15):
            p = img.getpixel((cx, y))
            if p[0] > 240 and p[1] > 240 and p[2] > 240:
                y_start = y
                break
                
        face = img.crop((cx - 26, y_start, cx + 26, y_start + 63))
        
        new_tile = template.copy()
        new_tile.paste(face, (4, 2), face)
        
        new_tile.save(os.path.join(out_dir, f'tile_{t_id}.png'))

process_row(r'C:/Users/loved/.gemini/antigravity/brain/14eb05f0-e654-49e3-8d08-001f2e289eae/.user_uploaded/media_1787934627474.png', [1, 2, 3, 4, 5, 6, 7, 8])
process_row(r'C:/Users/loved/.gemini/antigravity/brain/14eb05f0-e654-49e3-8d08-001f2e289eae/.user_uploaded/media_1787934638462.png', [9, 10, None, None, None, None, None, 11])
process_row(r'C:/Users/loved/.gemini/antigravity/brain/14eb05f0-e654-49e3-8d08-001f2e289eae/.user_uploaded/media_1787934649948.png', [12, 13, 14, None, 15])
print('Applied FIXED template!')
