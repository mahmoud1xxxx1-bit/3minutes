from PIL import Image

template = Image.open('template.png').convert('RGBA')
data = list(template.getdata())
new_data = []
w, h = template.size

for i, p in enumerate(data):
    x = i % w
    y = i // w
    
    # Check if we are in one of the 4 corners (say, 8x8 area)
    is_corner = (x < 8 or x >= w - 8) and (y < 8 or y >= h - 8)
    
    # If it is a corner and the color is bright (the white artifacts outside the black border)
    if is_corner and p[0] > 120 and p[1] > 120 and p[2] > 120:
        new_data.append((0, 0, 0, 0)) # Make it transparent!
    else:
        new_data.append(p)

template.putdata(new_data)
template.save('template_fixed.png')
print('Fixed template created!')
