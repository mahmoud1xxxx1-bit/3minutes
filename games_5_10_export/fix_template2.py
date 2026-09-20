from PIL import Image

template = Image.open('template.png').convert('RGBA')
data = list(template.getdata())
w, h = template.size

# These are the bad white pixels on the OUTSIDE of the black border
bad_pixels = [
    # Top Left
    (3,0), (4,0), (2,1), (3,1), (1,2), (0,3), (1,3), (0,4),
    # Top Right
    (w-4, 0), (w-5, 0), (w-3, 1), (w-4, 1), (w-2, 2), (w-1, 3), (w-2, 3), (w-1, 4),
    # Bottom Left
    (0, h-5), (0, h-4), (1, h-4), (1, h-3),
    # Bottom Right
    (w-1, h-5), (w-1, h-4), (w-2, h-4), (w-2, h-3),
]

for idx in range(len(data)):
    x = idx % w
    y = idx // w
    if (x, y) in bad_pixels:
        data[idx] = (0, 0, 0, 0)
        
template.putdata(data)
template.save('template_fixed.png')
print('Fixed template created safely!')
