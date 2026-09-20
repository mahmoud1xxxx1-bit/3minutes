from PIL import Image

img = Image.open(r'C:/Users/loved/.gemini/antigravity/brain/14eb05f0-e654-49e3-8d08-001f2e289eae/.user_uploaded/media_1787934627474.png').convert('RGB')
w, h = img.size

# Let's scan vertically down the center of the first tile
cx = 30

for y in range(h):
    p = img.getpixel((cx, y))
    print(f'y={y}: {p}')
