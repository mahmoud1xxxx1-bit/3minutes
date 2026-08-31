import 'dart:math';
import 'package:flutter/material.dart';

class PigeonPainterPack8 extends CustomPainter {
  final int seed;
  final int themeIndex;

  PigeonPainterPack8(this.seed, this.themeIndex);

  @override
  void paint(Canvas canvas, Size size) {
    final rand = Random(seed * 100 + themeIndex);
    switch (themeIndex) {
      case 0:
        _drawCoins(canvas, size, rand);
        break;
      case 1:
        _drawDNA(canvas, size, rand);
        break;
      case 2:
        _drawBarcodes(canvas, size, rand);
        break;
      case 3:
        _drawPaperAirplanes(canvas, size, rand);
        break;
      case 4:
        _drawBlueprints(canvas, size, rand);
        break;
      case 5:
        _drawTribalPatterns(canvas, size, rand);
        break;
    }
  }

  void _drawCoins(Canvas canvas, Size size, Random rand) {
    final bgPaint = Paint()..color = const Color(0xFF2C1C11);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final colors = [
      const Color(0xFFFFD700), // Gold
      const Color(0xFFC0C0C0), // Silver
      const Color(0xFFCD7F32), // Bronze
      const Color(0xFFB8860B), // Dark Gold
      const Color(0xFFA9A9A9), // Dark Gray
    ];

    for (int i = 0; i < 2000; i++) {
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      final radius = 10 + rand.nextDouble() * 30;
      final color = colors[rand.nextInt(colors.length)];

      final coinPaint = Paint()
        ..color = color.withValues(alpha: 0.8 + rand.nextDouble() * 0.2)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), radius, coinPaint);

      final edgePaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(Offset(x, y), radius, edgePaint);

