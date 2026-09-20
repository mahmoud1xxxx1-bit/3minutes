from PIL import Image

img = Image.open(r'C:/Users/loved/.gemini/antigravity/brain/14eb05f0-e654-49e3-8d08-001f2e289eae/.user_uploaded/media_1787934627474.png').convert('RGBA')

# Crop the perfect tile
template = img.crop((0, 3, 60, 78))

# Now make the inner area (where the animal is) transparent
# The animal is roughly between x=5 to 55, y=10 to 60.
# Let's just make the white face area transparent so we can paste the animal underneath!
# Wait, if we paste the animal ON TOP, we don't need to make the center transparent.
# But we need to ERASE the monkey so we have a blank tile!
# We can just fill the center with the white face color (255, 255, 255).
data = list(template.getdata())
new_data = []
w, h = template.size

for i, p in enumerate(data):
    x = i % w
    y = i // w
    
    # Is it inside the white face?
    # The white face is roughly x=3 to 56, y=4 to 67
    # Let's paint a white rectangle to erase the monkey!
    if 4 <= x <= 55 and 4 <= y <= 66:
        new_data.append((255, 255, 255, 255))
    else:
        new_data.append(p)
        
template.putdata(new_data)

# Let's also make the outside of the rounded corners transparent!
# Top-left corner
corners = [
    (0,0), (1,0), (2,0), (0,1), (1,1), (0,2)
]
for x, y in corners:
    # top-left
    idx = y * w + x
    new_data[idx] = (0,0,0,0)
    # top-right
    idx = y * w + (w - 1 - x)
    new_data[idx] = (0,0,0,0)
    # bottom-left
    idx = (h - 1 - y) * w + x
    new_data[idx] = (0,0,0,0)
    # bottom-right
    idx = (h - 1 - y) * w + (w - 1 - x)
    new_data[idx] = (0,0,0,0)

template.putdata(new_data)
template.save('template.png')
print('Template created!')
