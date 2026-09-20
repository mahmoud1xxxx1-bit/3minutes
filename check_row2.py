from PIL import Image

img = Image.open(r'C:/Users/loved/.gemini/antigravity/brain/14eb05f0-e654-49e3-8d08-001f2e289eae/.user_uploaded/media_1787934638462.png').convert('RGB')
w, h = img.size
in_border = False
start_x = 0
borders = []
cy = 5

for x in range(w):
    p = img.getpixel((x, cy))
    is_gap = p[0] < 100 and p[1] < 150 and p[2] < 100
    if is_gap and not in_border:
        in_border = True
        start_x = x
    elif not is_gap and in_border:
        in_border = False
        borders.append((start_x, x - 1))

print(f'Borders in row 2: {borders}')
