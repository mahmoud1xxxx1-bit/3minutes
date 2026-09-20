from PIL import Image

img = Image.open(r'C:/Users/loved/.gemini/antigravity/brain/14eb05f0-e654-49e3-8d08-001f2e289eae/.user_uploaded/media_1787934627474.png').convert('RGB')
w, h = img.size
cy = 40
for x in range(w):
    p = img.getpixel((x, cy))
    if p[0] < 10 and p[1] < 10 and p[2] < 10:
        print(f'Black at x={x}')
