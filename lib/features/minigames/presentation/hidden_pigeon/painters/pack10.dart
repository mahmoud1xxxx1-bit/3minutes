import 'dart:math';
import 'package:flutter/material.dart';

class PigeonPainterPack10 extends CustomPainter {
  final int seed;
  final int themeIndex;

  PigeonPainterPack10(this.seed, this.themeIndex);

  @override
  void paint(Canvas canvas, Size size) {
    final rand = Random(seed * 100 + themeIndex);
    switch (themeIndex) {
      case 0:
        _drawTheme0(canvas, size, rand);
        break;
      case 1:
        _drawTheme1(canvas, size, rand);
        break;
      case 2:
        _drawTheme2(canvas, size, rand);
        break;
      case 3:
        _drawTheme3(canvas, size, rand);
        break;
      case 4:
        _drawTheme4(canvas, size, rand);
        break;
      case 5:
        _drawTheme5(canvas, size, rand);
        break;
    }
  }

  void _drawTheme0(Canvas canvas, Size size, Random rand) {
    final colors = [
      Colors.redAccent, Colors.blueAccent, Colors.greenAccent,
      Colors.yellowAccent, Colors.purpleAccent, Colors.cyanAccent,
      Colors.pinkAccent, Colors.orangeAccent, Colors.tealAccent,
    ];
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white);
    for (int i = 0; i < 3500; i++) {
      final color = colors[rand.nextInt(colors.length)].withOpacity(rand.nextDouble() * 0.6 + 0.2);
      final paint = Paint()..color = color..style = PaintingStyle.fill;
      final cx = rand.nextDouble() * size.width;
      final cy = rand.nextDouble() * size.height;
      final radius = rand.nextDouble() * 50 + 5;
      
      if (rand.nextBool()) {
        canvas.drawCircle(Offset(cx, cy), radius, paint);
      } else {
        final path = Path();
        path.moveTo(cx, cy);
        for (int j = 0; j < 5; j++) {
          path.quadraticBezierTo(
            cx + (rand.nextDouble() - 0.5) * radius * 3,
            cy + (rand.nextDouble() - 0.5) * radius * 3,
            cx + (rand.nextDouble() - 0.5) * radius,
            cy + (rand.nextDouble() - 0.5) * radius,
          );
        }
        path.close();
        canvas.drawPath(path, paint);
      }
    }
  }

  void _drawTheme1(Canvas canvas, Size size, Random rand) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF2C1E16));
    final labelColors = [Colors.red, Colors.yellow, Colors.blue, Colors.green, Colors.purple, Colors.orange];
    
    for (int i = 0; i < 1500; i++) {
      final cx = rand.nextDouble() * size.width;
      final cy = rand.nextDouble() * size.height;
      final radius = rand.nextDouble() * 80 + 20;
      
      canvas.save();
      canvas.translate(cx, cy);
      
      // Black record
      canvas.drawCircle(Offset.zero, radius, Paint()..color = Colors.black87);
      
      // Grooves
      final groovePaint = Paint()..color = Colors.white24..style = PaintingStyle.stroke..strokeWidth = 0.5;
      for (double r = radius * 0.4; r < radius * 0.95; r += 3) {
        canvas.drawCircle(Offset.zero, r, groovePaint);
      }
      
      // Label
      final labelColor = labelColors[rand.nextInt(labelColors.length)];
      canvas.drawCircle(Offset.zero, radius * 0.35, Paint()..color = labelColor);
      
      // Center hole
      canvas.drawCircle(Offset.zero, radius * 0.05, Paint()..color = Colors.black);
      
      canvas.restore();
    }
  }

  void _drawTheme2(Canvas canvas, Size size, Random rand) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF333344));
    
    final clothColors = [Colors.blueGrey, Colors.indigo, Colors.brown, Colors.black54];
    final metalColors = [Colors.grey[300]!, Colors.amber[300]!, Colors.blueGrey[200]!];

    for (int i = 0; i < 2000; i++) {
      final cx = rand.nextDouble() * size.width;
      final cy = rand.nextDouble() * size.height;
      final angle = rand.nextDouble() * pi * 2;
      final length = rand.nextDouble() * 200 + 50;
      final width = rand.nextDouble() * 10 + 5;
      
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(angle);
      
      // Cloth backing
      final clothColor = clothColors[rand.nextInt(clothColors.length)].withOpacity(0.8);
      canvas.drawRect(Rect.fromLTWH(-length / 2, -width * 1.5, length, width * 3), Paint()..color = clothColor);
      
      // Teeth
      final metalColor = metalColors[rand.nextInt(metalColors.length)];
      final toothPaint = Paint()..color = metalColor;
      
      int numTeeth = (length / (width * 0.8)).floor();
      for (int t = 0; t < numTeeth; t++) {
        double x = -length / 2 + t * (width * 0.8);
        if (t % 2 == 0) {
          canvas.drawRect(Rect.fromLTWH(x, -width * 0.2, width * 0.6, width * 1.2), toothPaint);
        } else {
          canvas.drawRect(Rect.fromLTWH(x, -width * 1.0, width * 0.6, width * 1.2), toothPaint);
        }
      }
      canvas.restore();
    }
  }

  void _drawTheme3(Canvas canvas, Size size, Random rand) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF1A1A2E));
    
    final colors = [
      Colors.cyanAccent, Colors.blueAccent, Colors.orangeAccent,
      Colors.yellowAccent, Colors.greenAccent, Colors.purpleAccent, Colors.redAccent,
    ];
    
    final shapes = [
      [const Offset(0,0), const Offset(1,0), const Offset(2,0), const Offset(3,0)], // I
      [const Offset(0,0), const Offset(0,1), const Offset(1,0), const Offset(1,1)], // O
      [const Offset(0,0), const Offset(1,0), const Offset(2,0), const Offset(1,1)], // T
      [const Offset(0,0), const Offset(1,0), const Offset(1,1), const Offset(2,1)], // S
      [const Offset(0,1), const Offset(1,1), const Offset(1,0), const Offset(2,0)], // Z
      [const Offset(0,0), const Offset(0,1), const Offset(1,1), const Offset(2,1)], // J
      [const Offset(2,0), const Offset(0,1), const Offset(1,1), const Offset(2,1)], // L
    ];

    for (int i = 0; i < 3000; i++) {
      final shapeIdx = rand.nextInt(shapes.length);
      final shape = shapes[shapeIdx];
      final color = colors[shapeIdx].withOpacity(0.7);
      
      final cx = rand.nextDouble() * size.width;
      final cy = rand.nextDouble() * size.height;
      final blockSize = rand.nextDouble() * 20 + 10;
      final angle = (rand.nextInt(4)) * pi / 2;
      
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(angle);
      
      final paint = Paint()..color = color..style = PaintingStyle.fill;
      final strokePaint = Paint()..color = Colors.black54..style = PaintingStyle.stroke..strokeWidth = 2.0;
      
      for (final pt in shape) {
        final rect = Rect.fromLTWH(pt.dx * blockSize, pt.dy * blockSize, blockSize, blockSize);
        canvas.drawRect(rect, paint);
        canvas.drawRect(rect, strokePaint);
        // Highlight
        canvas.drawRect(
          Rect.fromLTWH(pt.dx * blockSize + 2, pt.dy * blockSize + 2, blockSize - 4, blockSize - 4),
          Paint()..color = Colors.white24,
        );
      }
      
      canvas.restore();
    }
  }

  void _drawTheme4(Canvas canvas, Size size, Random rand) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF050510));
    
    final starPaint = Paint()..color = Colors.white;
    for (int i = 0; i < 1000; i++) {
      canvas.drawCircle(
        Offset(rand.nextDouble() * size.width, rand.nextDouble() * size.height),
        rand.nextDouble() * 1.5,
        starPaint..color = Colors.white.withOpacity(rand.nextDouble()),
      );
    }
    
    final planetColors = [
      Colors.deepOrange, Colors.blueGrey, Colors.teal, Colors.indigo,
      Colors.brown, Colors.cyan, Colors.purple, Colors.red[900]!
    ];

    for (int i = 0; i < 1500; i++) {
      final cx = rand.nextDouble() * size.width;
      final cy = rand.nextDouble() * size.height;
      final radius = rand.nextDouble() * 60 + 10;
      
      canvas.save();
      canvas.translate(cx, cy);
      
      // Orbit rings
      final numRings = rand.nextInt(3) + 1;
      for (int r = 0; r < numRings; r++) {
        final ringRadius = radius + rand.nextDouble() * 40 + 10;
        final ringPaint = Paint()
          ..color = Colors.white24
          ..style = PaintingStyle.stroke
          ..strokeWidth = rand.nextDouble() * 2 + 0.5;
        canvas.drawOval(
          Rect.fromCenter(center: Offset.zero, width: ringRadius * 2, height: ringRadius * (rand.nextDouble() * 0.5 + 0.2)),
          ringPaint,
        );
      }
      
      // Planet
      final color = planetColors[rand.nextInt(planetColors.length)];
      final gradient = RadialGradient(
        colors: [color, Colors.black],
        center: const Alignment(-0.3, -0.3),
        radius: 0.8,
      );
      final planetPaint = Paint()
        ..shader = gradient.createShader(Rect.fromCircle(center: Offset.zero, radius: radius));
      canvas.drawCircle(Offset.zero, radius, planetPaint);
      
      canvas.restore();
    }
  }

  void _drawTheme5(Canvas canvas, Size size, Random rand) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF1E5631)); // Casino green
    
    for (int i = 0; i < 2500; i++) {
      final cx = rand.nextDouble() * size.width;
      final cy = rand.nextDouble() * size.height;
      final angle = rand.nextDouble() * pi * 2;
      
      final width = rand.nextDouble() * 20 + 20;
      final height = width * 2;
      
      final isBlack = rand.nextBool();
      final bodyColor = isBlack ? Colors.black87 : Colors.white;
      final dotColor = isBlack ? Colors.white : Colors.black87;
      
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(angle);
      
      // Shadow
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(-width/2 + 2, -height/2 + 3, width, height), const Radius.circular(5.0)),
        Paint()..color = Colors.black38,
      );
      
      // Body
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(-width/2, -height/2, width, height), const Radius.circular(5.0)),
        Paint()..color = bodyColor,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(-width/2, -height/2, width, height), const Radius.circular(5.0)),
        Paint()..color = Colors.grey..style = PaintingStyle.stroke..strokeWidth = 1.0,
      );
      
      // Center line
      canvas.drawLine(
        Offset(-width * 0.4, 0),
        Offset(width * 0.4, 0),
        Paint()..color = dotColor..strokeWidth = 1.5,
      );
      
      // Dots
      final dotPaint = Paint()..color = dotColor;
      final dotRadius = width * 0.08;
      final topDots = rand.nextInt(7);
      final bottomDots = rand.nextInt(7);
      
      void drawDot(double x, double y) {
        canvas.drawCircle(Offset(x * width * 0.25, y * height * 0.25), dotRadius, dotPaint);
      }
      
      // Draw top half dots
      if (topDots == 1 || topDots == 3 || topDots == 5) drawDot(0, -1);
      if (topDots > 1) { drawDot(-1, -1.5); drawDot(1, -0.5); }
      if (topDots > 3) { drawDot(-1, -0.5); drawDot(1, -1.5); }
      if (topDots == 6) { drawDot(-1, -1); drawDot(1, -1); }
      
      // Draw bottom half dots
      if (bottomDots == 1 || bottomDots == 3 || bottomDots == 5) drawDot(0, 1);
      if (bottomDots > 1) { drawDot(-1, 0.5); drawDot(1, 1.5); }
      if (bottomDots > 3) { drawDot(-1, 1.5); drawDot(1, 0.5); }
      if (bottomDots == 6) { drawDot(-1, 1); drawDot(1, 1); }
      
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
