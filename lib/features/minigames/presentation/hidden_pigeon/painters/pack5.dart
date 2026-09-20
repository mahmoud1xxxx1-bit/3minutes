import 'dart:math';
import 'package:flutter/material.dart';

class PigeonPainterPack5 extends CustomPainter {
  final int seed;
  final int themeIndex;
  
  PigeonPainterPack5(this.seed, this.themeIndex);

  @override
  void paint(Canvas canvas, Size size) {
    final rand = Random(seed * 100 + themeIndex);
    // Fill background
    final bgPaint = Paint()..style = PaintingStyle.fill;
    switch (themeIndex) {
      case 0:
        bgPaint.color = const Color(0xFF0D0B26); // Dark purple
        break;
      case 1:
        bgPaint.color = const Color(0xFF001F3F); // Deep ocean blue
        break;
      case 2:
        bgPaint.color = const Color(0xFF1A1A24); // Dark gray
        break;
      case 3:
        bgPaint.color = const Color(0xFF000000); // Black
        break;
      case 4:
        bgPaint.color = const Color(0xFFE8B273); // Sand
        break;
      case 5:
        bgPaint.color = const Color(0xFF111111); // Dark backing for stained glass
        break;
      default:
        bgPaint.color = Colors.black;
    }
    canvas.drawRect(Offset.zero & size, bgPaint);

    switch (themeIndex) {
      case 0: _drawNeurons(canvas, size, rand); break;
      case 1: _drawCoral(canvas, size, rand); break;
      case 2: _drawRain(canvas, size, rand); break;
      case 3: _drawMatrixCode(canvas, size, rand); break;
      case 4: _drawSanddunes(canvas, size, rand); break;
      case 5: _drawStainedGlass(canvas, size, rand); break;
    }
  }

