import 'dart:math';
import 'package:flutter/material.dart';

class PigeonPainterPack12 extends CustomPainter {
  final int seed;
  final int themeIndex;

  PigeonPainterPack12(this.seed, this.themeIndex);

  @override
  void paint(Canvas canvas, Size size) {
    final rand = Random(seed * 100 + themeIndex);
    switch (themeIndex) {
      case 0:
        _drawDice(canvas, size, rand);
        break;
      case 1:
        _drawSeashells(canvas, size, rand);
        break;
      case 2:
        _drawMushrooms(canvas, size, rand);
        break;
      case 3:
        _drawTornPaper(canvas, size, rand);
        break;
      case 4:
        _drawLightbulbs(canvas, size, rand);
        break;
      case 5:
        _drawDiamonds(canvas, size, rand);
        break;
      default:
        _drawDiamonds(canvas, size, rand);
    }
  }

  // 0: Dice
  void _drawDice(Canvas canvas, Size size, Random rand) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF2C3E50));
    final diceColors = [
      const Color(0xFFE74C3C),
      const Color(0xFFECF0F1),
      const Color(0xFF3498DB),
      const Color(0xFFF1C40F),
    ];

    for (int i = 0; i < 2000; i++) {
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      final diceSize = 10.0 + rand.nextDouble() * 30.0;
      final paint = Paint()
        ..color = diceColors[rand.nextInt(diceColors.length)].withOpacity(0.8)
        ..style = PaintingStyle.fill;

      final strokePaint = Paint()
        ..color = Colors.black.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rand.nextDouble() * pi);
      final rect = RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: diceSize, height: diceSize),
          Radius.circular(diceSize * 0.2));
      
      canvas.drawRRect(rect, paint);
      canvas.drawRRect(rect, strokePaint);

      // Draw dots
      int val = rand.nextInt(6) + 1;
      final dotPaint = Paint()..color = (paint.color == const Color(0xFFECF0F1)) ? Colors.black87 : Colors.white;
      final d = diceSize * 0.2;
      
      void drawDot(double dx, double dy) {
        canvas.drawCircle(Offset(dx, dy), diceSize * 0.1, dotPaint);
      }

      if (val % 2 != 0) drawDot(0, 0); // Center
      if (val > 1) { drawDot(-d, -d); drawDot(d, d); }
      if (val > 3) { drawDot(-d, d); drawDot(d, -d); }
      if (val == 6) { drawDot(-d, 0); drawDot(d, 0); }

      canvas.restore();
    }
  }

  // 1: Seashells
  void _drawSeashells(Canvas canvas, Size size, Random rand) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF0C2461));
    final shellColors = [
      const Color(0xFFF8EFBA),
      const Color(0xFFFECA57),
      const Color(0xFFFF9FF3),
      const Color(0xFF54A0FF),
      const Color(0xFFE58E26),
    ];

    for (int i = 0; i < 2500; i++) {
      final cx = rand.nextDouble() * size.width;
      final cy = rand.nextDouble() * size.height;
      final radius = 10.0 + rand.nextDouble() * 30.0;
      final rotation = rand.nextDouble() * pi * 2;
      
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(rotation);

      final paint = Paint()
        ..color = shellColors[rand.nextInt(shellColors.length)].withOpacity(0.8)
        ..style = PaintingStyle.fill;
      final strokePaint = Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      if (rand.nextBool()) {
        // Spiral shell
        final path = Path();
        path.moveTo(0, 0);
        for (double t = 0; t < pi * 4; t += 0.2) {
          final r = (radius * 0.1) * t;
          path.lineTo(r * cos(t), r * sin(t));
        }
        canvas.drawPath(path, strokePaint..strokeWidth = 2.0..color = paint.color);
      } else {
        // Scallop shell
        final path = Path();
        path.moveTo(0, radius * 0.5);
        for (int j = 0; j <= 5; j++) {
          final a = -pi + (pi / 5) * j;
          path.lineTo(cos(a) * radius, sin(a) * radius);
        }
        path.close();
        canvas.drawPath(path, paint);
        canvas.drawPath(path, strokePaint);
        
        for (int j = 1; j < 5; j++) {
          final a = -pi + (pi / 5) * j;
          canvas.drawLine(Offset(0, radius * 0.5), Offset(cos(a) * radius, sin(a) * radius), strokePaint);
        }
      }
      canvas.restore();
    }
  }

  // 2: Mushrooms
  void _drawMushrooms(Canvas canvas, Size size, Random rand) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF2C3A47));
    final stemColor = const Color(0xFFF8EFBA);
    final capColors = [
      const Color(0xFFE84118),
      const Color(0xFF8C7AE6),
      const Color(0xFF44BD32),
      const Color(0xFF0097E6),
    ];

    for (int i = 0; i < 2000; i++) {
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      final mWidth = 10.0 + rand.nextDouble() * 30.0;
      final mHeight = mWidth * (0.8 + rand.nextDouble() * 0.6);
      
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate((rand.nextDouble() - 0.5) * pi * 0.5);

      // Stem
      final stemRect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(0, mHeight * 0.3), width: mWidth * 0.3, height: mHeight * 0.6),
        Radius.circular(mWidth * 0.1),
      );
      canvas.drawRRect(stemRect, Paint()..color = stemColor..style = PaintingStyle.fill);

      // Cap
      final capPath = Path();
      capPath.moveTo(-mWidth * 0.5, 0);
      capPath.quadraticBezierTo(0, -mHeight, mWidth * 0.5, 0);
      capPath.close();
      
      final cPaint = Paint()..color = capColors[rand.nextInt(capColors.length)].withOpacity(0.9);
      canvas.drawPath(capPath, cPaint);

      // Dots
      if (rand.nextBool()) {
        final dotPaint = Paint()..color = Colors.white.withOpacity(0.8);
        for (int d = 0; d < 3 + rand.nextInt(4); d++) {
          final dx = (rand.nextDouble() - 0.5) * mWidth * 0.8;
          final dy = -rand.nextDouble() * mHeight * 0.6;
          // check if inside roughly
          if (dx*dx + dy*dy < (mWidth*0.4)*(mWidth*0.4)) {
            canvas.drawCircle(Offset(dx, dy), mWidth * 0.05 + rand.nextDouble() * mWidth * 0.05, dotPaint);
          }
        }
      }

      canvas.restore();
    }
  }

  // 3: Torn Paper
  void _drawTornPaper(Canvas canvas, Size size, Random rand) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF95A5A6));
    final paperColors = [
      const Color(0xFFECF0F1),
      const Color(0xFFBDC3C7),
      const Color(0xFFFDFEFE),
      const Color(0xFFE5E7E9),
      const Color(0xFFD6DBDF),
    ];

    for (int i = 0; i < 1500; i++) {
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      final pSize = 30.0 + rand.nextDouble() * 70.0;
      
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rand.nextDouble() * pi * 2);

      final path = Path();
      final points = 8 + rand.nextInt(8);
      
      for (int p = 0; p < points; p++) {
        final angle = (p / points) * pi * 2;
        final r = pSize * 0.5 + rand.nextDouble() * pSize * 0.5; // Jagged
        final px = cos(angle) * r;
        final py = sin(angle) * r;
        if (p == 0) {
          path.moveTo(px, py);
        } else {
          path.lineTo(px, py);
        }
      }
      path.close();

      final color = paperColors[rand.nextInt(paperColors.length)];
      canvas.drawPath(path, Paint()..color = Colors.black.withOpacity(0.1)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0));
      canvas.drawPath(path, Paint()..color = color);
      
      canvas.restore();
    }
  }

  // 4: Lightbulbs
  void _drawLightbulbs(Canvas canvas, Size size, Random rand) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF192A56));
    final bulbColors = [
      const Color(0xFFFBC531),
      const Color(0xFF4CD137),
      const Color(0xFF00A8FF),
      const Color(0xFF9C88FF),
      const Color(0xFFE84118),
    ];

    for (int i = 0; i < 2000; i++) {
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      final scale = 0.5 + rand.nextDouble() * 1.5;
      final w = 15.0 * scale;
      final h = 25.0 * scale;
      
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rand.nextDouble() * pi * 2);

      final color = bulbColors[rand.nextInt(bulbColors.length)];
      final isLit = rand.nextDouble() > 0.3;

      // Glow
      if (isLit) {
        canvas.drawCircle(const Offset(0, -5), w, Paint()..color = color.withOpacity(0.2)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0));
      }

      // Bulb glass
      final path = Path();
      path.moveTo(-w * 0.4, h * 0.3);
      path.quadraticBezierTo(-w, 0, -w * 0.8, -h * 0.4);
      path.quadraticBezierTo(0, -h * 0.8, w * 0.8, -h * 0.4);
      path.quadraticBezierTo(w, 0, w * 0.4, h * 0.3);
      path.close();

      canvas.drawPath(path, Paint()..color = isLit ? color.withOpacity(0.7) : Colors.white24);
      canvas.drawPath(path, Paint()..color = Colors.white.withOpacity(0.5)..style = PaintingStyle.stroke..strokeWidth = 1.0);

      // Base
      canvas.drawRect(Rect.fromLTRB(-w * 0.4, h * 0.3, w * 0.4, h * 0.5), Paint()..color = Colors.grey[700]!);
      for (int k = 0; k < 3; k++) {
        final yy = h * 0.3 + (h * 0.2 / 3) * k;
        canvas.drawLine(Offset(-w * 0.4, yy), Offset(w * 0.4, yy), Paint()..color = Colors.black54..strokeWidth = 1.0);
      }
      canvas.drawCircle(Offset(0, h * 0.55), w * 0.2, Paint()..color = Colors.black87);

      canvas.restore();
    }
  }

  // 5: Diamonds
  void _drawDiamonds(Canvas canvas, Size size, Random rand) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF1E272E));
    final diamondColors = [
      const Color(0xFF0FBFC9),
      const Color(0xFF575FCF),
      const Color(0xFFEF5777),
      const Color(0xFF0BE881),
      const Color(0xFFFFC048),
    ];

    for (int i = 0; i < 3000; i++) {
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      final w = 10.0 + rand.nextDouble() * 20.0;
      final h = w * (1.2 + rand.nextDouble() * 0.8);
      
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rand.nextDouble() * pi * 2);

      final color = diamondColors[rand.nextInt(diamondColors.length)];

      final path = Path();
      path.moveTo(0, -h * 0.5); // Top
      path.lineTo(w * 0.5, 0);  // Right
      path.lineTo(0, h * 0.5);  // Bottom
      path.lineTo(-w * 0.5, 0); // Left
      path.close();

      final fillPaint = Paint()..color = color.withOpacity(0.6 + rand.nextDouble() * 0.4);
      final strokePaint = Paint()..color = Colors.white.withOpacity(0.5)..style = PaintingStyle.stroke..strokeWidth = 1.0;

      canvas.drawPath(path, fillPaint);
      
      // Facets
      canvas.drawLine(Offset(0, -h * 0.5), Offset(0, h * 0.5), strokePaint);
      canvas.drawLine(Offset(-w * 0.5, 0), Offset(w * 0.5, 0), strokePaint);
      canvas.drawPath(path, strokePaint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
