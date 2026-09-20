from PIL import Image
import os

img_path = r'C:/Users/loved/.gemini/antigravity/brain/14eb05f0-e654-49e3-8d08-001f2e289eae/.user_uploaded/media_1787932640928.png'
out_dir = r'C:/Users/loved/3minutes/assets/images/onet'
os.makedirs(out_dir, exist_ok=True)
img = Image.open(img_path).convert('RGBA')

start_x = 286
start_y = 28
tile_w = 480 / 8
tile_h = 517 / 8

# Selected coordinates for 15 distinct animals
coords = [
    (0,0), # 1: Frog
    (0,1), # 2: Octopus
    (0,2), # 3: Lion
    (0,3), # 4: Deer
    (0,4), # 5: Zebra
    (0,5), # 6: Brown Bear
    (0,7), # 7: Yellow Fish
    (1,0), # 8: Whale
    (1,2), # 9: Snail
    (1,3), # 10: Cow
    (1,6), # 11: Chicken
    (1,7), # 12: Owl
    (2,2), # 13: Fox
    (2,3), # 14: Walrus
    (2,7), # 15: Rabbit
]

animal_id = 1
for r, c in coords:
    x = start_x + c * tile_w
    y = start_y + r * tile_h
    cx, cy = x + tile_w/2, y + tile_h/2 - 2
    crop = img.crop((int(cx - 24), int(cy - 24), int(cx + 24), int(cy + 24)))
    
    data = list(crop.getdata())
    new_data = []
    for item in data:
        if item[0] > 220 and item[1] > 220 and item[2] > 220:
            new_data.append((255, 255, 255, 0))
        else:
            new_data.append(item)
    crop.putdata(new_data)
    crop.save(os.path.join(out_dir, f'animal_{animal_id}.png'))
    animal_id += 1

print(f'Extracted 15 gorgeous animals.')
