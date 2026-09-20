import re

with open("lib/features/minigames/presentation/hidden_pigeon/hidden_pigeon_game.dart", "r", encoding="utf-8") as f:
    content = f.read()

# Replace BlendMask back to normal CustomPaint
pigeon_block = """Widget pigeon = CustomPaint(
      size: const Size(45, 45),
      painter: PigeonPainter(colors[colorIndex]),
    );"""

content = re.sub(
    r"Widget pigeon = BlendMask\(.*?painter: PigeonPainter\(colors\[colorIndex\]\),\s*\),\s*\);",
    pigeon_block,
    content,
    flags=re.DOTALL
)

with open("lib/features/minigames/presentation/hidden_pigeon/hidden_pigeon_game.dart", "w", encoding="utf-8") as f:
    f.write(content)
