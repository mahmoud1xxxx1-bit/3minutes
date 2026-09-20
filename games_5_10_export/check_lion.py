from PIL import Image

img = Image.open(r'C:/Users/loved/.gemini/antigravity/brain/14eb05f0-e654-49e3-8d08-001f2e289eae/.user_uploaded/media_1787933917552.png').convert('RGB')
cy = 40
for x in range(400, 510, 1):
    p = img.getpixel((x, cy))
    if p[0] < 30 and p[1] > 50 and p[2] < 30:
        print(f'Gap green at x={x}')
