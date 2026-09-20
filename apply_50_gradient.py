import re

with open("lib/features/minigames/presentation/hidden_pigeon/pigeon_painter.dart", "r", encoding="utf-8") as f:
    content = f.read()

# Change colors to 50% opacity (0x80)
content = content.replace("Color(0x99FFFFFF)", "Color(0x80FFFFFF)")
content = content.replace("Color(0x99000000)", "Color(0x80000000)")

with open("lib/features/minigames/presentation/hidden_pigeon/pigeon_painter.dart", "w", encoding="utf-8") as f:
    f.write(content)
