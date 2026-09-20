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
        
        # FLOOD FILL to make white background transparent
        w, h = face.size
        data = list(face.getdata())
        new_data = data.copy()
        
        visited = set()
        q = [(0,0), (w-1,0), (0,h-1), (w-1,h-1)]
        
        def is_similar(p, target, tol=20):
            return abs(p[0]-target[0]) < tol and abs(p[1]-target[1]) < tol and abs(p[2]-target[2]) < tol

        bg_color = (255, 255, 255, 255)
        
        while q:
            x, y = q.pop(0)
            if (x, y) in visited: continue
            visited.add((x, y))
            
            idx = y * w + x
            p = data[idx]
            
            if is_similar(p, bg_color):
                new_data[idx] = (0, 0, 0, 0)
                if x > 0: q.append((x-1, y))
                if x < w-1: q.append((x+1, y))
                if y > 0: q.append((x, y-1))
                if y < h-1: q.append((x, y+1))
                
        face.putdata(new_data)
        
        new_tile = template.copy()
        new_tile.paste(face, (4, 2), face)
        
        new_tile.save(os.path.join(out_dir, f'tile_{t_id}.png'))
        print(f'Saved ULTRA PERFECT tile_{t_id}.png')

process_row(r'C:/Users/loved/.gemini/antigravity/brain/14eb05f0-e654-49e3-8d08-001f2e289eae/.user_uploaded/media_1787934627474.png', [1, 2, 3, 4, 5, 6, 7, 8])
process_row(r'C:/Users/loved/.gemini/antigravity/brain/14eb05f0-e654-49e3-8d08-001f2e289eae/.user_uploaded/media_1787934638462.png', [9, 10, None, None, None, None, None, 11])
process_row(r'C:/Users/loved/.gemini/antigravity/brain/14eb05f0-e654-49e3-8d08-001f2e289eae/.user_uploaded/media_1787934649948.png', [12, 13, 14, None, 15])
print('Applied ULTRA FIXED template!')
