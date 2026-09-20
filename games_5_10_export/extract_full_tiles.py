from PIL import Image
import os

out_dir = r'C:/Users/loved/3minutes/assets/images/onet_full'
os.makedirs(out_dir, exist_ok=True)

img_row1 = Image.open(r'C:/Users/loved/.gemini/antigravity/brain/14eb05f0-e654-49e3-8d08-001f2e289eae/.user_uploaded/media_1787934627474.png').convert('RGBA')
img_row2 = Image.open(r'C:/Users/loved/.gemini/antigravity/brain/14eb05f0-e654-49e3-8d08-001f2e289eae/.user_uploaded/media_1787934638462.png').convert('RGBA')
img_row3 = Image.open(r'C:/Users/loved/.gemini/antigravity/brain/14eb05f0-e654-49e3-8d08-001f2e289eae/.user_uploaded/media_1787934649948.png').convert('RGBA')

def extract_full_tile(img, col, animal_id):
    left = int(col * 60.5)
    right = int((col + 1) * 60.5)
    # The image is 80 pixels tall
    top = 0
    bottom = 80
    
    crop = img.crop((left, top, right, bottom))
    
    # We want to make the 4 corners transparent because the tiles are rounded!
    # The corners are dark green/black background.
    data = list(crop.getdata())
    new_data = []
    w, h = crop.size
    for i, p in enumerate(data):
        x = i % w
        y = i // w
        
        # If it's the very corners, make it transparent
        # The background between tiles is dark (R<50, G<60, B<50)
        if (x < 3 or x > w-4) and (y < 3 or y > h-4):
            if p[0] < 50 and p[1] < 60 and p[2] < 50:
                new_data.append((0,0,0,0))
                continue
        new_data.append(p)
        
    crop.putdata(new_data)
    crop.save(os.path.join(out_dir, f'tile_{animal_id}.png'))

extract_full_tile(img_row1, 0, 1)
extract_full_tile(img_row1, 1, 2)
extract_full_tile(img_row1, 2, 3)
extract_full_tile(img_row1, 3, 4)
extract_full_tile(img_row1, 4, 5)
extract_full_tile(img_row1, 5, 6)
extract_full_tile(img_row1, 6, 7)
extract_full_tile(img_row1, 7, 8)

extract_full_tile(img_row2, 0, 9)
extract_full_tile(img_row2, 1, 10)
extract_full_tile(img_row2, 7, 11)

extract_full_tile(img_row3, 0, 12)
extract_full_tile(img_row3, 1, 13)
extract_full_tile(img_row3, 2, 14)
extract_full_tile(img_row3, 4, 15)

print('Extracted perfect full tiles!')
