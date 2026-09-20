from PIL import Image
import os

img_path = r'C:/Users/loved/.gemini/antigravity/brain/14eb05f0-e654-49e3-8d08-001f2e289eae/.user_uploaded/media_1787933917552.png'
out_dir = r'C:/Users/loved/3minutes/assets/images/onet_clean'
os.makedirs(out_dir, exist_ok=True)

img = Image.open(img_path).convert('RGBA')

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

start_x = 12
start_y = 11
tile_w = 58.625
tile_h = 71.0

animal_id = 1
for r, c in coords:
    cx = int(start_x + c * tile_w + tile_w/2)
    cy = int(start_y + r * tile_h + 31) # 31 is the visual center of the white area
    
    # Crop exactly 44x44 around cx, cy
    crop = img.crop((cx - 22, cy - 22, cx + 22, cy + 22))
    
    data = list(crop.getdata())
    new_data = []
    for item in data:
        # If it is white-ish, make it transparent
        if item[0] > 220 and item[1] > 220 and item[2] > 220:
            new_data.append((255, 255, 255, 0))
        else:
            new_data.append(item)
    crop.putdata(new_data)
    
    crop.save(os.path.join(out_dir, f'animal_{animal_id}.png'))
    animal_id += 1

print('Done extracting purely by math.')
