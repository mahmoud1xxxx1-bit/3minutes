from PIL import Image

img = Image.open(r'C:/Users/loved/.gemini/antigravity/brain/14eb05f0-e654-49e3-8d08-001f2e289eae/.user_uploaded/media_1787934627474.png').convert('RGB')
for y in range(50, 75):
    p = img.getpixel((30, y))
    if p[1] > p[0] + 20 and p[1] > p[2] + 20:
        print(f'Green found at y={y}: 0xFF%02X%02X%02X' % p)
