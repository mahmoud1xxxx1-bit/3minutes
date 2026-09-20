import re

with open("lib/features/minigames/presentation/hidden_pigeon/pigeon_painter.dart", "r", encoding="utf-8") as f:
    content = f.read()

# Add a boolean isSolid to PigeonPainter
if "final bool isSolid;" not in content:
    content = content.replace(
        "class PigeonPainter extends CustomPainter {",
        "class PigeonPainter extends CustomPainter {\n  final bool isSolid;"
    )
    content = content.replace(
        "PigeonPainter(this.color);",
        "PigeonPainter(this.color, {this.isSolid = false});"
    )
    
    paint_logic = """
    final paint = Paint()..style = PaintingStyle.fill;
    if (isSolid) {
      paint.color = color;
    } else {
      paint.shader = const LinearGradient(
        colors: [Color(0x73FFFFFF), Color(0x73000000)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect);
    }
    """
    
    content = re.sub(
        r"final paint = Paint\(\).*?style = PaintingStyle.fill;",
        paint_logic,
        content,
        flags=re.DOTALL
    )

with open("lib/features/minigames/presentation/hidden_pigeon/pigeon_painter.dart", "w", encoding="utf-8") as f:
    f.write(content)
