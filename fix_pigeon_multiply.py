import re

with open("lib/features/minigames/presentation/hidden_pigeon/hidden_pigeon_game.dart", "r", encoding="utf-8") as f:
    content = f.read()

# Make all colors black
content = content.replace(
    "Colors.black.withOpacity(0.7),",
    "Colors.black,"
)
content = content.replace(
    "Colors.brown.shade800.withOpacity(0.85),",
    "Colors.black,"
)
content = content.replace(
    "Colors.white.withOpacity(0.75),",
    "Colors.black,"
)

# Add BlendMask with multiply and opacity 0.65
pigeon_block = """Widget pigeon = BlendMask(
      blendMode: BlendMode.multiply,
      opacity: 0.65,
      child: CustomPaint(
        size: const Size(45, 45),
        painter: PigeonPainter(colors[colorIndex]),
      ),
    );"""

content = re.sub(
    r"Widget pigeon = CustomPaint\(.*?painter: PigeonPainter\(colors\[colorIndex\]\),\s*\);",
    pigeon_block,
    content,
    flags=re.DOTALL
)

with open("lib/features/minigames/presentation/hidden_pigeon/hidden_pigeon_game.dart", "w", encoding="utf-8") as f:
    f.write(content)
