import 'dart:math';
import 'package:flutter/material.dart';

class PigeonPainterPack9 extends CustomPainter {
  final int seed;
  final int themeIndex;
  
  PigeonPainterPack9(this.seed, this.themeIndex);

  @override
  void paint(Canvas canvas, Size size) {
    final rand = Random(seed * 100 + themeIndex);
    switch (themeIndex) {
      case 0: _drawAbstractWaves(canvas, size, rand); break;
      case 1: _drawChains(canvas, size, rand); break;
      case 2: _drawButtons(canvas, size, rand); break;
      case 3: _drawBalloons(canvas, size, rand); break;
      case 4: _drawFireworks(canvas, size, rand); break;
      case 5: _drawLabyrinth(canvas, size, rand); break;
    }
  }

  void _drawAbstractWaves(Canvas canvas, Size size, Random rand) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF0D1B2A));
    final colors = [0xFF415A77, 0xFF778DA9, 0xFFE0E1DD, 0xFF1B263B];
    for (int i = 0; i < 2000; i++) {
      final path = Path();
      double startY = rand.nextDouble() * size.height;
      double startX = rand.nextDouble() * size.width - 200;
      path.moveTo(startX, startY);
      path.quadraticBezierTo(
        startX + rand.nextDouble() * 200 + 50, startY + (rand.nextDouble() - 0.5) * 300,
        startX + rand.nextDouble() * 400 + 150, startY + (rand.nextDouble() - 0.5) * 300,
      );
      path.quadraticBezierTo(
        startX + rand.nextDouble() * 600 + 300, startY + (rand.nextDouble() - 0.5) * 300,
        startX + rand.nextDouble() * 800 + 400, startY + (rand.nextDouble() - 0.5) * 300,
      );
      
      final paint = Paint()
        ..color = Color(colors[rand.nextInt(colors.length)]).withValues(alpha: rand.nextDouble() * 0.4 + 0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = rand.nextDouble() * 8 + 1;
      canvas.drawPath(path, paint);
    }
  }

  void _drawChains(Canvas canvas, Size size, Random rand) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF2B2D42));
    final colors = [0xFF8D99AE, 0xFFEDF2F4, 0xFFEF233C, 0xFFD90429];
    for (int i = 0; i < 2500; i++) {
      double cx = rand.nextDouble() * size.width;
      double cy = rand.nextDouble() * size.height;
      double angle = rand.nextDouble() * pi;
      double rx = rand.nextDouble() * 20 + 10;
      double ry = rx * 0.4;
      
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(angle);
      
      final paint = Paint()
        ..color = Color(colors[rand.nextInt(colors.length)]).withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = rand.nextDouble() * 4 + 2;
        
      canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: rx * 2, height: ry * 2), paint);
      canvas.restore();
    }
  }

  void _drawButtons(Canvas canvas, Size size, Random rand) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFF4F1DE));
    final colors = [0xFFE07A5F, 0xFF3D405B, 0xFF81B29A, 0xFFF2CC8F];
    for (int i = 0; i < 2000; i++) {
      double cx = rand.nextDouble() * size.width;
      double cy = rand.nextDouble() * size.height;
      double radius = rand.nextDouble() * 15 + 10;
      
      final baseColor = Color(colors[rand.nextInt(colors.length)]);
      final paint = Paint()..color = baseColor..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(cx, cy), radius, paint);
      
      final edgePaint = Paint()
        ..color = Colors.black26
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(Offset(cx, cy), radius, edgePaint);
      
      final innerPaint = Paint()
        ..color = Colors.black12
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(cx, cy), radius * 0.6, innerPaint);
      
      final holePaint = Paint()..color = const Color(0xFFF4F1DE)..style = PaintingStyle.fill;
      double hr = radius * 0.15;
      double offset = radius * 0.25;
      canvas.drawCircle(Offset(cx - offset, cy - offset), hr, holePaint);
      canvas.drawCircle(Offset(cx + offset, cy - offset), hr, holePaint);
      canvas.drawCircle(Offset(cx - offset, cy + offset), hr, holePaint);
      canvas.drawCircle(Offset(cx + offset, cy + offset), hr, holePaint);
    }
  }

  void _drawBalloons(Canvas canvas, Size size, Random rand) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFA8DADC));
    final colors = [0xFFE63946, 0xFFF1FAEE, 0xFF457B9D, 0xFF1D3557];
    for (int i = 0; i < 2000; i++) {
      double cx = rand.nextDouble() * size.width;
      double cy = rand.nextDouble() * size.height;
      double radius = rand.nextDouble() * 20 + 10;
      
      final stringPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
        
      final path = Path();
      path.moveTo(cx, cy + radius);
      path.quadraticBezierTo(cx - 10, cy + radius + 20, cx, cy + radius + 40);
      path.quadraticBezierTo(cx + 10, cy + radius + 60, cx, cy + radius + 80);
      canvas.drawPath(path, stringPaint);
      
      final baseColor = Color(colors[rand.nextInt(colors.length)]);
      final paint = Paint()
        ..color = baseColor.withValues(alpha: 0.85)
        ..style = PaintingStyle.fill;
        
      canvas.save();
      canvas.translate(cx, cy);
      canvas.scale(1, 1.2);
      canvas.drawCircle(Offset.zero, radius, paint);
      canvas.restore();
      
      final highlightPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.4)
        ..style = PaintingStyle.fill;
      canvas.drawOval(Rect.fromCenter(center: Offset(cx - radius*0.3, cy - radius*0.4), width: radius*0.3, height: radius*0.6), highlightPaint);
    }
  }

  void _drawFireworks(Canvas canvas, Size size, Random rand) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF0B090A));
    final colors = [0xFFE5383B, 0xFFF5CB5C, 0xFF8338EC, 0xFF3A86FF, 0xFFFF006E];
    for (int i = 0; i < 2500; i++) {
      double cx = rand.nextDouble() * size.width;
      double cy = rand.nextDouble() * size.height;
      
      int burstCount = rand.nextInt(5) + 5;
      final color = Color(colors[rand.nextInt(colors.length)]).withValues(alpha: rand.nextDouble() * 0.5 + 0.3);
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = rand.nextDouble() * 2 + 0.5;
        
      for(int j = 0; j < burstCount; j++) {
        double angle = rand.nextDouble() * 2 * pi;
        double length = rand.nextDouble() * 30 + 10;
        double x1 = cx + cos(angle) * (rand.nextDouble() * 10);
        double y1 = cy + sin(angle) * (rand.nextDouble() * 10);
        double x2 = cx + cos(angle) * length;
        double y2 = cy + sin(angle) * length;
        
        canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
      }
      
      if (rand.nextDouble() < 0.2) {
        canvas.drawCircle(Offset(cx, cy), rand.nextDouble() * 2 + 1, Paint()..color = Colors.white..style = PaintingStyle.fill);
      }
    }
  }

  void _drawLabyrinth(Canvas canvas, Size size, Random rand) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFD4A373));
    final colors = [0xFFFAEDCD, 0xFFFEFAE0, 0xFFE9EDC9, 0xFFCCD5AE];
    
    for (int i = 0; i < 3000; i++) {
      bool isVertical = rand.nextBool();
      double x = rand.nextDouble() * size.width;
      double y = rand.nextDouble() * size.height;
      double length = rand.nextDouble() * 80 + 20;
      double width = rand.nextDouble() * 8 + 2;
      
      final paint = Paint()
        ..color = Color(colors[rand.nextInt(colors.length)]).withValues(alpha: 0.9)
        ..style = PaintingStyle.fill;
        
      if (isVertical) {
        canvas.drawRect(Rect.fromLTWH(x, y, width, length), paint);
        canvas.drawRect(Rect.fromLTWH(x, y, width, length), Paint()..color = Colors.black26..style = PaintingStyle.stroke..strokeWidth = 1);
      } else {
        canvas.drawRect(Rect.fromLTWH(x, y, length, width), paint);
        canvas.drawRect(Rect.fromLTWH(x, y, length, width), Paint()..color = Colors.black26..style = PaintingStyle.stroke..strokeWidth = 1);
      }
    }
  }

  @override
  bool shouldRepaint(covariant PigeonPainterPack9 oldDelegate) {
    return oldDelegate.seed != seed || oldDelegate.themeIndex != themeIndex;
  }
}
