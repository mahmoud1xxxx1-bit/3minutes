from PIL import Image
img = Image.open(r'C:/Users/loved/.gemini/antigravity/brain/14eb05f0-e654-49e3-8d08-001f2e289eae/.user_uploaded/media_1787932640928.png').convert('RGB')
crop = img.crop((270, 20, 380, 130))
crop.save('test_crop.png')
print('Saved test crop')
