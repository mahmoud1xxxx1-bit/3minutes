from PIL import Image

img = Image.open(r'C:/Users/loved/.gemini/antigravity/brain/14eb05f0-e654-49e3-8d08-001f2e289eae/.user_uploaded/media_1787934649948.png').convert('RGB')

def is_animal(p):
    return abs(p[0]-255) > 10 or abs(p[1]-255) > 10 or abs(p[2]-255) > 10

for y in range(5, 20):
    found = False
    for x in range(15, 45):
        p = img.getpixel((x, y))
        if is_animal(p):
            print(f'Top: x={x}, y={y}, color={p}')
            found = True
            break
    if found: break

for y in range(65, 40, -1):
    found = False
    for x in range(15, 45):
        p = img.getpixel((x, y))
        # Ignore green base (R<150, G>200, B<200)
        if is_animal(p) and not (p[0]<150 and p[1]>200):
            print(f'Bottom: x={x}, y={y}, color={p}')
            found = True
            break
    if found: break
    
for x in range(5, 30):
    found = False
    for y in range(20, 50):
        p = img.getpixel((x, y))
        if is_animal(p) and not (p[0]<150 and p[1]>200):
            print(f'Left: x={x}, y={y}, color={p}')
            found = True
            break
    if found: break

for x in range(55, 30, -1):
    found = False
    for y in range(20, 50):
        p = img.getpixel((x, y))
        if is_animal(p) and not (p[0]<150 and p[1]>200):
            print(f'Right: x={x}, y={y}, color={p}')
            found = True
            break
    if found: break

