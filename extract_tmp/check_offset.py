from PIL import Image

def get_y_offset(img_path, cx):
    img = Image.open(img_path).convert('RGB')
    for y in range(0, 15):
        p = img.getpixel((cx, y))
        if p[0] < 50 and p[1] < 50 and p[2] < 50:
            return y
    return -1

y1 = get_y_offset(r'C:/Users/loved/.gemini/antigravity/brain/14eb05f0-e654-49e3-8d08-001f2e289eae/.user_uploaded/media_1787934627474.png', 30)
y2 = get_y_offset(r'C:/Users/loved/.gemini/antigravity/brain/14eb05f0-e654-49e3-8d08-001f2e289eae/.user_uploaded/media_1787934638462.png', 27)
y3 = get_y_offset(r'C:/Users/loved/.gemini/antigravity/brain/14eb05f0-e654-49e3-8d08-001f2e289eae/.user_uploaded/media_1787934649948.png', 30)
print(f'Row 1 top border: {y1}')
print(f'Row 2 top border: {y2}')
print(f'Row 3 top border: {y3}')
