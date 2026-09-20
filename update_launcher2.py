import re

with open("lib/test_all_games_1_10.dart", "r", encoding="utf-8") as f:
    content = f.read()

content = re.sub(
    r"const MiniGameDescriptor\(id: 'traffic_loop', title: 'Traffic Loop', category: MiniGameCategory\.logic\),",
    "const MiniGameDescriptor(id: 'traffic_loop', title: 'Traffic Loop', category: MiniGameCategory.logic),\n        const MiniGameDescriptor(id: 'hidden_pigeon', title: 'Hidden Pigeon', category: MiniGameCategory.observation),",
    content
)

with open("lib/test_all_games_1_10.dart", "w", encoding="utf-8") as f:
    f.write(content)
