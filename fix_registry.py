import re

registry_path = r"c:\Users\loved\3minutes\lib\features\minigames\data\game_registry.dart"
with open(registry_path, "r", encoding="utf-8") as f:
    content = f.read()

new_games = """  static const List<MiniGameDescriptor> games = [
    MiniGameDescriptor(id: 'find_differences', title: '', category: MiniGameCategory.precision),
    MiniGameDescriptor(id: 'follow_the_cup', title: '', category: MiniGameCategory.memory),
    MiniGameDescriptor(id: 'key_escape', title: '', category: MiniGameCategory.logic),
    MiniGameDescriptor(id: 'level_devil', title: '', category: MiniGameCategory.reaction),
    MiniGameDescriptor(id: 'mirror_control', title: '', category: MiniGameCategory.precision),
    MiniGameDescriptor(id: 'mole_strike', title: '', category: MiniGameCategory.reaction),
    MiniGameDescriptor(id: 'ninja_slice', title: '', category: MiniGameCategory.reaction),
    MiniGameDescriptor(id: 'onet_connect', title: '', category: MiniGameCategory.logic),
    MiniGameDescriptor(id: 'path_rush', title: '', category: MiniGameCategory.logic),
    MiniGameDescriptor(id: 'traffic_loop', title: '', category: MiniGameCategory.logic),
    MiniGameDescriptor(id: 'hidden_pigeon', title: '', category: MiniGameCategory.precision),
  ];"""

content = re.sub(r"static const List<MiniGameDescriptor> games = \[.*?\];", new_games, content, flags=re.DOTALL)

with open(registry_path, "w", encoding="utf-8") as f:
    f.write(content)

print("GameRegistry updated")
