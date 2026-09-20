from PIL import Image
import os
out_dir = r'C:/Users/loved/3minutes/assets/images/onet'
for i in range(1, 16):
    img = Image.open(os.path.join(out_dir, f'animal_{i}.png'))
    data = img.getdata()
    green_count = 0
    black_count = 0
    for p in data:
        if p[3] == 0: continue
        # Green base color
        if p[1] > 140 and p[0] < 100 and p[2] < 100:
            green_count += 1
        # Black border color
        if p[0] < 50 and p[1] < 50 and p[2] < 50:
            black_count += 1
    print(f'Animal {i}: {green_count} border-green pixels, {black_count} black pixels.')
