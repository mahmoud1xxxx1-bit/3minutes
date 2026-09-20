import re

with open("lib/features/minigames/data/game_registry.dart", "r", encoding="utf-8") as f:
    content = f.read()

# Add hidden_pigeon
if "'hidden_pigeon'" not in content:
    content = content.replace(
        "MiniGameDescriptor(id: 'traffic_loop', title: 'Traffic Loop', category: MiniGameCategory.logic),",
        "MiniGameDescriptor(id: 'traffic_loop', title: 'Traffic Loop', category: MiniGameCategory.logic),\n    MiniGameDescriptor(id: 'hidden_pigeon', title: 'Hidden Pigeon', category: MiniGameCategory.precision),"
    )
    # also bump version
    content = content.replace("static const int version = 10;", "static const int version = 11;")

with open("lib/features/minigames/data/game_registry.dart", "w", encoding="utf-8") as f:
    f.write(content)
