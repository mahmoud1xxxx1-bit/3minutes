from PIL import Image
import os
import hashlib

img_path = r'C:/Users/loved/.gemini/antigravity/brain/14eb05f0-e654-49e3-8d08-001f2e289eae/.user_uploaded/media_1787933917552.png'
out_dir = r'C:/Users/loved/3minutes/assets/images/onet_full'
os.makedirs(out_dir, exist_ok=True)
img = Image.open(img_path).convert('RGBA')

# The board is from x=12 to x=481
# The board is from y=11 to y=508
# 8 cols, 7 rows.
# Each tile is 58.625 x 71.0
# The actual tile (with black border) is about 56x69.
# Let's write a function to find the exact black bounding box for a given rough center.

def find_tile_bbox(cx, cy):
    # Expand until we are outside the black border.
    # The background between tiles is dark green (R<50, G>50, B<50).
    # The black border is R<50, G<50, B<50.
    
    # Move left until we find dark green (background)
    left = cx
    while left > 0:
        p = img.getpixel((left, cy))
        if p[0] < 30 and p[1] > 30 and p[2] < 30: # Dark green gap
            break
        left -= 1
        
    right = cx
    while right < img.width:
        p = img.getpixel((right, cy))
        if p[0] < 30 and p[1] > 30 and p[2] < 30: # Dark green gap
            break
        right += 1
        
    top = cy
    while top > 0:
        p = img.getpixel((cx, top))
        if p[0] < 30 and p[1] > 30 and p[2] < 30: # Dark green gap
            break
        top -= 1
        
    bottom = cy
    while bottom < img.height:
        p = img.getpixel((cx, bottom))
        if p[0] < 30 and p[1] > 30 and p[2] < 30: # Dark green gap
            break
        bottom += 1

    # Now step inwards to find the outer edge of the black border
    while left < right and img.getpixel((left, cy))[1] > 30: left += 1
    while right > left and img.getpixel((right, cy))[1] > 30: right -= 1
    while top < bottom and img.getpixel((cx, top))[1] > 30: top += 1
    while bottom > top and img.getpixel((cx, bottom))[1] > 30: bottom -= 1
    
    return (left, top, right, bottom)

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
    cy = int(start_y + r * tile_h + tile_h/2)
    
    # Just hardcode the exact size of the tiles based on math, to avoid pixel scanning errors!
    # A tile is exactly 56 pixels wide and 69 pixels high.
    # The gap between tiles is ~2-3 pixels.
    # The top-left of tile (r,c) is at:
    # x = 12 + c * 58.625
    # y = 11 + r * 71.0
    
    x_start = int(12 + c * (469 / 8))
    y_start = int(11 + r * (497 / 7))
    
    # The width of a tile is roughly 56
    # The height of a tile is roughly 69
    # Let's crop exactly 56x69
    crop = img.crop((x_start, y_start, x_start + 56, y_start + 69))
    
    # Make the 4 corner pixels transparent so it's rounded!
    # (Since it's a rounded rect, the background green is in the corners)
    data = list(crop.getdata())
    new_data = []
    w, h = crop.size
    for i, p in enumerate(data):
        x = i % w
        y = i // w
        # If it's the dark green background color, make it transparent
        if p[0] < 50 and p[1] > 40 and p[2] < 50 and p[1] > p[0] + 10:
            new_data.append((0,0,0,0))
        else:
            new_data.append(p)
    crop.putdata(new_data)
    
    crop.save(os.path.join(out_dir, f'tile_{animal_id}.png'))
    animal_id += 1

print('Extracted 15 full tiles!')
