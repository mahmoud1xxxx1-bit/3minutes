import 'dart:math';
import 'package:flutter/material.dart';

class PigeonPainterPack15 extends CustomPainter {
  final int seed;
  final int themeIndex;

  PigeonPainterPack15(this.seed, this.themeIndex);

  @override
  void paint(Canvas canvas, Size size) {
    final rand = Random(seed * 100 + themeIndex);
    switch (themeIndex) {
      case 0:
        _drawPlaidPatterns(canvas, size, rand);
        break;
      case 1:
        _drawCheckerboards(canvas, size, rand);
        break;
      case 2:
        _drawZigZags(canvas, size, rand);
        break;
      case 3:
        _drawCelticKnots(canvas, size, rand);
        break;
      case 4:
        _drawConcentricRings(canvas, size, rand);
        break;
      case 5:
        _drawHashMarks(canvas, size, rand);
        break;
    }
  }

  void _drawPlaidPatterns(Canvas canvas, Size size, Random rand) {
    canvas.drawRect(
        Offset.zero & size,
        Paint()..color = const Color(0xFFF0E5D8));
    final colors = [
      const Color(0x88D32F2F),
      const Color(0x881976D2),
      const Color(0x88388E3C),
      const Color(0x88FBC02D),
      const Color(0x887B1FA2),
      const Color(0x88E64A19),
    ];
    
    for (int i = 0; i < 3000; i++) {
      final paint = Paint()
        ..color = colors[rand.nextInt(colors.length)]
        ..style = PaintingStyle.fill
        ..blendMode = BlendMode.multiply;
        
      bool isVertical = rand.nextBool();
      double width = 5 + rand.nextDouble() * 30;
      double pos = rand.nextDouble() * (isVertical ? size.width : size.height);
      
      if (isVertical) {
        canvas.drawRect(Rect.fromLTWH(pos, 0, width, size.height), paint);
      } else {
        canvas.drawRect(Rect.fromLTWH(0, pos, size.width, width), paint);
      }
    }
  }

