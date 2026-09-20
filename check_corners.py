from PIL import Image

template = Image.open('template_fixed.png')
w, h = template.size

print('Top Left 5x5:')
for y in range(5):
    for x in range(5):
        print(f'({x},{y}): {template.getpixel((x,y))}', end='  ')
    print()

print('\nBottom Left 5x5:')
for y in range(h-5, h):
    for x in range(5):
        print(f'({x},{y}): {template.getpixel((x,y))}', end='  ')
    print()
