import os
import zipfile

def zipdir(path, ziph):
    # ziph is zipfile handle
    for root, dirs, files in os.walk(path):
        # Exclude huge generated folders
        if 'build' in dirs:
            dirs.remove('build')
        if '.dart_tool' in dirs:
            dirs.remove('.dart_tool')
        if '.git' in dirs:
            dirs.remove('.git')
        if '.pub-cache' in dirs:
            dirs.remove('.pub-cache')
            
        for file in files:
            file_path = os.path.join(root, file)
            # Add file to zip
            ziph.write(file_path, os.path.relpath(file_path, path))

zip_filename = r'c:\Users\loved\Desktop\xmx hg 11.zip'
with zipfile.ZipFile(zip_filename, 'w', zipfile.ZIP_DEFLATED) as zipf:
    zipdir(r'c:\Users\loved\3minutes', zipf)

print(f"Successfully created {zip_filename}")