      final innerPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(Offset(x, y), radius * 0.75, innerPaint);
    }
  }

  void _drawDNA(Canvas canvas, Size size, Random rand) {
    final bgPaint = Paint()..color = const Color(0xFF0F172A);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final colors1 = [const Color(0xFF38BDF8), const Color(0xFF0EA5E9)];
    final colors2 = [const Color(0xFFF472B6), const Color(0xFFEC4899)];
    final rungColors = [const Color(0xFFFDE047), const Color(0xFF86EFAC)];

    for (int i = 0; i < 300; i++) {
      final startX = rand.nextDouble() * size.width;
      final startY = rand.nextDouble() * size.height;
      final angle = rand.nextDouble() * pi * 2;
      final length = 100 + rand.nextDouble() * 200;
      final amplitude = 10 + rand.nextDouble() * 20;
      final frequency = 0.05 + rand.nextDouble() * 0.1;

      canvas.save();
      canvas.translate(startX, startY);
      canvas.rotate(angle);

      final paint1 = Paint()
        ..color = colors1[rand.nextInt(colors1.length)].withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      final paint2 = Paint()
        ..color = colors2[rand.nextInt(colors2.length)].withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      final rungPaint = Paint()
        ..color = rungColors[rand.nextInt(rungColors.length)].withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      for (double x = 0; x < length; x += 5) {
        final y1 = sin(x * frequency) * amplitude;
        final y2 = sin(x * frequency + pi) * amplitude;

        if (x % 15 < 5) {
          canvas.drawLine(Offset(x, y1), Offset(x, y2), rungPaint);
        }
      }

      final path1 = Path();
      final path2 = Path();
      for (double x = 0; x <= length; x++) {
        final y1 = sin(x * frequency) * amplitude;
        final y2 = sin(x * frequency + pi) * amplitude;
        if (x == 0) {
          path1.moveTo(x, y1);
          path2.moveTo(x, y2);
        } else {
          path1.lineTo(x, y1);
          path2.lineTo(x, y2);
        }
      }
      canvas.drawPath(path1, paint1);
      canvas.drawPath(path2, paint2);

      canvas.restore();
    }
  }

  void _drawBarcodes(Canvas canvas, Size size, Random rand) {
    final bgPaint = Paint()..color = const Color(0xFFF8FAFC);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final paint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 2000; i++) {
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      final w = 1 + rand.nextDouble() * 8;
      final h = 30 + rand.nextDouble() * 100;
      
      canvas.drawRect(Rect.fromLTWH(x, y, w, h), paint);
    }
  }

  void _drawPaperAirplanes(Canvas canvas, Size size, Random rand) {
    final bgPaint = Paint()..color = const Color(0xFF87CEEB);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    for (int i = 0; i < 1500; i++) {
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      final scale = 0.5 + rand.nextDouble() * 1.5;
      final angle = rand.nextDouble() * pi * 2;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle);
      canvas.scale(scale);

      final planePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.8 + rand.nextDouble() * 0.2)
        ..style = PaintingStyle.fill;
      
      final shadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.2)
        ..style = PaintingStyle.fill;

      final strokePaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;

      // Draw shadow
      final shadowPath = Path()
        ..moveTo(-10, -10)
        ..lineTo(20, 5)
        ..lineTo(-10, 20)
        ..lineTo(-5, 5)
        ..close();
      canvas.drawPath(shadowPath, shadowPaint);

      // Draw plane
      final planePath1 = Path()
        ..moveTo(-15, -15)
        ..lineTo(15, 0)
        ..lineTo(-10, 5)
        ..close();
      canvas.drawPath(planePath1, planePaint);
      canvas.drawPath(planePath1, strokePaint);

      final planePath2 = Path()
        ..moveTo(-15, 15)
        ..lineTo(15, 0)
        ..lineTo(-10, 5)
        ..close();
      
      final planePaint2 = Paint()
        ..color = const Color(0xFFE0E0E0).withValues(alpha: 0.9)
        ..style = PaintingStyle.fill;
      canvas.drawPath(planePath2, planePaint2);
      canvas.drawPath(planePath2, strokePaint);

      canvas.restore();
    }
  }

  void _drawBlueprints(Canvas canvas, Size size, Random rand) {
    final bgPaint = Paint()..color = const Color(0xFF003366);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (double i = 0; i < size.width; i += 20) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }
    for (double i = 0; i < size.height; i += 20) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPaint);
    }

    final blueprintPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final fillPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 1500; i++) {
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      final shapeType = rand.nextInt(3);

      switch (shapeType) {
        case 0:
          final r = 10 + rand.nextDouble() * 50;
          canvas.drawCircle(Offset(x, y), r, blueprintPaint);
          if (rand.nextBool()) {
            canvas.drawCircle(Offset(x, y), r * 0.8, blueprintPaint);
          }
          break;
        case 1:
          final w = 20 + rand.nextDouble() * 80;
          final h = 20 + rand.nextDouble() * 80;
          final rect = Rect.fromLTWH(x, y, w, h);
          canvas.drawRect(rect, blueprintPaint);
          canvas.drawLine(rect.topLeft, rect.bottomRight, blueprintPaint);
          canvas.drawLine(rect.topRight, rect.bottomLeft, blueprintPaint);
          break;
        case 2:
          final p = Path();
          p.moveTo(x, y);
          for (int j = 0; j < 5; j++) {
            p.lineTo(
              x + (rand.nextDouble() - 0.5) * 100,
              y + (rand.nextDouble() - 0.5) * 100,
            );
          }
          p.close();
          canvas.drawPath(p, fillPaint);
          canvas.drawPath(p, blueprintPaint);
          break;
      }
    }
  }

  void _drawTribalPatterns(Canvas canvas, Size size, Random rand) {
    final bgPaint = Paint()..color = const Color(0xFF3E2723);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final colors = [
      const Color(0xFFD84315), // Deep Orange
      const Color(0xFFFF8F00), // Amber
      const Color(0xFFFBC02D), // Yellow
      const Color(0xFF5D4037), // Brown
      const Color(0xFF8D6E63), // Light Brown
      const Color(0xFF212121), // Dark Gray
    ];

    for (int i = 0; i < 2000; i++) {
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      final s = 20 + rand.nextDouble() * 60;
      final color = colors[rand.nextInt(colors.length)];

      final paint = Paint()
        ..color = color.withValues(alpha: 0.8)
        ..style = PaintingStyle.fill;
      
      final strokePaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rand.nextInt(4) * pi / 2); // 90 degree increments

      final type = rand.nextInt(3);
      if (type == 0) {
        // Diamond
        final p = Path()
          ..moveTo(0, -s/2)
          ..lineTo(s/2, 0)
          ..lineTo(0, s/2)
          ..lineTo(-s/2, 0)
          ..close();
        canvas.drawPath(p, paint);
        canvas.drawPath(p, strokePaint);
      } else if (type == 1) {
        // Zig-zag / Triangles
        final p = Path()
          ..moveTo(-s/2, -s/2)
          ..lineTo(0, s/2)
          ..lineTo(s/2, -s/2)
          ..close();
        canvas.drawPath(p, paint);
        canvas.drawPath(p, strokePaint);
      } else {
        // Blocks
        final rect = Rect.fromCenter(center: Offset.zero, width: s, height: s/2);
        canvas.drawRect(rect, paint);
        canvas.drawRect(rect, strokePaint);
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
