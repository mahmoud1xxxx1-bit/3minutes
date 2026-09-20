import re

with open("lib/features/minigames/presentation/hidden_pigeon/pigeon_painter.dart", "r", encoding="utf-8") as f:
    content = f.read()

# Change colors to 60% opacity (0x99)
content = content.replace("Color(0xB3FFFFFF)", "Color(0x99FFFFFF)")
content = content.replace("Color(0xB3000000)", "Color(0x99000000)")

with open("lib/features/minigames/presentation/hidden_pigeon/pigeon_painter.dart", "w", encoding="utf-8") as f:
    f.write(content)
