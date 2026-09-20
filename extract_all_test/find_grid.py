from PIL import Image
import os

img_path = r'C:/Users/loved/.gemini/antigravity/brain/14eb05f0-e654-49e3-8d08-001f2e289eae/.user_uploaded/media_1787932640928.png'
out_dir = r'C:/Users/loved/3minutes/assets/images/onet_v2'
os.makedirs(out_dir, exist_ok=True)

img = Image.open(img_path).convert('RGBA')

# Let's save a row of pixels to find where the grid starts
row_y = 300
pixels = []
for x in range(300, 900):
    p = img.getpixel((x, row_y))
    pixels.append((x, p))

# Find white pixels (the board)
board_start = None
for x, p in pixels:
    if p[0] > 240 and p[1] > 240 and p[2] > 240:
        if board_start is None:
            board_start = x
            break

print(f'Board starts at x={board_start}')

# Let's find where the grid starts vertically
col_x = 500
pixels_y = []
for y in range(0, 500):
    p = img.getpixel((col_x, y))
    pixels_y.append((y, p))

board_start_y = None
for y, p in pixels_y:
    if p[0] > 240 and p[1] > 240 and p[2] > 240:
        if board_start_y is None:
            board_start_y = y
            break

print(f'Board starts at y={board_start_y}')
