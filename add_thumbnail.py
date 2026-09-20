import re

with open("lib/thumbnails.dart", "r", encoding="utf-8") as f:
    content = f.read()

# Add to background colors
content = re.sub(
    r"case 'traffic_loop': colors = \[const Color\(0xFF121212\), const Color\(0xFF263238\)\]; break;",
    "case 'traffic_loop': colors = [const Color(0xFF121212), const Color(0xFF263238)]; break;\n    case 'hidden_pigeon': colors = [const Color(0xFF8D6E63), const Color(0xFF3E2723)]; break;",
    content
)

# Add to painter cases
content = re.sub(
    r"case 'onet_connect':\n        _drawOnetConnect\(canvas, size\);\n        break;",
    "case 'onet_connect':\n        _drawOnetConnect(canvas, size);\n        break;\n      case 'hidden_pigeon':\n        _drawHiddenPigeon(canvas, size, center);\n        break;",
    content
)

# Add drawing function
hidden_pigeon_draw = """
  void _drawHiddenPigeon(Canvas canvas, Size size, Offset center) {
    _drawEmoji(canvas, '🏙️', center, 60);
    final paint = Paint()..color = Colors.white.withOpacity(0.3);
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.3), 5, paint);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.7), 5, paint);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.2), 5, paint);
    
    // Magnifying glass part
    final glow = Paint()..color = Colors.blueAccent.withOpacity(0.5)..style = PaintingStyle.stroke..strokeWidth = 6..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(Offset(size.width * 0.4, size.height * 0.4), 20, glow);
    canvas.drawLine(Offset(size.width * 0.4 + 14, size.height * 0.4 + 14), Offset(size.width * 0.4 + 30, size.height * 0.4 + 30), glow);
  }
"""

content = re.sub(r'void _drawEmoji\(', hidden_pigeon_draw.strip() + '\n\n  void _drawEmoji(', content)

with open("lib/thumbnails.dart", "w", encoding="utf-8") as f:
    f.write(content)
