from PIL import Image

img = Image.open(r'C:/Users/loved/.gemini/antigravity/brain/14eb05f0-e654-49e3-8d08-001f2e289eae/.user_uploaded/media_1787934627474.png').convert('RGB')
for y in range(65, 71):
    print(f'x=30, y={y}: {img.getpixel((30, y))}')
