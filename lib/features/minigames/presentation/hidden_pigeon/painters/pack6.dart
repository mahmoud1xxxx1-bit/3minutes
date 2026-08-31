import 'dart:math';
import 'package:flutter/material.dart';

class PigeonPainterPack6 extends CustomPainter {
  final int seed;
  final int themeIndex;
  
  PigeonPainterPack6(this.seed, this.themeIndex);

  @override
  void paint(Canvas canvas, Size size) {
    final rand = Random(seed * 100 + themeIndex);
    switch (themeIndex) {
      case 0: _drawMicrochips(canvas, size, rand); break;
      case 1: _drawConstellations(canvas, size, rand); break;
      case 2: _drawJigsawPuzzles(canvas, size, rand); break;
      case 3: _drawOrigami(canvas, size, rand); break;
      case 4: _drawAbstractSwirls(canvas, size, rand); break;
      case 5: _drawAutumnLeaves(canvas, size, rand); break;
    }
  }

  void _drawMicrochips(Canvas canvas, Size size, Random rand) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF0C2411),
    );

    final colors = [
      const Color(0xFF1E5629),
      const Color(0xFF328241),
      const Color(0xFFB5933C),
      const Color(0xFFD4B15C),
      const Color(0xFF6B8A72),
    ];

    for (int i = 0; i < 2500; i++) {
      final paint = Paint()
        ..color = colors[rand.nextInt(colors.length)]
        ..strokeWidth = rand.nextDouble() * 3 + 1
        ..style = rand.nextBool() ? PaintingStyle.stroke : PaintingStyle.fill;

      final startX = rand.nextDouble() * size.width;
      final startY = rand.nextDouble() * size.height;

      if (rand.nextBool()) {
        // Draw traces
        final path = Path()..moveTo(startX, startY);
        double curX = startX;
        double curY = startY;
        for (int j = 0; j < 5; j++) {
          if (rand.nextBool()) {
            curX += (rand.nextBool() ? 1 : -1) * (rand.nextDouble() * 40 + 10);
          } else {
            curY += (rand.nextBool() ? 1 : -1) * (rand.nextDouble() * 40 + 10);
          }
          path.lineTo(curX, curY);
        }
        canvas.drawPath(path, paint..style = PaintingStyle.stroke);
        canvas.drawCircle(Offset(curX, curY), rand.nextDouble() * 3 + 2, paint..style = PaintingStyle.fill);
      } else {
        // Draw chips/pads
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(startX, startY),
            width: rand.nextDouble() * 30 + 5,
            height: rand.nextDouble() * 30 + 5,
          ),
          paint,
        );
      }
    }
  }

  void _drawConstellations(Canvas canvas, Size size, Random rand) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF030B1C),
    );

    final colors = [
      const Color(0xFFFFFFFF),
      const Color(0xFFB3E5FC),
      const Color(0xFF81D4FA),
      const Color(0xFFE1BEE7),
      const Color(0xFFFFF59D),
    ];

    final paintLine = Paint()
      ..color = const Color(0x66FFFFFF)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    List<Offset> points = [];
    for (int i = 0; i < 3000; i++) {
      points.add(Offset(rand.nextDouble() * size.width, rand.nextDouble() * size.height));
    }

    for (int i = 0; i < points.length; i++) {
      final p1 = points[i];
      // Connect to a few nearby points
      int connections = 0;
      for (int j = i + 1; j < points.length && connections < 3; j++) {
        final p2 = points[j];
        if ((p1 - p2).distance < 40) {
          canvas.drawLine(p1, p2, paintLine);
          connections++;
        }
      }
      
      final paintDot = Paint()
        ..color = colors[rand.nextInt(colors.length)]
        ..style = PaintingStyle.fill;
      canvas.drawCircle(p1, rand.nextDouble() * 2 + 0.5, paintDot);
      
      // Some glow
      if (rand.nextDouble() < 0.1) {
        canvas.drawCircle(p1, rand.nextDouble() * 5 + 2, Paint()..color = paintDot.color.withValues(alpha: 0.3)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
      }
    }
  }

  void _drawJigsawPuzzles(Canvas canvas, Size size, Random rand) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFFDDDDDD),
    );

    for (int i = 0; i < 2000; i++) {
      final color = Color.fromARGB(
        255,
        100 + rand.nextInt(156),
        100 + rand.nextInt(156),
        100 + rand.nextInt(156),
      );
      
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
        
      final borderPaint = Paint()
        ..color = Colors.black38
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      final cx = rand.nextDouble() * size.width;
      final cy = rand.nextDouble() * size.height;
      final w = rand.nextDouble() * 40 + 30;
      final h = rand.nextDouble() * 40 + 30;
      
      final path = Path();
      path.moveTo(cx - w/2, cy - h/2);
      
      // Top edge
      if (rand.nextBool()) {
        path.quadraticBezierTo(cx, cy - h, cx + w/2, cy - h/2);
      } else {
        path.lineTo(cx + w/2, cy - h/2);
      }
      
      // Right edge
      if (rand.nextBool()) {
        path.quadraticBezierTo(cx + w, cy, cx + w/2, cy + h/2);
      } else {
        path.lineTo(cx + w/2, cy + h/2);
      }
      
      // Bottom edge
      if (rand.nextBool()) {
        path.quadraticBezierTo(cx, cy + h, cx - w/2, cy + h/2);
      } else {
        path.lineTo(cx - w/2, cy + h/2);
      }
      
      // Left edge
      if (rand.nextBool()) {
        path.quadraticBezierTo(cx - w, cy, cx - w/2, cy - h/2);
      } else {
        path.lineTo(cx - w/2, cy - h/2);
      }
      
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(rand.nextDouble() * pi * 2);
      canvas.translate(-cx, -cy);
      
      canvas.drawPath(path, paint);
      canvas.drawPath(path, borderPaint);
      
      canvas.restore();
    }
  }

  void _drawOrigami(Canvas canvas, Size size, Random rand) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFFF0F0F0),
    );

    final colors = [
      const Color(0xFFFFCDD2),
      const Color(0xFFF8BBD0),
      const Color(0xFFE1BEE7),
      const Color(0xFFD1C4E9),
      const Color(0xFFC5CAE9),
      const Color(0xFFB3E5FC),
      const Color(0xFFB2DFDB),
      const Color(0xFFDCEDC8),
      const Color(0xFFFFF9C4),
      const Color(0xFFFFE0B2),
      const Color(0xFFFFCCBC),
      const Color(0xFFFFFFFF),
    ];

    for (int i = 0; i < 2500; i++) {
      final cx = rand.nextDouble() * size.width;
      final cy = rand.nextDouble() * size.height;
      final r = rand.nextDouble() * 50 + 20;
      
      final pts = <Offset>[];
      int sides = rand.nextInt(3) + 3; // 3 to 5 sides
      
      for (int j = 0; j < sides; j++) {
        final angle = rand.nextDouble() * pi * 2;
        final dist = rand.nextDouble() * r;
        pts.add(Offset(cx + cos(angle) * dist, cy + sin(angle) * dist));
      }
      
      final path = Path()..moveTo(pts[0].dx, pts[0].dy);
      for (int j = 1; j < pts.length; j++) {
        path.lineTo(pts[j].dx, pts[j].dy);
      }
      path.close();
      
      final paint = Paint()
        ..color = colors[rand.nextInt(colors.length)]
        ..style = PaintingStyle.fill;
        
      final border = Paint()
        ..color = Colors.black12
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;
        
      canvas.drawPath(path, paint);
      
      // Draw internal fold lines
      for (int j = 0; j < pts.length; j++) {
        for (int k = j + 2; k < pts.length; k++) {
          if (rand.nextDouble() < 0.3) {
            canvas.drawLine(pts[j], pts[k], border);
          }
        }
      }
      
      canvas.drawPath(path, border);
    }
  }

  void _drawAbstractSwirls(Canvas canvas, Size size, Random rand) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF111111),
    );

    final colors = [
      const Color(0xFFFF007F),
      const Color(0xFF00E5FF),
      const Color(0xFFFFD700),
      const Color(0xFF8A2BE2),
      const Color(0xFFFF4500),
    ];

    for (int i = 0; i < 2000; i++) {
      final paint = Paint()
        ..color = colors[rand.nextInt(colors.length)].withValues(alpha: rand.nextDouble() * 0.6 + 0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = rand.nextDouble() * 8 + 1
        ..strokeCap = StrokeCap.round;

      final path = Path();
      final startX = rand.nextDouble() * size.width;
      final startY = rand.nextDouble() * size.height;
      path.moveTo(startX, startY);

      double curX = startX;
      double curY = startY;

      for (int j = 0; j < 4; j++) {
        final cp1x = curX + (rand.nextDouble() * 200 - 100);
        final cp1y = curY + (rand.nextDouble() * 200 - 100);
        final cp2x = curX + (rand.nextDouble() * 200 - 100);
        final cp2y = curY + (rand.nextDouble() * 200 - 100);
        final endX = curX + (rand.nextDouble() * 150 - 75);
        final endY = curY + (rand.nextDouble() * 150 - 75);

        path.cubicTo(cp1x, cp1y, cp2x, cp2y, endX, endY);
        curX = endX;
        curY = endY;
      }
      canvas.drawPath(path, paint);
    }
  }

  void _drawAutumnLeaves(Canvas canvas, Size size, Random rand) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF3E2723),
    );

    final colors = [
      const Color(0xFFD84315),
      const Color(0xFFBF360C),
      const Color(0xFFF9A825),
      const Color(0xFFF57F17),
      const Color(0xFF8D6E63),
      const Color(0xFF5D4037),
      const Color(0xFF2E7D32),
    ];

    for (int i = 0; i < 3000; i++) {
      final cx = rand.nextDouble() * size.width;
      final cy = rand.nextDouble() * size.height;
      final length = rand.nextDouble() * 40 + 10;
      final width = length * (rand.nextDouble() * 0.4 + 0.3);
      
      final color = colors[rand.nextInt(colors.length)];
      
      final paint = Paint()
        ..color = color.withValues(alpha: 0.9)
        ..style = PaintingStyle.fill;
        
      final veinPaint = Paint()
        ..color = color.computeLuminance() > 0.3 ? Colors.black38 : Colors.white38
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(rand.nextDouble() * pi * 2);
      
      final path = Path();
      path.moveTo(-length/2, 0);
      path.quadraticBezierTo(0, -width, length/2, 0);
      path.quadraticBezierTo(0, width, -length/2, 0);
      
      canvas.drawPath(path, paint);
      canvas.drawLine(Offset(-length/2, 0), Offset(length/2, 0), veinPaint);
      
      // Small veins
      for (double x = -length/4; x < length/3; x += length/4) {
        canvas.drawLine(Offset(x, 0), Offset(x + length/6, width/2), veinPaint);
        canvas.drawLine(Offset(x, 0), Offset(x + length/6, -width/2), veinPaint);
      }
      
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
