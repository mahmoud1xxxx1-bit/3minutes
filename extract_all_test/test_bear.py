from PIL import Image

def get_face(img_path, cx):
    img = Image.open(img_path).convert('RGBA')
    y_start = 0
    for y in range(0, 15):
        p = img.getpixel((cx, y))
        if p[0] > 240 and p[1] > 240 and p[2] > 240:
            y_start = y
            break
    face = img.crop((cx - 26, y_start, cx + 26, y_start + 63))
    return face

bear = get_face(r'C:/Users/loved/.gemini/antigravity/brain/14eb05f0-e654-49e3-8d08-001f2e289eae/.user_uploaded/media_1787934649948.png', 272)

w, h = bear.size
visited = set()
q = [(0,0), (w-1,0), (0,h-1), (w-1,h-1)]
data = list(bear.getdata())
new_data = data.copy()

def is_similar(p, target, tol=20):
    return abs(p[0]-target[0]) < tol and abs(p[1]-target[1]) < tol and abs(p[2]-target[2]) < tol

bg_color = (255, 255, 255, 255) # Assume pure white background

while q:
    x, y = q.pop(0)
    if (x, y) in visited: continue
    visited.add((x, y))
    
    idx = y * w + x
    p = data[idx]
    
    if is_similar(p, bg_color):
        new_data[idx] = (0, 0, 0, 0)
        if x > 0: q.append((x-1, y))
        if x < w-1: q.append((x+1, y))
        if y > 0: q.append((x, y-1))
        if y < h-1: q.append((x, y+1))

bear.putdata(new_data)
bear.save('bear_test.png')

template = Image.open('template_fixed.png').convert('RGBA')
template.paste(bear, (4, 2), bear)
template.save('bear_fixed.png')
print('Bear fixed created!')
