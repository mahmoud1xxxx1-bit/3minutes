import 'dart:math';
import 'package:flutter/material.dart';

class PigeonPainterPack13 extends CustomPainter {
  final int seed;
  final int themeIndex;
  
  PigeonPainterPack13(this.seed, this.themeIndex);

  @override
  void paint(Canvas canvas, Size size) {
    final rand = Random(seed * 100 + themeIndex);
    switch (themeIndex) {
      case 0:
        _drawRadarSweeps(canvas, size, rand);
        break;
      case 1:
        _drawWindmills(canvas, size, rand);
        break;
      case 2:
        _drawTents(canvas, size, rand);
        break;
      case 3:
        _drawPyramids(canvas, size, rand);
        break;
      case 4:
        _drawPinecones(canvas, size, rand);
        break;
      case 5:
        _drawSpiderEyes(canvas, size, rand);
        break;
    }
  }

  void _drawRadarSweeps(Canvas canvas, Size size, Random rand) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF001A00),
    );

    final paint = Paint()..style = PaintingStyle.stroke;
    
    // Draw background grid
    paint.color = const Color(0xFF003300).withValues(alpha: 0.5);
    paint.strokeWidth = 1.0;
    for (int i = 0; i < size.width; i += 20) {
      canvas.drawLine(Offset(i.toDouble(), 0), Offset(i.toDouble(), size.height), paint);
    }
    for (int i = 0; i < size.height; i += 20) {
      canvas.drawLine(Offset(0, i.toDouble()), Offset(size.width, i.toDouble()), paint);
    }

    // Draw radar sweeps and circles
    for (int i = 0; i < 800; i++) {
      final cx = rand.nextDouble() * size.width;
      final cy = rand.nextDouble() * size.height;
      final maxRadius = rand.nextDouble() * 100 + 20;

      paint.color = const Color(0xFF00FF00).withValues(alpha: rand.nextDouble() * 0.3 + 0.1);
      paint.strokeWidth = rand.nextDouble() * 2 + 0.5;
      
      for (int j = 1; j <= 5; j++) {
        canvas.drawCircle(Offset(cx, cy), maxRadius * j / 5, paint);
      }

      final angle1 = rand.nextDouble() * pi * 2;
      final angle2 = angle1 + rand.nextDouble() * pi / 2;
      
      final fillPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = const Color(0xFF00FF00).withValues(alpha: rand.nextDouble() * 0.15);
      
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: maxRadius),
        angle1,
        angle2 - angle1,
        true,
        fillPaint,
      );

      // Draw random blips
      final blips = rand.nextInt(5);
      final blipPaint = Paint()..style = PaintingStyle.fill..color = const Color(0xFFFFFFFF);
      for (int k = 0; k < blips; k++) {
        final blipR = rand.nextDouble() * maxRadius;
        final blipAngle = rand.nextDouble() * pi * 2;
        canvas.drawCircle(
          Offset(cx + cos(blipAngle) * blipR, cy + sin(blipAngle) * blipR),
          rand.nextDouble() * 3 + 1,
          blipPaint,
        );
      }
    }
    
    for (int i = 0; i < 500; i++) {
      paint.color = Color.lerp(const Color(0xFF00FF00), const Color(0xFF00FFFF), rand.nextDouble())!.withValues(alpha: rand.nextDouble() * 0.4);
      final x1 = rand.nextDouble() * size.width;
      final y1 = rand.nextDouble() * size.height;
      final x2 = rand.nextDouble() * size.width;
      final y2 = rand.nextDouble() * size.height;
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }
  }

  void _drawWindmills(Canvas canvas, Size size, Random rand) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF87CEEB),
    );

    final bgColors = [
      const Color(0xFF90EE90),
      const Color(0xFF3CB371),
      const Color(0xFF228B22),
      const Color(0xFFD2B48C),
    ];

    for (int i = 0; i < 2000; i++) {
      final cx = rand.nextDouble() * size.width;
      final cy = rand.nextDouble() * size.height * 0.5 + size.height * 0.5;
      final r = rand.nextDouble() * 30 + 10;
      canvas.drawCircle(
        Offset(cx, cy),
        r,
        Paint()..color = bgColors[rand.nextInt(bgColors.length)].withValues(alpha: 0.6),
      );
    }

    final bladeColors = [
      const Color(0xFFF5F5DC),
      const Color(0xFFFFF8DC),
      const Color(0xFFDEB887),
    ];

    for (int i = 0; i < 800; i++) {
      final cx = rand.nextDouble() * size.width;
      final cy = rand.nextDouble() * size.height;
      final scale = rand.nextDouble() * 40 + 10;
      final angle = rand.nextDouble() * pi * 2;
      final blades = 3 + rand.nextInt(3);

      final paint = Paint()
        ..color = const Color(0xFF8B4513)
        ..style = PaintingStyle.fill;
      
      // Base
      canvas.drawRect(
        Rect.fromLTWH(cx - scale * 0.1, cy, scale * 0.2, scale * 1.5),
        paint,
      );

      // Blades
      paint.color = bladeColors[rand.nextInt(bladeColors.length)].withValues(alpha: 0.9);
      for (int j = 0; j < blades; j++) {
        final currentAngle = angle + j * (2 * pi / blades);
        final path = Path()
          ..moveTo(cx, cy)
          ..lineTo(cx + cos(currentAngle - 0.2) * scale * 0.2, cy + sin(currentAngle - 0.2) * scale * 0.2)
          ..lineTo(cx + cos(currentAngle) * scale, cy + sin(currentAngle) * scale)
          ..lineTo(cx + cos(currentAngle + 0.2) * scale * 0.2, cy + sin(currentAngle + 0.2) * scale * 0.2)
          ..close();
        canvas.drawPath(path, paint);
      }
      
      // Center
      canvas.drawCircle(Offset(cx, cy), scale * 0.1, Paint()..color = const Color(0xFFA0522D));
    }
  }

  void _drawTents(Canvas canvas, Size size, Random rand) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF2E8B57),
    );

    final tentColors = [
      const Color(0xFFFF6347),
      const Color(0xFF4682B4),
      const Color(0xFFFFD700),
      const Color(0xFFFF8C00),
      const Color(0xFFDA70D6),
    ];

    for (int i = 0; i < 2500; i++) {
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      final w = rand.nextDouble() * 40 + 15;
      final h = rand.nextDouble() * 30 + 15;

      final paint = Paint()
        ..color = tentColors[rand.nextInt(tentColors.length)].withValues(alpha: 0.85)
        ..style = PaintingStyle.fill;
      
      final path = Path()
        ..moveTo(x, y - h)
        ..lineTo(x - w / 2, y)
        ..lineTo(x + w / 2, y)
        ..close();
      
      canvas.drawPath(path, paint);
      
      // Tent opening
      paint.color = const Color(0xFF1A1A1A);
      final openingPath = Path()
        ..moveTo(x, y - h * 0.6)
        ..lineTo(x - w * 0.15, y)
        ..lineTo(x + w * 0.15, y)
        ..close();
      canvas.drawPath(openingPath, paint);

      // Strings
      paint.color = const Color(0xFFDDDDDD);
      paint.strokeWidth = 1.0;
      paint.style = PaintingStyle.stroke;
      canvas.drawLine(Offset(x, y - h), Offset(x - w * 0.8, y), paint);
      canvas.drawLine(Offset(x, y - h), Offset(x + w * 0.8, y), paint);
    }
  }

  void _drawPyramids(Canvas canvas, Size size, Random rand) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFF4A460),
    );

    for (int i = 0; i < 2000; i++) {
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      final sizeFactor = rand.nextDouble() * 60 + 20;

      final lightColor = Color.lerp(const Color(0xFFFFDAB9), const Color(0xFFDEB887), rand.nextDouble())!;
      final shadowColor = Color.lerp(const Color(0xFFCD853F), const Color(0xFF8B4513), rand.nextDouble())!;

      // Light side
      final pathLight = Path()
        ..moveTo(x, y - sizeFactor)
        ..lineTo(x - sizeFactor, y)
        ..lineTo(x + sizeFactor * 0.2, y + sizeFactor * 0.2)
        ..close();
      
      canvas.drawPath(pathLight, Paint()..color = lightColor.withValues(alpha: 0.9));

      // Shadow side
      final pathShadow = Path()
        ..moveTo(x, y - sizeFactor)
        ..lineTo(x + sizeFactor * 0.2, y + sizeFactor * 0.2)
        ..lineTo(x + sizeFactor, y - sizeFactor * 0.1)
        ..close();
      
      canvas.drawPath(pathShadow, Paint()..color = shadowColor.withValues(alpha: 0.9));
      
      // Horizontal lines on pyramid for block effect
      final linePaint = Paint()
        ..color = const Color(0x33000000)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      
      for (int j = 1; j < 5; j++) {
        final ratio = j / 5;
        final hY = y - sizeFactor * (1 - ratio);
        
        final lX = x - sizeFactor * ratio;
        final mX = x + sizeFactor * 0.2 * ratio;
        final mY = y + sizeFactor * 0.2 * ratio;
        final rX = x + sizeFactor * ratio;
        final rY = y - sizeFactor * 0.1 * ratio;
        
        canvas.drawLine(Offset(lX, hY), Offset(mX, mY - sizeFactor * (1-ratio)), linePaint);
        canvas.drawLine(Offset(mX, mY - sizeFactor * (1-ratio)), Offset(rX, rY - sizeFactor * (1-ratio)), linePaint);
      }
    }
  }

  void _drawPinecones(Canvas canvas, Size size, Random rand) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF3E2723),
    );

    for (int i = 0; i < 1500; i++) {
      final cx = rand.nextDouble() * size.width;
      final cy = rand.nextDouble() * size.height;
      final coneWidth = rand.nextDouble() * 30 + 20;
      final coneHeight = coneWidth * (rand.nextDouble() * 0.5 + 1.2);
      final angle = rand.nextDouble() * pi * 2;

      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(angle);

      final scales = 8 + rand.nextInt(8);
      for (int y = -scales; y < scales; y++) {
        final normalizedY = y / scales;
        final w = coneWidth * (1 - normalizedY * normalizedY.abs());
        
        final rowScales = 3 + rand.nextInt(4);
        for (int x = -rowScales; x <= rowScales; x++) {
          final px = (x / rowScales) * w;
          final py = y * (coneHeight / scales) * 0.8;
          
          final scalePaint = Paint()
            ..color = Color.lerp(const Color(0xFF5D4037), const Color(0xFF8D6E63), rand.nextDouble())!
            ..style = PaintingStyle.fill;
            
          final path = Path()
            ..moveTo(px, py)
            ..quadraticBezierTo(px - w * 0.3, py + coneHeight * 0.1, px, py + coneHeight * 0.15)
            ..quadraticBezierTo(px + w * 0.3, py + coneHeight * 0.1, px, py)
            ..close();
            
          canvas.drawPath(path, scalePaint);
          
          canvas.drawPath(path, Paint()
            ..color = const Color(0xFF261410)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0
          );
        }
      }
      canvas.restore();
    }
  }

  void _drawSpiderEyes(Canvas canvas, Size size, Random rand) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF110011),
    );

    final webPaint = Paint()
      ..color = const Color(0x22FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (int i = 0; i < 2000; i++) {
      final x1 = rand.nextDouble() * size.width;
      final y1 = rand.nextDouble() * size.height;
      final x2 = x1 + (rand.nextDouble() - 0.5) * 100;
      final y2 = y1 + (rand.nextDouble() - 0.5) * 100;
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), webPaint);
    }

    final eyeColors = [
      const Color(0xFFFF0000),
      const Color(0xFFCC0000),
      const Color(0xFFFF3333),
      const Color(0xFFFF6600),
    ];

    for (int i = 0; i < 1500; i++) {
      final cx = rand.nextDouble() * size.width;
      final cy = rand.nextDouble() * size.height;
      final angle = rand.nextDouble() * pi * 2;
      final baseSize = rand.nextDouble() * 6 + 2;
      final color = eyeColors[rand.nextInt(eyeColors.length)];
      
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(angle);

      void drawEye(double ex, double ey, double r) {
        // Glow
        canvas.drawCircle(Offset(ex, ey), r * 2.5, Paint()..color = color.withValues(alpha: 0.3));
        canvas.drawCircle(Offset(ex, ey), r * 1.5, Paint()..color = color.withValues(alpha: 0.6));
        // Solid
        canvas.drawCircle(Offset(ex, ey), r, Paint()..color = color);
        // Pupil/highlight
        canvas.drawCircle(Offset(ex - r * 0.2, ey - r * 0.2), r * 0.4, Paint()..color = const Color(0xFFFFFFFF));
        canvas.drawCircle(Offset(ex, ey), r * 0.6, Paint()..color = const Color(0xFF000000));
      }

      final spacing = baseSize * 2.5;
      
      // Main big pair
      drawEye(-spacing * 0.8, 0, baseSize);
      drawEye(spacing * 0.8, 0, baseSize);
      
      // Smaller side pairs
      drawEye(-spacing * 1.8, baseSize * 0.5, baseSize * 0.6);
      drawEye(spacing * 1.8, baseSize * 0.5, baseSize * 0.6);
      
      // Tiny top pairs
      drawEye(-spacing * 0.4, -baseSize * 1.2, baseSize * 0.4);
      drawEye(spacing * 0.4, -baseSize * 1.2, baseSize * 0.4);
      drawEye(-spacing * 1.2, -baseSize * 0.8, baseSize * 0.4);
      drawEye(spacing * 1.2, -baseSize * 0.8, baseSize * 0.4);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
