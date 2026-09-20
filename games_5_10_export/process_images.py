import os
import glob
from PIL import Image, ImageDraw

def mask_corners(img_path, out_path):
    img = Image.open(img_path).convert('RGBA')
    w, h = img.size
    
    # We want a mask that is white inside the rounded rectangle and black outside
    mask = Image.new('L', (w, h), 0)
    draw = ImageDraw.Draw(mask)
    
    # The rounded rectangle in the generated images seems to cover almost the whole image but with some margin.
    # Let's inspect the margin. Looking at the generated image, the border is thick and black.
    # We can just use a floodfill from the 4 corners (0,0), (w-1,0), (0,h-1), (w-1,h-1) to make the white background transparent.
    
    # Floodfill approach
    img_data = img.load()
    
    # Simple algorithm: if pixel is white or very close to white (e.g. > 240,240,240), make it transparent.
    # But wait, the animal inside might have white!
    # So we do a flood fill from the edges.
    
    def flood_fill_transparent(x, y):
        stack = [(x, y)]
        visited = set()
        while stack:
            cx, cy = stack.pop()
            if (cx, cy) in visited:
                continue
            visited.add((cx, cy))
            
            if cx < 0 or cx >= w or cy < 0 or cy >= h:
                continue
                
            r, g, b, a = img_data[cx, cy]
            # If color is close to white
            if r > 240 and g > 240 and b > 240 and a == 255:
                img_data[cx, cy] = (255, 255, 255, 0)
                stack.append((cx+1, cy))
                stack.append((cx-1, cy))
                stack.append((cx, cy+1))
                stack.append((cx, cy-1))
                
    flood_fill_transparent(0, 0)
    flood_fill_transparent(w-1, 0)
    flood_fill_transparent(0, h-1)
    flood_fill_transparent(w-1, h-1)
    
    img = img.resize((150, 150), Image.Resampling.LANCZOS)
    img.save(out_path)

input_dir = r"C:\Users\loved\.gemini\antigravity\brain\14eb05f0-e654-49e3-8d08-001f2e289eae"
output_dir = r"C:\Users\loved\3minutes\assets\images\onet_full"

for i in range(16, 26):
    files = glob.glob(os.path.join(input_dir, f"tile_{i}_*.jpg"))
    if files:
        mask_corners(files[0], os.path.join(output_dir, f"tile_{i}.png"))
        print(f"Processed tile_{i}.png")
