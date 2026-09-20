import re

with open("lib/features/minigames/presentation/hidden_pigeon/hidden_pigeon_game.dart", "r", encoding="utf-8") as f:
    content = f.read()

# Replace the Container with the BoxShadow halo back to a BlendMask with 1.0 opacity and hardLight
# Wait, hardLight might still make it blend too much. 
# I will just use a normal Widget without any BoxShadows.

pigeon_block = """Widget pigeon = CustomPaint(
      size: const Size(45, 45),
      painter: PigeonPainter(colors[colorIndex]),
    );"""

# Replace the Container block
content = re.sub(
    r"Widget pigeon = Container\(.*?painter: PigeonPainter\(colors\[colorIndex\]\),\s*\),\s*\);",
    pigeon_block,
    content,
    flags=re.DOTALL
)

with open("lib/features/minigames/presentation/hidden_pigeon/hidden_pigeon_game.dart", "w", encoding="utf-8") as f:
    f.write(content)
