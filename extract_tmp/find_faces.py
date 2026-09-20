from PIL import Image

img = Image.open(r'C:/Users/loved/.gemini/antigravity/brain/14eb05f0-e654-49e3-8d08-001f2e289eae/.user_uploaded/media_1787934627474.png').convert('RGB')
w, h = img.size
cy = 5  # Scan near the top to avoid animals!

in_border = False
start_x = 0
borders = []

for x in range(w):
    p = img.getpixel((x, cy))
    # Look for the green/black gap between tiles
    is_gap = p[0] < 100 and p[1] < 150 and p[2] < 100
    
    if is_gap and not in_border:
        in_border = True
        start_x = x
    elif not is_gap and in_border:
        in_border = False
        borders.append((start_x, x - 1))

print(f'Found {len(borders)} borders at y={cy}!')
for i, (sx, ex) in enumerate(borders):
    print(f'Border {i}: start={sx}, end={ex}, center={(sx+ex)//2}, width={ex-sx}')
