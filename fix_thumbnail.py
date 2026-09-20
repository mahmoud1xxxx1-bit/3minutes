import re

with open("lib/thumbnails.dart", "r", encoding="utf-8") as f:
    content = f.read()

new_draw_hidden_pigeon = """void _drawHiddenPigeon(Canvas canvas, Size size, Offset center) {
    // 1. Draw a messy abstract background to represent the "visual clutter"
    final random = dart_math.Random(42);
    for (int i = 0; i < 30; i++) {
      final paint = Paint()
        ..color = Color.fromARGB(
          100 + random.nextInt(155),
          random.nextInt(255),
          random.nextInt(255),
          random.nextInt(255),
        )
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(random.nextDouble() * size.width, random.nextDouble() * size.height),
        10 + random.nextDouble() * 30,
        paint,
      );
    }

    // 2. Draw the Pigeon using the exact path from the game
    final path = Path();
    final pw = size.width * 0.4;
    final ph = size.height * 0.4;
    final px = center.dx - pw / 2;
    final py = center.dy - ph / 2;
    
    path.moveTo(px + pw * 0.7, py + ph * 0.3); 
    path.quadraticBezierTo(px + pw * 0.6, py + ph * 0.3, px + pw * 0.5, py + ph * 0.4); 
    path.quadraticBezierTo(px + pw * 0.2, py + ph * 0.5, px + pw * 0.1, py + ph * 0.6); 
    path.quadraticBezierTo(px + pw * 0.2, py + ph * 0.7, px + pw * 0.4, py + ph * 0.7); 
    path.quadraticBezierTo(px + pw * 0.4, py + ph * 0.85, px + pw * 0.45, py + ph * 0.9); 
    path.quadraticBezierTo(px + pw * 0.5, py + ph * 0.85, px + pw * 0.55, py + ph * 0.8); 
    path.quadraticBezierTo(px + pw * 0.8, py + ph * 0.7, px + pw * 0.9, py + ph * 0.5); 
    path.lineTo(px + pw * 0.95, py + ph * 0.45); 
    path.lineTo(px + pw * 0.85, py + ph * 0.4); 
    path.quadraticBezierTo(px + pw * 0.8, py + ph * 0.3, px + pw * 0.7, py + ph * 0.3); 

    // Gradient Pigeon
    final pigeonPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xEEFFFFFF), Color(0xEE000000)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(px, py, pw, ph))
      ..style = PaintingStyle.fill;
      
    canvas.drawPath(path, pigeonPaint);

    // Draw a subtle target ring around it
    final targetPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawCircle(center, pw * 0.6, targetPaint);
  }"""

# Need to add import 'dart:math' as dart_math; at the top if not exists
if "import 'dart:math'" not in content:
    content = "import 'dart:math' as dart_math;\n" + content
else:
    content = content.replace("import 'dart:math';", "import 'dart:math' as dart_math;")

content = re.sub(
    r"void _drawHiddenPigeon\(Canvas canvas, Size size, Offset center\) \{.*?(?=\n  void _drawEmoji|\n  @override)",
    new_draw_hidden_pigeon + "\n",
    content,
    flags=re.DOTALL
)

with open("lib/thumbnails.dart", "w", encoding="utf-8") as f:
    f.write(content)
