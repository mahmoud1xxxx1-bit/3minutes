with open('pubspec.yaml', 'r', encoding='utf-8') as f:
    code = f.read()

# Add the assets!
assets_str = '''  assets:
    - assets/ranks/
    - assets/avatars/
    - assets/mirror_control/
    - assets/images/onet_full/'''

code = code.replace('''  assets:
    - assets/ranks/
    - assets/avatars/
    - assets/mirror_control/''', assets_str)

with open('pubspec.yaml', 'w', encoding='utf-8') as f:
    f.write(code)
print('Updated pubspec')
