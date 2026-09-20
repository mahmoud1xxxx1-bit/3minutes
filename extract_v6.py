from PIL import Image
import os

img_path = r'C:/Users/loved/.gemini/antigravity/brain/14eb05f0-e654-49e3-8d08-001f2e289eae/.user_uploaded/media_1787933917552.png'
out_dir = r'C:/Users/loved/3minutes/assets/images/onet'
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
    # Get the rough center of the tile
    cx = int(start_x + c * tile_w + tile_w/2)
    cy = int(start_y + r * tile_h + 33)
    
    # We want to crop the inner animal, avoiding the black borders.
    # The animal is bounded by the white background.
    # Let's search left, right, top, bottom from the center to find the black borders, then step in.
    
    # Actually, the white face is clearly bounded.
    # Let's crop a fixed size that is safely inside the white face!
    # A tile is ~58x71. The black border is 2-3px.
    # So the white face is ~50x50.
    # The animal is even smaller, maybe 36x36.
    
    # Let's do a 40x40 crop around cx, cy. BUT let's adjust cx, cy to the EXACT center of the white area.
    # Find left black border
    left = cx
    while left > 0 and img.getpixel((left, cy))[0] > 100: left -= 1
    # Find right black border
    right = cx
    while right < img.width and img.getpixel((right, cy))[0] > 100: right += 1
    
    # Find top black border
    top = cy
    while top > 0 and img.getpixel((cx, top))[0] > 100: top -= 1
    # Find bottom green/black border
    bottom = cy
    while bottom < img.height and img.getpixel((cx, bottom))[1] > 150: bottom += 1 # wait, green is G>150, R<100
    
    # But bottom could be black or green. 
    # Let's just use left and right to find true center X!
    true_cx = (left + right) // 2
    
    # Let's do the same for Y, but avoid green.
    # Let's just crop 40x40 around (true_cx, cy).
    
    crop = img.crop((true_cx - 19, cy - 19, true_cx + 19, cy + 19))
    
    data = list(crop.getdata())
    new_data = []
    for item in data:
        # Make white-ish transparent
        if item[0] > 220 and item[1] > 220 and item[2] > 220:
            new_data.append((255, 255, 255, 0))
        # If it's the green base or black border by accident, turn it transparent!
        elif item[0] < 50 and item[1] < 50 and item[2] < 50 and (item[0]+item[1]+item[2]) < 100:
             # It's a black pixel from a border? Wait, the animals have black outlines! Don't delete black!
             new_data.append(item)
        else:
            new_data.append(item)
    crop.putdata(new_data)
    
    crop.save(os.path.join(out_dir, f'animal_{animal_id}.png'))
    animal_id += 1

print(f'Extracted 15 centered animals.')
