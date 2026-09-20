from PIL import Image

def check_y(img_path):
    img = Image.open(img_path).convert('RGB')
    w, h = img.size
    print(f'Checking {img_path}')
    cx = 30
    # Find top black border (y around 2-5)
    for y in range(0, 10):
        p = img.getpixel((cx, y))
        if p[0] < 50 and p[1] < 50 and p[2] < 50:
            print(f'  Top black border at y={y}')
            break
            
    # Find bottom black border (y around 75-79)
    for y in range(70, 80):
        p = img.getpixel((cx, y))
        if p[0] < 50 and p[1] < 50 and p[2] < 50:
            print(f'  Bottom black border at y={y}')
            break

check_y(r'C:/Users/loved/.gemini/antigravity/brain/14eb05f0-e654-49e3-8d08-001f2e289eae/.user_uploaded/media_1787934627474.png')
check_y(r'C:/Users/loved/.gemini/antigravity/brain/14eb05f0-e654-49e3-8d08-001f2e289eae/.user_uploaded/media_1787934638462.png')
check_y(r'C:/Users/loved/.gemini/antigravity/brain/14eb05f0-e654-49e3-8d08-001f2e289eae/.user_uploaded/media_1787934649948.png')
