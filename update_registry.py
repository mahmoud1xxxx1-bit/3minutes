import re

file_path = r"c:\Users\loved\3minutes\lib\features\minigames\data\game_registry.dart"
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Update version
version_match = re.search(r'static const int version = (\d+);', content)
if version_match:
    old_version = version_match.group(1)
    new_version = int(old_version) + 1
    content = content.replace(f'static const int version = {old_version};', f'static const int version = {new_version};')

# Add game descriptor
new_game = "    MiniGameDescriptor(id: 'mirror_control', title: '', category: MiniGameCategory.precision),\n  ];"
content = content.replace("  ];", new_game)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Updated game_registry.dart")
