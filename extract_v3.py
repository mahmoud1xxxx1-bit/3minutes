from PIL import Image
import os
import hashlib

img_path = r'C:/Users/loved/.gemini/antigravity/brain/14eb05f0-e654-49e3-8d08-001f2e289eae/.user_uploaded/media_1787932640928.png'
out_dir = r'C:/Users/loved/3minutes/assets/images/onet_v3'
os.makedirs(out_dir, exist_ok=True)

img = Image.open(img_path).convert('RGBA')

start_x = 286
start_y = 28
tile_w = 480 / 8
tile_h = 517 / 8

unique_hashes = set()
animal_id = 1

for r in range(8):
    for c in range(8):
        x = start_x + c * tile_w
        y = start_y + r * tile_h
        
        # Crop the center 46x46
        cx, cy = x + tile_w/2, y + tile_h/2 - 2
        crop = img.crop((int(cx - 22), int(cy - 22), int(cx + 22), int(cy + 22)))
        
        # Hash the crop to see if we already have it
        data = list(crop.getdata())
        h = hashlib.md5(str(data).encode()).hexdigest()
        
        if h not in unique_hashes:
            unique_hashes.add(h)
            
            # Make white transparent
            new_data = []
            for item in data:
                if item[0] > 220 and item[1] > 220 and item[2] > 220:
                    new_data.append((255, 255, 255, 0))
                else:
                    new_data.append(item)
            crop.putdata(new_data)
            
            crop.save(os.path.join(out_dir, f'animal_{animal_id}.png'))
            animal_id += 1

print(f'Extracted {animal_id - 1} unique animals.')
