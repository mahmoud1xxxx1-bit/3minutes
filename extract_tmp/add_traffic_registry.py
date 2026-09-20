import os

path = "lib/features/minigames/data/game_registry.dart"
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

new_game = "    MiniGameDescriptor(id: 'traffic_loop', title: '', category: MiniGameCategory.reaction),\n    MiniGameDescriptor(id: 'mirror_control', title: '', category: MiniGameCategory.precision),"
content = content.replace("    MiniGameDescriptor(id: 'mirror_control', title: '', category: MiniGameCategory.precision),", new_game)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)
