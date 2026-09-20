import 'dart:math';
import 'package:flutter/material.dart';

class PigeonPainterPack3 extends CustomPainter {
  final int seed;
  final int themeIndex;

  PigeonPainterPack3(this.seed, this.themeIndex);

  @override
  void paint(Canvas canvas, Size size) {
    final rand = Random(seed * 100 + themeIndex);
    switch (themeIndex) {
      case 0:
        _drawSteampunkGears(canvas, size, rand);
        break;
      case 1:
        _drawSpiderwebs(canvas, size, rand);
        break;
      case 2:
        _drawBookshelf(canvas, size, rand);
        break;
      case 3:
        _drawCrystals(canvas, size, rand);
        break;
      case 4:
        _drawBacteria(canvas, size, rand);
        break;
      case 5:
        _drawClockwork(canvas, size, rand);
        break;
    }
  }

  void _drawSteampunkGears(Canvas canvas, Size size, Random rand) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF2C1B10),
    );
    final colors = [
      const Color(0xFFB5A642),
      const Color(0xFFB87333),
      const Color(0xFF715F4C),
      const Color(0xFF8B4513),
      const Color(0xFF5A4D41),
    ];
    for (int i = 0; i < 2000; i++) {
      double cx = rand.nextDouble() * size.width;
      double cy = rand.nextDouble() * size.height;
      double radius = rand.nextDouble() * 50 + 10;
      int teeth = rand.nextInt(10) + 6;
      Color c = colors[rand.nextInt(colors.length)];

      final paint = Paint()
        ..color = c.withOpacity(rand.nextDouble() * 0.5 + 0.5)
        ..style = rand.nextBool() ? PaintingStyle.fill : PaintingStyle.stroke
        ..strokeWidth = rand.nextDouble() * 4 + 1;

      Path path = Path();
      for (int t = 0; t < teeth * 2; t++) {
        double angle = t * pi / teeth;
        double r = (t % 2 == 0) ? radius : radius * 0.8;
        double x = cx + cos(angle) * r;
        double y = cy + sin(angle) * r;
        if (t == 0) path.moveTo(x, y);
        else path.lineTo(x, y);
      }
      path.close();
      canvas.drawPath(path, paint);

      if (rand.nextBool()) {
        canvas.drawCircle(
          Offset(cx, cy),
          radius * 0.4,
          Paint()..color = const Color(0xFF1A0F09)..style = PaintingStyle.fill,
        );
      }
    }
  }

  void _drawSpiderwebs(Canvas canvas, Size size, Random rand) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF111115),
    );
    final paint = Paint()
      ..color = const Color(0xFFDCDCDC).withOpacity(0.3)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 3000; i++) {
      double x1 = rand.nextDouble() * size.width;
      double y1 = rand.nextDouble() * size.height;
      double x2 = x1 + (rand.nextDouble() - 0.5) * 100;
      double y2 = y1 + (rand.nextDouble() - 0.5) * 100;
      
      if (rand.nextDouble() < 0.05) {
        // center of a web
        double cx = rand.nextDouble() * size.width;
        double cy = rand.nextDouble() * size.height;
        for (int j = 0; j < 8; j++) {
          double angle = j * pi / 4 + rand.nextDouble();
          canvas.drawLine(
            Offset(cx, cy),
            Offset(cx + cos(angle) * 100, cy + sin(angle) * 100),
            paint,
          );
        }
        for (int j = 1; j < 5; j++) {
          canvas.drawCircle(Offset(cx, cy), j * 20.0, paint);
        }
      }

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }
  }

  void _drawBookshelf(Canvas canvas, Size size, Random rand) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF3E2723),
    );
    final colors = [
      const Color(0xFF8B0000),
      const Color(0xFF006400),
      const Color(0xFF4B0082),
      const Color(0xFFDAA520),
      const Color(0xFF2F4F4F),
      const Color(0xFF8B4513),
    ];
    for (int i = 0; i < 2000; i++) {
      double x = rand.nextDouble() * size.width;
      double y = rand.nextDouble() * size.height;
      double w = rand.nextDouble() * 20 + 10;
      double h = rand.nextDouble() * 80 + 40;
      Color c = colors[rand.nextInt(colors.length)];
      
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate((rand.nextDouble() - 0.5) * 0.5); // some lean
      
      final bookPaint = Paint()..color = c;
      canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bookPaint);
      
      // Details
      final linePaint = Paint()
        ..color = const Color(0xFFD4AF37)
        ..strokeWidth = 2;
      canvas.drawLine(const Offset(0, 10), Offset(w, 10), linePaint);
      canvas.drawLine(Offset(0, h - 10), Offset(w, h - 10), linePaint);
      
      canvas.restore();
    }
  }

  void _drawCrystals(Canvas canvas, Size size, Random rand) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF0F0F1B),
    );
    final colors = [
      const Color(0xFF8A2BE2),
      const Color(0xFF00FFFF),
      const Color(0xFFFF00FF),
      const Color(0xFF4B0082),
      const Color(0xFFE0FFFF),
    ];
    
    for (int i = 0; i < 2000; i++) {
      double cx = rand.nextDouble() * size.width;
      double cy = rand.nextDouble() * size.height;
      Color c = colors[rand.nextInt(colors.length)].withOpacity(0.4 + rand.nextDouble() * 0.4);
      
      final paint = Paint()
        ..color = c
        ..style = PaintingStyle.fill;
        
      final strokePaint = Paint()
        ..color = Colors.white.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      Path path = Path();
      int points = rand.nextInt(4) + 3; // 3 to 6
      double radiusX = rand.nextDouble() * 30 + 10;
      double radiusY = rand.nextDouble() * 80 + 20;
      double rotation = rand.nextDouble() * pi * 2;
      
      for (int p = 0; p < points; p++) {
        double angle = p * pi * 2 / points;
        double px = cx + cos(angle + rotation) * radiusX;
        double py = cy + sin(angle + rotation) * radiusY;
        if (p == 0) path.moveTo(px, py);
        else path.lineTo(px, py);
      }
      path.close();
      canvas.drawPath(path, paint);
      canvas.drawPath(path, strokePaint);
    }
  }

  void _drawBacteria(Canvas canvas, Size size, Random rand) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF051505),
    );
    final colors = [
      const Color(0xFF39FF14),
      const Color(0xFFCCFF00),
      const Color(0xFF8A2BE2),
      const Color(0xFFFF1493),
      const Color(0xFF00FA9A),
    ];
    for (int i = 0; i < 2500; i++) {
      double cx = rand.nextDouble() * size.width;
      double cy = rand.nextDouble() * size.height;
      double r = rand.nextDouble() * 20 + 5;
      Color c = colors[rand.nextInt(colors.length)].withOpacity(0.6);
      
      final paint = Paint()..color = c..style = PaintingStyle.fill;
      
      if (rand.nextBool()) {
        // draw a blob
        Path path = Path();
        for (int p = 0; p < 8; p++) {
          double angle = p * pi / 4;
          double rad = r + (rand.nextDouble() - 0.5) * r * 0.5;
          double px = cx + cos(angle) * rad;
          double py = cy + sin(angle) * rad;
          if (p == 0) path.moveTo(px, py);
          else path.lineTo(px, py);
        }
        path.close();
        canvas.drawPath(path, paint);
        
        // nucleus
        canvas.drawCircle(Offset(cx, cy), r * 0.3, Paint()..color = Colors.black.withOpacity(0.5));
      } else {
        // draw a squiggle
        Path path = Path();
        path.moveTo(cx, cy);
        double sx = cx;
        double sy = cy;
        for (int j = 0; j < 5; j++) {
          sx += (rand.nextDouble() - 0.5) * 40;
          sy += (rand.nextDouble() - 0.5) * 40;
          path.lineTo(sx, sy);
        }
        canvas.drawPath(path, Paint()..color = c..style = PaintingStyle.stroke..strokeWidth = 3.0);
      }
    }
  }

  void _drawClockwork(Canvas canvas, Size size, Random rand) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF0B1021),
    );
    final colors = [
      const Color(0xFFFFD700),
      const Color(0xFFC0C0C0),
      const Color(0xFFB87333),
      const Color(0xFF87CEEB),
    ];
    for (int i = 0; i < 2500; i++) {
      double cx = rand.nextDouble() * size.width;
      double cy = rand.nextDouble() * size.height;
      Color c = colors[rand.nextInt(colors.length)].withOpacity(0.5 + rand.nextDouble() * 0.5);
      
      int type = rand.nextInt(3);
      if (type == 0) {
        // arcs/rings
        double r = rand.nextDouble() * 60 + 10;
        canvas.drawArc(
          Rect.fromCircle(center: Offset(cx, cy), radius: r),
          rand.nextDouble() * pi * 2,
          rand.nextDouble() * pi,
          false,
          Paint()..color = c..style = PaintingStyle.stroke..strokeWidth = rand.nextDouble() * 3 + 1,
        );
      } else if (type == 1) {
        // ticks
        double r = rand.nextDouble() * 50 + 20;
        double angle = rand.nextDouble() * pi * 2;
        double r2 = r + rand.nextDouble() * 10 + 5;
        canvas.drawLine(
          Offset(cx + cos(angle) * r, cy + sin(angle) * r),
          Offset(cx + cos(angle) * r2, cy + sin(angle) * r2),
          Paint()..color = c..strokeWidth = 2,
        );
      } else {
        // springs / small circles
        double r = rand.nextDouble() * 15 + 2;
        canvas.drawCircle(
          Offset(cx, cy),
          r,
          Paint()..color = c..style = PaintingStyle.stroke..strokeWidth = 1.0,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
