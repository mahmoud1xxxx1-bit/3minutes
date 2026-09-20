import re

with open("lib/features/minigames/presentation/hidden_pigeon/hidden_pigeon_game.dart", "r", encoding="utf-8") as f:
    content = f.read()

# Make colors fully solid
content = content.replace("Colors.black.withOpacity(0.4)", "Colors.black")
content = content.replace("Colors.brown.shade800.withOpacity(0.5)", "Colors.brown.shade800")
content = content.replace("Colors.white.withOpacity(0.4)", "Colors.white")

# Replace BlendMask with a standard Container with drop shadow to make it pop (120%)
pigeon_block = """Widget pigeon = Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.white.withOpacity(0.8), blurRadius: 4, spreadRadius: 1),
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 6, offset: const Offset(2, 2)),
        ],
      ),
      child: CustomPaint(
        size: const Size(45, 45),
        painter: PigeonPainter(colors[colorIndex]),
      ),
    );"""

# We need to replace the BlendMask block using regex because it spans multiple lines.
content = re.sub(
    r"Widget pigeon = BlendMask\(.*?painter: PigeonPainter\(colors\[colorIndex\]\),\s*\),\s*\);",
    pigeon_block,
    content,
    flags=re.DOTALL
)

with open("lib/features/minigames/presentation/hidden_pigeon/hidden_pigeon_game.dart", "w", encoding="utf-8") as f:
    f.write(content)
