import 'package:flutter/material.dart';
import 'dart:math' as math;

Widget getGameThumbnail(String id) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(20),
    child: Stack(
      fit: StackFit.expand,
      children: [
        _buildThumbnailBackground(id),
        _buildThumbnailContent(id),
        _buildCosmeticOverlay(),
      ],
    ),
  );
}

Widget _buildThumbnailBackground(String id) {
  List<Color> colors;
  switch (id) {
    case 'find_differences': colors = [const Color(0xFF1E3C72), const Color(0xFF2A5298)]; break;
    case 'follow_the_cup': colors = [const Color(0xFF4A1C40), const Color(0xFF21091A)]; break;
    case 'key_escape': colors = [const Color(0xFF0F2027), const Color(0xFF203A43)]; break;
    case 'level_devil': colors = [const Color(0xFF2B0202), const Color(0xFF6B0F0F)]; break;
    case 'mirror_control': colors = [const Color(0xFF021B33), const Color(0xFF003859)]; break;
    case 'mole_strike': colors = [const Color(0xFF2E7D32), const Color(0xFF1B5E20)]; break;
    case 'ninja_slice': colors = [const Color(0xFF212121), const Color(0xFF000000)]; break;
    case 'path_rush': colors = [const Color(0xFF1A1A24), const Color(0xFF0F0F15)]; break;
    case 'onet_connect': colors = [const Color(0xFF4A148C), const Color(0xFF311B92)]; break;
    case 'traffic_loop': colors = [const Color(0xFF121212), const Color(0xFF263238)]; break;
    case 'hidden_pigeon': colors = [const Color(0xFF8D6E63), const Color(0xFF3E2723)]; break;
    default: colors = [Colors.grey.shade900, Colors.black];
  }
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors),
    ),
  );
}

Widget _buildCosmeticOverlay() {
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.2),
          Colors.transparent,
          Colors.black.withOpacity(0.4),
        ],
        stops: const [0.0, 0.5, 1.0],
      ),
    ),
  );
}

Widget _buildThumbnailContent(String id) {
  return CustomPaint(
    painter: _GameThumbnailPainter(id),
  );
}