  void _drawNeurons(Canvas canvas, Size size, Random rand) {
    // 0: Neurons
    final colors = [
      const Color(0xFF3B0086),
      const Color(0xFF9000B3),
      const Color(0xFFD400FF),
      const Color(0xFF00E5FF),
      const Color(0xFF4A90E2),
    ];
    
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final nodes = <Offset>[];
    for (int i = 0; i < 400; i++) {
      nodes.add(Offset(rand.nextDouble() * size.width, rand.nextDouble() * size.height));
    }

    // Connections (axons/dendrites)
    for (int i = 0; i < 2000; i++) {
      paint.color = colors[rand.nextInt(colors.length)].withOpacity(0.4 + rand.nextDouble() * 0.4);
      paint.strokeWidth = 0.5 + rand.nextDouble() * 2.5;
      
      final n1 = nodes[rand.nextInt(nodes.length)];
      final n2 = nodes[rand.nextInt(nodes.length)];
      
      final path = Path();
      path.moveTo(n1.dx, n1.dy);
      path.quadraticBezierTo(
        (n1.dx + n2.dx) / 2 + (rand.nextDouble() * 100 - 50),
        (n1.dy + n2.dy) / 2 + (rand.nextDouble() * 100 - 50),
        n2.dx, n2.dy
      );
      canvas.drawPath(path, paint);
    }
    
    // Nodes (somas)
    paint.style = PaintingStyle.fill;
    for (int i = 0; i < 1500; i++) {
      paint.color = colors[rand.nextInt(colors.length)].withOpacity(0.6 + rand.nextDouble() * 0.4);
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      final r = 1.0 + rand.nextDouble() * 6.0;
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  void _drawCoral(Canvas canvas, Size size, Random rand) {
    // 1: Coral
    final colors = [
      const Color(0xFFFF6F61), // Coral
      const Color(0xFFFFB2A7), // Light Coral
      const Color(0xFF00CED1), // Dark Turquoise
      const Color(0xFF20B2AA), // Light Sea Green
      const Color(0xFFFF8C00), // Dark Orange
      const Color(0xFFFF1493), // Deep Pink
    ];

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Seaweed and wavy corals
    for (int i = 0; i < 1500; i++) {
      paint.color = colors[rand.nextInt(colors.length)].withOpacity(0.5 + rand.nextDouble() * 0.4);
      paint.strokeWidth = 1.0 + rand.nextDouble() * 8.0;
      
      final startX = rand.nextDouble() * size.width;
      final startY = size.height + (rand.nextDouble() * 100);
      final height = 50 + rand.nextDouble() * (size.height * 0.8);
      
      final path = Path();
      path.moveTo(startX, startY);
      
      double curX = startX;
      double curY = startY;
      
      for (int j = 0; j < 5; j++) {
        final nextX = curX + (rand.nextDouble() * 80 - 40);
        final nextY = curY - (height / 5);
        
        path.quadraticBezierTo(
          curX + (rand.nextDouble() * 40 - 20),
          curY - (height / 10),
          nextX,
          nextY,
        );
        curX = nextX;
        curY = nextY;
      }
      canvas.drawPath(path, paint);
    }
    
    // Coral polyps / Bubbles
    paint.style = PaintingStyle.fill;
    for (int i = 0; i < 1500; i++) {
      paint.color = colors[rand.nextInt(colors.length)].withOpacity(0.7);
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      final r = 2.0 + rand.nextDouble() * 10.0;
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  void _drawRain(Canvas canvas, Size size, Random rand) {
    // 2: Rain
    final colors = [
      const Color(0xFF4B6584), // Slate
      const Color(0xFF778CA3), // Light Slate
      const Color(0xFFD1D8E0), // Gray
      const Color(0xFFFFFFFF), // White
      const Color(0xFF0FB9B1), // Teal hint
    ];

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Rain streaks
    for (int i = 0; i < 2500; i++) {
      paint.color = colors[rand.nextInt(colors.length)].withOpacity(0.1 + rand.nextDouble() * 0.6);
      paint.strokeWidth = 0.5 + rand.nextDouble() * 2.0;
      
      final x = rand.nextDouble() * (size.width + 200) - 100;
      final y = rand.nextDouble() * (size.height + 200) - 100;
      final length = 10 + rand.nextDouble() * 50;
      
      canvas.drawLine(
        Offset(x, y),
        Offset(x - (length * 0.3), y + length),
        paint
      );
    }
    
    // Splashes / Ripples
    paint.style = PaintingStyle.stroke;
    for (int i = 0; i < 1000; i++) {
      paint.color = colors[rand.nextInt(colors.length)].withOpacity(0.2 + rand.nextDouble() * 0.4);
      paint.strokeWidth = 0.5 + rand.nextDouble() * 1.5;
      
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      final rx = 5.0 + rand.nextDouble() * 20.0;
      final ry = rx * 0.3; // Perspective
      
      canvas.drawOval(Rect.fromCenter(center: Offset(x, y), width: rx * 2, height: ry * 2), paint);
    }
  }

  void _drawMatrixCode(Canvas canvas, Size size, Random rand) {
    // 3: Matrix Code
    final colors = [
      const Color(0xFF00FF41), // Matrix Green
      const Color(0xFF008F11), // Dark Green
      const Color(0xFF003B00), // Very Dark Green
      const Color(0xFFBFFFFA), // White/Green hint
    ];

    final paint = Paint()
      ..style = PaintingStyle.fill;

    // Columns of characters (simulated by small rects/shapes)
    for (int i = 0; i < 3000; i++) {
      paint.color = colors[rand.nextInt(colors.length)].withOpacity(0.3 + rand.nextDouble() * 0.7);
      
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      final w = 2.0 + rand.nextDouble() * 6.0;
      final h = w * (1.0 + rand.nextDouble() * 1.5);
      
      // Some simple random shapes to simulate glyphs
      final type = rand.nextInt(3);
      if (type == 0) {
        canvas.drawRect(Rect.fromLTWH(x, y, w, h), paint);
      } else if (type == 1) {
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = 1.0 + rand.nextDouble();
        canvas.drawRect(Rect.fromLTWH(x, y, w, h), paint);
        paint.style = PaintingStyle.fill;
      } else {
        canvas.drawLine(Offset(x, y), Offset(x + w, y + h), paint..strokeWidth = 1.5);
        canvas.drawLine(Offset(x + w, y), Offset(x, y + h), paint);
      }
      
      // Rain trail effect
      if (rand.nextDouble() > 0.8) {
        final trailLength = rand.nextInt(10) + 5;
        for (int j = 1; j < trailLength; j++) {
          paint.color = colors[1].withOpacity(0.5 * (1.0 - j / trailLength));
          canvas.drawRect(Rect.fromLTWH(x, y - (j * h * 1.5), w, h), paint);
        }
      }
    }
  }

  void _drawSanddunes(Canvas canvas, Size size, Random rand) {
    // 4: Sanddunes
    final colors = [
      const Color(0xFFD4A373),
      const Color(0xFFE9C46A),
      const Color(0xFFF4A261),
      const Color(0xFFE76F51),
      const Color(0xFF8A5A44),
    ];

    final paint = Paint()
      ..style = PaintingStyle.fill;

    // Sand dunes (overlapping wavy polygons)
    for (int i = 0; i < 500; i++) {
      paint.color = colors[rand.nextInt(colors.length)].withOpacity(0.1 + rand.nextDouble() * 0.2);
      
      final path = Path();
      final startY = rand.nextDouble() * size.height;
      path.moveTo(0, size.height);
      path.lineTo(0, startY);
      
      double curX = 0;
      double curY = startY;
      
      while (curX < size.width) {
        final nextX = curX + 50 + rand.nextDouble() * 150;
        final nextY = startY + (rand.nextDouble() * 100 - 50);
        path.quadraticBezierTo(
          curX + (nextX - curX) / 2,
          curY + (rand.nextDouble() * 60 - 30),
          nextX,
          nextY
        );
        curX = nextX;
        curY = nextY;
      }
      path.lineTo(size.width, size.height);
      path.close();
      canvas.drawPath(path, paint);
    }
    
    // Sand grains
    for (int i = 0; i < 2500; i++) {
      paint.color = colors[rand.nextInt(colors.length)].withOpacity(0.4 + rand.nextDouble() * 0.6);
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      final r = 0.5 + rand.nextDouble() * 2.0;
      canvas.drawCircle(Offset(x, y), r, paint);
    }
    
    // Wind sweeps (curves)
    paint.style = PaintingStyle.stroke;
    for (int i = 0; i < 500; i++) {
      paint.color = colors[rand.nextInt(colors.length)].withOpacity(0.2);
      paint.strokeWidth = 1.0 + rand.nextDouble() * 3.0;
      
      final startX = rand.nextDouble() * size.width;
      final startY = rand.nextDouble() * size.height;
      
      final path = Path();
      path.moveTo(startX, startY);
      path.quadraticBezierTo(
        startX + 50 + rand.nextDouble() * 100,
        startY - 20 - rand.nextDouble() * 50,
        startX + 100 + rand.nextDouble() * 200,
        startY + rand.nextDouble() * 50 - 25
      );
      canvas.drawPath(path, paint);
    }
  }

  void _drawStainedGlass(Canvas canvas, Size size, Random rand) {
    // 5: Stained Glass
    final colors = [
      const Color(0xFFE63946), // Red
      const Color(0xFFF1FAEE), // White/Ice
      const Color(0xFFA8DADC), // Light Blue
      const Color(0xFF457B9D), // Blue
      const Color(0xFF1D3557), // Dark Blue
      const Color(0xFFFFB703), // Yellow
      const Color(0xFFFB8500), // Orange
      const Color(0xFF8338EC), // Purple
    ];

    final paint = Paint()..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFF111111) // Lead came color
      ..strokeWidth = 2.0 + rand.nextDouble() * 4.0;

    // Simulate shards/glass pieces by drawing lots of intersecting overlapping polygons
    for (int i = 0; i < 1500; i++) {
      paint.color = colors[rand.nextInt(colors.length)].withOpacity(0.6 + rand.nextDouble() * 0.4);
      strokePaint.strokeWidth = 1.0 + rand.nextDouble() * 3.0;
      
      final cx = rand.nextDouble() * size.width;
      final cy = rand.nextDouble() * size.height;
      final radius = 10.0 + rand.nextDouble() * 60.0;
      final sides = 3 + rand.nextInt(4);
      
      final path = Path();
      for (int j = 0; j < sides; j++) {
        final angle = (j / sides) * 2 * pi + rand.nextDouble() * 0.5;
        final dist = radius * (0.5 + rand.nextDouble() * 0.5);
        final x = cx + cos(angle) * dist;
        final y = cy + sin(angle) * dist;
        if (j == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      
      canvas.drawPath(path, paint);
      canvas.drawPath(path, strokePaint);
    }
    
    // Long leading lines (lead cames) criss-crossing
    for (int i = 0; i < 200; i++) {
      strokePaint.strokeWidth = 2.0 + rand.nextDouble() * 6.0;
      
      final x1 = rand.nextDouble() * size.width;
      final y1 = rand.nextDouble() * size.height;
      final x2 = rand.nextDouble() * size.width;
      final y2 = rand.nextDouble() * size.height;
      
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
