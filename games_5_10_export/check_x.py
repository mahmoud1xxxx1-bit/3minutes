from PIL import Image

img = Image.open(r'C:/Users/loved/.gemini/antigravity/brain/14eb05f0-e654-49e3-8d08-001f2e289eae/.user_uploaded/media_1787934627474.png').convert('RGB')
w, h = img.size

# Let's scan horizontally across the first tile at y=10 (in the white face)
for x in range(0, 60):
    p = img.getpixel((x, 10))
    print(f'x={x}: {p}')
