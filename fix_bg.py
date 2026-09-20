import re

with open("lib/features/minigames/presentation/hidden_pigeon/hidden_pigeon_backgrounds.dart", "r", encoding="utf-8") as f:
    content = f.read()

content = content.replace("bool (covariant CustomPainter oldDelegate) => false;", "bool shouldRepaint(covariant CustomPainter oldDelegate) => false;")

with open("lib/features/minigames/presentation/hidden_pigeon/hidden_pigeon_backgrounds.dart", "w", encoding="utf-8") as f:
    f.write(content)
