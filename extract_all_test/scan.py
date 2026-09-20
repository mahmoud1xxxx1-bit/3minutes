from PIL import Image

img = Image.open(r'C:/Users/loved/.gemini/antigravity/brain/14eb05f0-e654-49e3-8d08-001f2e289eae/.user_uploaded/media_1787932640928.png').convert('RGB')
def print_colors(x_start, y_start, dx, dy):
    for i in range(10):
        p = img.getpixel((x_start + i*dx, y_start + i*dy))
        print(f'({x_start + i*dx}, {y_start + i*dy}): {p}')

print('Scanning X from 275 to 305 at y=50')
for x in range(275, 305):
    p = img.getpixel((x, 50))
    if p[0] < 50: print(f'Black at x={x}')
print('---')
print('Scanning Y from 30 to 60 at x=350')
for y in range(30, 60):
    p = img.getpixel((350, y))
    if p[0] < 50: print(f'Black at y={y}')

