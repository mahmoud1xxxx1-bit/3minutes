from PIL import Image

img = Image.open(r'C:/Users/loved/.gemini/antigravity/brain/14eb05f0-e654-49e3-8d08-001f2e289eae/.user_uploaded/media_1787940798856.png').convert('RGB')
w, h = img.size

# Find the bounding box of the tile by looking for the black borders
left = w
right = 0
top = h
bottom = 0

for y in range(h):
    for x in range(w):
        p = img.getpixel((x, y))
        # Black border color is around (16, 14, 13) to (30, 30, 30)
        # Let's say < 40
        if p[0] < 50 and p[1] < 50 and p[2] < 50:
            left = min(left, x)
            right = max(right, x)
            top = min(top, y)
            bottom = max(bottom, y)

print(f'Shark tile bounding box: left={left}, top={top}, right={right}, bottom={bottom}')
print(f'Width: {right - left + 1}, Height: {bottom - top + 1}')
