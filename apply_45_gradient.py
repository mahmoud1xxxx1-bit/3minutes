import re

with open("lib/features/minigames/presentation/hidden_pigeon/pigeon_painter.dart", "r", encoding="utf-8") as f:
    content = f.read()

# Change colors to 45% opacity (0x73)
content = content.replace("Color(0x80FFFFFF)", "Color(0x73FFFFFF)")
content = content.replace("Color(0x80000000)", "Color(0x73000000)")

with open("lib/features/minigames/presentation/hidden_pigeon/pigeon_painter.dart", "w", encoding="utf-8") as f:
    f.write(content)
