import re

with open("lib/features/minigames/presentation/hidden_pigeon/pigeon_painter.dart", "r", encoding="utf-8") as f:
    content = f.read()

# Restore original pigeon painter (solid fill only)
pigeon_painter_code = """import 'package:flutter/material.dart';

class PigeonPainter extends CustomPainter {
  final Color color;
  PigeonPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
      
    final path = Path();
    path.moveTo(size.width * 0.7, size.height * 0.3); 
    path.quadraticBezierTo(size.width * 0.6, size.height * 0.3, size.width * 0.5, size.height * 0.4); 
    path.quadraticBezierTo(size.width * 0.2, size.height * 0.5, size.width * 0.1, size.height * 0.6); 
    path.quadraticBezierTo(size.width * 0.2, size.height * 0.7, size.width * 0.4, size.height * 0.7); 
    path.quadraticBezierTo(size.width * 0.4, size.height * 0.85, size.width * 0.45, size.height * 0.9); 
    path.quadraticBezierTo(size.width * 0.5, size.height * 0.85, size.width * 0.55, size.height * 0.8); 
    path.quadraticBezierTo(size.width * 0.8, size.height * 0.7, size.width * 0.9, size.height * 0.5); 
    path.lineTo(size.width * 0.95, size.height * 0.45); 
    path.lineTo(size.width * 0.85, size.height * 0.4); 
    path.quadraticBezierTo(size.width * 0.8, size.height * 0.3, size.width * 0.7, size.height * 0.3); 
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
"""

with open("lib/features/minigames/presentation/hidden_pigeon/pigeon_painter.dart", "w", encoding="utf-8") as f:
    f.write(pigeon_painter_code)


# Now update the colors in the game to be exactly 70-80% transparent.
with open("lib/features/minigames/presentation/hidden_pigeon/hidden_pigeon_game.dart", "r", encoding="utf-8") as f:
    game_content = f.read()

game_content = game_content.replace(
    "final colors = [",
    "final colors = ["
)
game_content = game_content.replace(
    "Colors.black,",
    "Colors.black.withOpacity(0.7),"
)
game_content = game_content.replace(
    "Colors.brown.shade800,",
    "Colors.brown.shade800.withOpacity(0.85),"
)
game_content = game_content.replace(
    "Colors.white,",
    "Colors.white.withOpacity(0.75),"
)

with open("lib/features/minigames/presentation/hidden_pigeon/hidden_pigeon_game.dart", "w", encoding="utf-8") as f:
    f.write(game_content)
