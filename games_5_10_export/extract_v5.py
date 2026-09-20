from PIL import Image
import os
import hashlib

img_path = r'C:/Users/loved/.gemini/antigravity/brain/14eb05f0-e654-49e3-8d08-001f2e289eae/.user_uploaded/media_1787933917552.png'
out_dir = r'C:/Users/loved/3minutes/assets/images/onet'
os.makedirs(out_dir, exist_ok=True)

img = Image.open(img_path).convert('RGBA')

start_x = 12
start_y = 11
tile_w = 58.625
tile_h = 71.0

# Coords of 15 unique animals
coords = [
    (0,0), # Monkey
    (0,1), # Blue Cat
    (0,2), # Fox
    (0,3), # Deer
    (0,4), # Polar Bear
    (0,5), # Toucan
    (0,6), # Yellow Fish
    (0,7), # Whale
    (1,0), # Dog
    (1,1), # Turtle
    (1,7), # Snail
    (2,0), # Owl
    (2,1), # Pink Cat
    (2,2), # Shark
    (2,4), # Lion
]

animal_id = 1
for r, c in coords:
    cx = start_x + c * tile_w + tile_w/2
    cy = start_y + r * tile_h + 30 # Slightly above center to avoid green base
    
    # 40x40 crop
    crop = img.crop((int(cx - 20), int(cy - 20), int(cx + 20), int(cy + 20)))
    
    data = list(crop.getdata())
    new_data = []
    for item in data:
        # Make white-ish transparent
        if item[0] > 220 and item[1] > 220 and item[2] > 220:
            new_data.append((255, 255, 255, 0))
        else:
            new_data.append(item)
    crop.putdata(new_data)
    
    crop.save(os.path.join(out_dir, f'animal_{animal_id}.png'))
    animal_id += 1

print(f'Extracted 15 perfect animals.')
