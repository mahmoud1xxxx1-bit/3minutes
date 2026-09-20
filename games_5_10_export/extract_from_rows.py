from PIL import Image
import os

out_dir = r'C:/Users/loved/3minutes/assets/images/onet_clean'
os.makedirs(out_dir, exist_ok=True)

img_row1 = Image.open(r'C:/Users/loved/.gemini/antigravity/brain/14eb05f0-e654-49e3-8d08-001f2e289eae/.user_uploaded/media_1787934627474.png').convert('RGBA')
img_row2 = Image.open(r'C:/Users/loved/.gemini/antigravity/brain/14eb05f0-e654-49e3-8d08-001f2e289eae/.user_uploaded/media_1787934638462.png').convert('RGBA')
img_row3 = Image.open(r'C:/Users/loved/.gemini/antigravity/brain/14eb05f0-e654-49e3-8d08-001f2e289eae/.user_uploaded/media_1787934649948.png').convert('RGBA')

def extract_animal(img, col, animal_id):
    cx = int(30.25 + col * 60.5)
    cy = 36
    
    # We want a 56x60 crop!
    # left = cx - 28, right = cx + 28
    # top = cy - 30, bottom = cy + 30
    crop = img.crop((cx - 28, cy - 30, cx + 28, cy + 30))
    
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

extract_animal(img_row1, 0, 1)
extract_animal(img_row1, 1, 2)
extract_animal(img_row1, 2, 3)
extract_animal(img_row1, 3, 4)
extract_animal(img_row1, 4, 5)
extract_animal(img_row1, 5, 6)
extract_animal(img_row1, 6, 7)
extract_animal(img_row1, 7, 8)

extract_animal(img_row2, 0, 9)
extract_animal(img_row2, 1, 10)
extract_animal(img_row2, 7, 11)

extract_animal(img_row3, 0, 12)
extract_animal(img_row3, 1, 13)
extract_animal(img_row3, 2, 14)
extract_animal(img_row3, 4, 15)

print('Extracted perfectly with 56x60 MAXIMAL bounding box!')