  void _drawCheckerboards(Canvas canvas, Size size, Random rand) {
    canvas.drawRect(
        Offset.zero & size,
        Paint()..color = const Color(0xFF222222));
        
    final colors = [
      const Color(0xFFEEEEEE),
      const Color(0xFFFF5252),
      const Color(0xFF448AFF),
      const Color(0xFFFFAB40),
      const Color(0xFF69F0AE),
    ];
    
    for (int i = 0; i < 3000; i++) {
      double tileSize = 10 + rand.nextDouble() * 50;
      int cols = 3 + rand.nextInt(5);
      int rows = 3 + rand.nextInt(5);
      
      double x = rand.nextDouble() * size.width - tileSize;
      double y = rand.nextDouble() * size.height - tileSize;
      
      final color1 = colors[rand.nextInt(colors.length)].withOpacity(0.7);
      final color2 = colors[rand.nextInt(colors.length)].withOpacity(0.7);
      
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rand.nextDouble() * pi / 4);
      
      for (int r = 0; r < rows; r++) {
        for (int c = 0; c < cols; c++) {
          final paint = Paint()..color = ((r + c) % 2 == 0) ? color1 : color2;
          canvas.drawRect(Rect.fromLTWH(c * tileSize, r * tileSize, tileSize, tileSize), paint);
        }
      }
      canvas.restore();
    }
  }

  void _drawZigZags(Canvas canvas, Size size, Random rand) {
    canvas.drawRect(
        Offset.zero & size,
        Paint()..color = const Color(0xFFE8F5E9));
        
    final colors = [
      const Color(0xFF43A047),
      const Color(0xFF1E88E5),
      const Color(0xFFE53935),
      const Color(0xFFFFB300),
      const Color(0xFF8E24AA),
    ];
    
    for (int i = 0; i < 2000; i++) {
      final paint = Paint()
        ..color = colors[rand.nextInt(colors.length)].withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 + rand.nextDouble() * 8
        ..strokeJoin = StrokeJoin.miter;
        
      double startX = rand.nextDouble() * size.width;
      double startY = rand.nextDouble() * size.height;
      
      Path path = Path();
      path.moveTo(startX, startY);
      
      int points = 10 + rand.nextInt(20);
      double segLength = 10 + rand.nextDouble() * 40;
      double angle = rand.nextDouble() * pi * 2;
      double angleJitter = pi / 3;
      
      double curX = startX;
      double curY = startY;
      
      for (int p = 0; p < points; p++) {
        double currentAngle = angle + (p % 2 == 0 ? angleJitter : -angleJitter);
        curX += cos(currentAngle) * segLength;
        curY += sin(currentAngle) * segLength;
        path.lineTo(curX, curY);
      }
      
      canvas.drawPath(path, paint);
    }
  }

  void _drawCelticKnots(Canvas canvas, Size size, Random rand) {
    canvas.drawRect(
        Offset.zero & size,
        Paint()..color = const Color(0xFF2E151B));
        
    final colors = [
      const Color(0xFFDAA520),
      const Color(0xFFB8860B),
      const Color(0xFFF0E68C),
      const Color(0xFFCD853F),
      const Color(0xFFD2B48C),
    ];
    
    for (int i = 0; i < 1500; i++) {
      final paint = Paint()
        ..color = colors[rand.nextInt(colors.length)].withOpacity(0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3 + rand.nextDouble() * 6
        ..strokeCap = StrokeCap.round;
        
      double cx = rand.nextDouble() * size.width;
      double cy = rand.nextDouble() * size.height;
      double radius = 10 + rand.nextDouble() * 50;
      
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(rand.nextDouble() * pi);
      
      Path path = Path();
      for (int j = 0; j < 3; j++) {
        double ang = j * 2 * pi / 3;
        double px = cos(ang) * radius;
        double py = sin(ang) * radius;
        path.addArc(Rect.fromCircle(center: Offset(px, py), radius: radius * 0.7), ang - pi, pi * 1.5);
      }
      
      canvas.drawPath(path, paint);
      canvas.drawCircle(Offset.zero, radius * 1.2, paint..strokeWidth = 2);
      
      canvas.restore();
    }
  }

  void _drawConcentricRings(Canvas canvas, Size size, Random rand) {
    canvas.drawRect(
        Offset.zero & size,
        Paint()..color = const Color(0xFF001F3F));
        
    final colors = [
      const Color(0xFF7FDBFF),
      const Color(0xFF39CCCC),
      const Color(0xFF3D9970),
      const Color(0xFF2ECC40),
      const Color(0xFFFF851B),
      const Color(0xFFFF4136),
      const Color(0xFFB10DC9),
    ];
    
    for (int i = 0; i < 800; i++) {
      double cx = rand.nextDouble() * size.width;
      double cy = rand.nextDouble() * size.height;
      int rings = 3 + rand.nextInt(7);
      double maxRadius = 20 + rand.nextDouble() * 80;
      double ringSpacing = maxRadius / rings;
      
      Color baseColor = colors[rand.nextInt(colors.length)];
      
      for (int r = rings; r > 0; r--) {
        final paint = Paint()
          ..color = baseColor.withOpacity(0.3 + rand.nextDouble() * 0.5)
          ..style = (rand.nextBool() ? PaintingStyle.fill : PaintingStyle.stroke)
          ..strokeWidth = 1 + rand.nextDouble() * 5;
          
        canvas.drawCircle(Offset(cx, cy), r * ringSpacing, paint);
      }
    }
  }

  void _drawHashMarks(Canvas canvas, Size size, Random rand) {
    canvas.drawRect(
        Offset.zero & size,
        Paint()..color = const Color(0xFFF5F5DC));
        
    final colors = [
      const Color(0xFF8B4513),
      const Color(0xFFA0522D),
      const Color(0xFFD2691E),
      const Color(0xFFCD853F),
      const Color(0xFFF4A460),
    ];
    
    for (int i = 0; i < 3000; i++) {
      double cx = rand.nextDouble() * size.width;
      double cy = rand.nextDouble() * size.height;
      int lines = 3 + rand.nextInt(5);
      double length = 15 + rand.nextDouble() * 30;
      double spacing = 3 + rand.nextDouble() * 4;
      
      double angle = rand.nextDouble() * pi;
      
      final paint = Paint()
        ..color = colors[rand.nextInt(colors.length)].withOpacity(0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1 + rand.nextDouble() * 3
        ..strokeCap = StrokeCap.round;
        
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(angle);
      
      double startX = - (lines * spacing) / 2;
      for (int l = 0; l < lines; l++) {
        canvas.drawLine(Offset(startX + l * spacing, -length / 2), Offset(startX + l * spacing, length / 2), paint);
      }
      
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
