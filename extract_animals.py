from PIL import Image
import os

img_path = r'C:/Users/loved/.gemini/antigravity/brain/14eb05f0-e654-49e3-8d08-001f2e289eae/.user_uploaded/media_1787931692712.png'
out_dir = r'C:/Users/loved/3minutes/assets/images/onet'
os.makedirs(out_dir, exist_ok=True)

img = Image.open(img_path).convert('RGBA')

# Tile dimensions approx 71.8 x 86.4
# Let's define the center coordinates for the animals to crop a 50x50 box
# Row 1 (y = 0..86) -> center y around 38 (since bottom has 3D green base)
# Col 1 (x = 0..71) -> center x around 36
def extract_animal(c, r, name):
    x_center = int(c * 71.8 + 35.9)
    y_center = int(r * 86.4 + 40)
    
    # Crop a 54x54 box around center
    box = (x_center - 27, y_center - 27, x_center + 27, y_center + 27)
    crop = img.crop(box)
    
    # Make white transparent
    data = crop.getdata()
    new_data = []
    for item in data:
        # Check if pixel is near-white
        if item[0] > 220 and item[1] > 220 and item[2] > 220:
            new_data.append((255, 255, 255, 0))
        else:
            new_data.append(item)
    crop.putdata(new_data)
    
    crop.save(os.path.join(out_dir, f'{name}.png'))
    print(f'Saved {name}.png')

# 1. Fox
extract_animal(0, 0, 'animal_1')
# 2. Fish
extract_animal(1, 0, 'animal_2')
# 3. Monkey
extract_animal(2, 0, 'animal_3')
# 4. Pig
extract_animal(3, 0, 'animal_4')
# 5. Snail
extract_animal(5, 0, 'animal_5')
# 6. DogCat
extract_animal(1, 1, 'animal_6')
# 7. Rabbit
extract_animal(2, 1, 'animal_7')
# 8. Owl
extract_animal(3, 1, 'animal_8')
# 9. Dino
extract_animal(4, 1, 'animal_9')
# 10. Walrus
extract_animal(0, 3, 'animal_10')
# 11. Zebra
extract_animal(5, 3, 'animal_11')