class _GameThumbnailPainter extends CustomPainter {
  final String id;
  _GameThumbnailPainter(this.id);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    switch (id) {
      case 'path_rush':
        _drawPathRush(canvas, size);
        break;
      case 'traffic_loop':
        _drawTrafficLoop(canvas, size, center);
        break;
      case 'mirror_control':
        _drawMirrorControl(canvas, size);
        break;
      case 'key_escape':
        _drawKeyEscape(canvas, size, center);
        break;
      case 'ninja_slice':
        _drawNinjaSlice(canvas, size, center);
        break;
      case 'follow_the_cup':
        _drawFollowTheCup(canvas, size);
        break;
      case 'mole_strike':
        _drawMoleStrike(canvas, size);
        break;
      case 'level_devil':
        _drawLevelDevil(canvas, size);
        break;
      case 'find_differences':
        _drawFindDifferences(canvas, size, center);
        break;
      case 'onet_connect':
        _drawOnetConnect(canvas, size);
        break;
      case 'hidden_pigeon':
        _drawHiddenPigeon(canvas, size, center);
        break;
    }
  }

  void _drawPathRush(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF1DDA5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
      
    final glow = Paint()
      ..color = const Color(0xFF19DCE8).withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    for (int i = 0; i < 3; i++) {
      final path = Path();
      final startX = size.width * (0.2 + i * 0.3);
      path.moveTo(startX, size.height * 0.2);
      
      final endX = size.width * (0.8 - i * 0.3);
      path.cubicTo(
        size.width * (i == 1 ? 0.9 : 0.1), size.height * 0.4,
        size.width * (i == 0 ? 0.9 : 0.1), size.height * 0.6,
        endX, size.height * 0.8,
      );
      
      canvas.drawPath(path, glow);
      canvas.drawPath(path, paint);
    }
    
    // Draw animal and food representations
    _drawEmoji(canvas, '🐰', Offset(size.width * 0.5, size.height * 0.15), 32);
    _drawEmoji(canvas, '🥕', Offset(size.width * 0.8, size.height * 0.85), 24);
  }

  void _drawTrafficLoop(Canvas canvas, Size size, Offset center) {
    final rect = Rect.fromCenter(center: center, width: size.width * 0.8, height: size.height * 0.4);
    
    final glow = Paint()
      ..color = Colors.cyan.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      
    final track = Paint()
      ..color = const Color(0xFF1E3C72)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
      
    final path = Path()
      ..addArc(Rect.fromLTRB(rect.left, rect.top, center.dx, rect.bottom), math.pi / 2, math.pi * 1.5)
      ..addArc(Rect.fromLTRB(center.dx, rect.top, rect.right, rect.bottom), math.pi, -math.pi * 1.5);
      
    canvas.drawPath(path, glow);
    canvas.drawPath(path, track);
    
    // Cars
    canvas.drawCircle(Offset(rect.left + rect.width * 0.15, rect.top + 5), 8, Paint()..color = Colors.redAccent);
    canvas.drawCircle(Offset(rect.right - rect.width * 0.15, rect.bottom - 5), 8, Paint()..color = Colors.greenAccent);
  }

  void _drawMirrorControl(Canvas canvas, Size size) {
    final center = size.width / 2;
    // Split line
    canvas.drawLine(Offset(center, 0), Offset(center, size.height), Paint()..color = Colors.white24..strokeWidth = 2);
    
    // Left Car
    final leftCar = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(center * 0.5, size.height * 0.6), width: 25, height: 45),
      const Radius.circular(5)
    );
    canvas.drawRRect(leftCar, Paint()..color = Colors.pinkAccent..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    canvas.drawRRect(leftCar, Paint()..color = Colors.pink);
    
    // Right Car
    final rightCar = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(center * 1.5, size.height * 0.6), width: 25, height: 45),
      const Radius.circular(5)
    );
    canvas.drawRRect(rightCar, Paint()..color = Colors.cyanAccent..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    canvas.drawRRect(rightCar, Paint()..color = Colors.cyan);
  }

  void _drawKeyEscape(Canvas canvas, Size size, Offset center) {
    final paint = Paint()
      ..color = Colors.blueAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
      
    // Abstract maze
    canvas.drawRect(Rect.fromCenter(center: center, width: size.width * 0.7, height: size.width * 0.7), paint);
    canvas.drawRect(Rect.fromCenter(center: center, width: size.width * 0.4, height: size.width * 0.4), paint);
    canvas.drawLine(Offset(center.dx, center.dy - size.width * 0.2), Offset(center.dx, center.dy - size.width * 0.35), paint);
    
    _drawEmoji(canvas, '🗝️', center, 40);
  }

  void _drawNinjaSlice(Canvas canvas, Size size, Offset center) {
    _drawEmoji(canvas, '🍉', center, 60);
    
    // Slash
    final path = Path()
      ..moveTo(size.width * 0.1, size.height * 0.8)
      ..lineTo(size.width * 0.9, size.height * 0.2);
      
    canvas.drawPath(path, Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
  }

  void _drawFollowTheCup(Canvas canvas, Size size) {
    for (int i = 0; i < 3; i++) {
      final x = size.width * (0.2 + i * 0.3);
      final y = size.height * (i == 1 ? 0.4 : 0.6);
      
      // Cup
      final path = Path()
        ..moveTo(x - 20, y + 25)
        ..lineTo(x + 20, y + 25)
        ..lineTo(x + 15, y - 20)
        ..lineTo(x - 15, y - 20)
        ..close();
        
      canvas.drawPath(path, Paint()..color = Colors.amber);
      
      if (i == 1) {
        // Glowing ball under lifted cup
        canvas.drawCircle(Offset(x, y + 40), 10, Paint()..color = Colors.yellowAccent..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
        canvas.drawCircle(Offset(x, y + 40), 6, Paint()..color = Colors.white);
      }
    }
  }

  void _drawMoleStrike(Canvas canvas, Size size) {
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        final x = size.width * (0.25 + i * 0.25);
        final y = size.height * (0.3 + j * 0.25);
        
        // Hole
        canvas.drawOval(
          Rect.fromCenter(center: Offset(x, y), width: 30, height: 10),
          Paint()..color = Colors.black54
        );
        
        if (i == 1 && j == 1) {
          _drawEmoji(canvas, '🐿️', Offset(x, y - 10), 24);
        }
      }
    }
  }

  void _drawLevelDevil(Canvas canvas, Size size) {
    // Spikes
    final path = Path()
      ..moveTo(size.width * 0.3, size.height * 0.8)
      ..lineTo(size.width * 0.4, size.height * 0.6)
      ..lineTo(size.width * 0.5, size.height * 0.8)
      ..lineTo(size.width * 0.6, size.height * 0.6)
      ..lineTo(size.width * 0.7, size.height * 0.8);
      
    canvas.drawPath(path, Paint()..color = Colors.redAccent);
    
    // Character
    _drawEmoji(canvas, '😈', Offset(size.width * 0.2, size.height * 0.5), 36);
  }

  void _drawFindDifferences(Canvas canvas, Size size, Offset center) {
    // Split screen
    canvas.drawRect(Rect.fromLTRB(0, 0, size.width/2, size.height), Paint()..color = Colors.green.withOpacity(0.3));
    canvas.drawRect(Rect.fromLTRB(size.width/2, 0, size.width, size.height), Paint()..color = Colors.green.withOpacity(0.4));
    
    _drawEmoji(canvas, '🔍', center, 50);
  }

  void _drawOnetConnect(Canvas canvas, Size size) {
    final points = [
      Offset(size.width * 0.3, size.height * 0.3),
      Offset(size.width * 0.7, size.height * 0.3),
      Offset(size.width * 0.7, size.height * 0.7),
    ];
    
    final path = Path()..moveTo(points[0].dx, points[0].dy)..lineTo(points[1].dx, points[1].dy)..lineTo(points[2].dx, points[2].dy);
    
    canvas.drawPath(path, Paint()
      ..color = Colors.greenAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2));
      
    _drawEmoji(canvas, '🐼', points[0], 28);
    _drawEmoji(canvas, '🐼', points[2], 28);
  }

  void _drawHiddenPigeon(Canvas canvas, Size size, Offset center) {
    // 1. Draw a messy abstract background to represent the "visual clutter"
    final random = math.Random(42);
    for (int i = 0; i < 30; i++) {
      final paint = Paint()
        ..color = Color.fromARGB(
          (100 + random.nextInt(155)).toInt(),
          random.nextInt(255),
          random.nextInt(255),
          random.nextInt(255),
        )
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(random.nextDouble() * size.width, random.nextDouble() * size.height),
        (10 + random.nextDouble() * 30).toDouble(),
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
  }

  void _drawEmoji(Canvas canvas, String emoji, Offset center, double fontSize) {
    final textSpan = TextSpan(text: emoji, style: TextStyle(fontSize: fontSize));
    final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    textPainter.layout();
    textPainter.paint(canvas, Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
