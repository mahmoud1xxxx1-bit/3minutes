from PIL import Image
import os

out_dir = r'C:/Users/loved/3minutes/assets/images/onet_full'
os.makedirs(out_dir, exist_ok=True)

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

def extract_tiles(img_path, tile_ids):
    img = Image.open(img_path).convert('RGBA')
    borders = find_gaps(img, cy=5)
    
    for i, t_id in enumerate(tile_ids):
        if t_id is None: continue
        if i + 1 >= len(borders): break
        
        gap_left = borders[i]
        gap_right = borders[i+1]
        
        cx = (gap_left[1] + gap_right[0]) // 2
        
        left = cx - 30
        right = cx + 30
        top = 0
        bottom = 80
        
        if left < 0:
            left = 0
            right = 60
        if right > img.size[0]:
            right = img.size[0]
            left = right - 60
            
        crop = img.crop((left, top, right, bottom))
        
        # Now let's try to flood fill the corners to make them transparent!
        # The tiles are rounded. The corners are at (0,0), (59,0), (0,79), (59,79).
        # We can just check if these corners are dark green, and make them transparent!
        # Actually, let's just use a simple corner mask!
        # The corners have a radius of ~6 pixels.
        # Let's just make the 4x4 corners transparent if they are dark.
        data = list(crop.getdata())
        new_data = []
        w, h = crop.size
        for idx, p in enumerate(data):
            x = idx % w
            y = idx // w
            is_corner = (x < 4 or x > w-5) and (y < 4 or y > h-5)
            # if it's a corner and it's dark green/black, make it transparent
            if is_corner and p[0] < 60 and p[1] < 100 and p[2] < 60:
                new_data.append((0,0,0,0))
            else:
                new_data.append(p)
        crop.putdata(new_data)
        
        crop.save(os.path.join(out_dir, f'tile_{t_id}.png'))
        print(f'Saved tile_{t_id}.png from {img_path} at cx={cx}')

extract_tiles(r'C:/Users/loved/.gemini/antigravity/brain/14eb05f0-e654-49e3-8d08-001f2e289eae/.user_uploaded/media_1787934627474.png', [1, 2, 3, 4, 5, 6, 7, 8])
extract_tiles(r'C:/Users/loved/.gemini/antigravity/brain/14eb05f0-e654-49e3-8d08-001f2e289eae/.user_uploaded/media_1787934638462.png', [9, 10, None, None, None, None, None, 11])
extract_tiles(r'C:/Users/loved/.gemini/antigravity/brain/14eb05f0-e654-49e3-8d08-001f2e289eae/.user_uploaded/media_1787934649948.png', [12, 13, 14, None, 15])

print('Perfect equal 60x80 tiles extracted with dynamic borders and transparent corners!')
