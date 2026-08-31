import 'dart:math';
import 'package:flutter/material.dart';

class PigeonPainterPack2 extends CustomPainter {
  final int seed;
  final int themeIndex;
  
  PigeonPainterPack2(this.seed, this.themeIndex);

  @override
  void paint(Canvas canvas, Size size) {
    final rand = Random(seed * 100 + themeIndex);
    canvas.clipRect(Offset.zero & size);
    
    switch (themeIndex) {
      case 0: _drawJungle(canvas, size, rand); break;
      case 1: _drawDesert(canvas, size, rand); break;
      case 2: _drawSnowStorm(canvas, size, rand); break;
      case 3: _drawCloudCity(canvas, size, rand); break;
      case 4: _drawCastleRuins(canvas, size, rand); break;
      case 5: _drawBeeHive(canvas, size, rand); break;
    }
  }

  void _drawJungle(Canvas canvas, Size size, Random rand) {
    canvas.drawPaint(Paint()..color = const Color(0xFF1B3B22));
    final colors = [
      const Color(0xFF2E7D32),
      const Color(0xFF1B5E20),
      const Color(0xFF4CAF50),
      const Color(0xFF81C784),
      const Color(0xFF004D40),
      const Color(0xFF33691E),
    ];
    
    for (int i = 0; i < 2500; i++) {
      final paint = Paint()
        ..color = colors[rand.nextInt(colors.length)].withValues(alpha: 0.6 + rand.nextDouble() * 0.4)
        ..style = rand.nextBool() ? PaintingStyle.fill : PaintingStyle.stroke
        ..strokeWidth = 1.0 + rand.nextDouble() * 3.0;

      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      final w = 10.0 + rand.nextDouble() * 80.0;
      final h = 20.0 + rand.nextDouble() * 120.0;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rand.nextDouble() * pi * 2);

      final choice = rand.nextInt(3);
      if (choice == 0) {
        canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: w, height: h), paint);
      } else if (choice == 1) {
        final path = Path();
        path.moveTo(0, -h/2);
        path.quadraticBezierTo(w/2, 0, 0, h/2);
        path.quadraticBezierTo(-w/2, 0, 0, -h/2);
        canvas.drawPath(path, paint);
      } else {
        canvas.drawLine(Offset(0, -h/2), Offset(0, h/2), paint..strokeWidth = w / 5);
      }
      canvas.restore();
    }
  }

  void _drawDesert(Canvas canvas, Size size, Random rand) {
    canvas.drawPaint(Paint()..color = const Color(0xFFFFD54F));
    final colors = [
      const Color(0xFFFFC107),
      const Color(0xFFFFB300),
      const Color(0xFFFFA000),
      const Color(0xFFFF8F00),
      const Color(0xFFFFE082),
      const Color(0xFFD7CCC8),
      const Color(0xFF8D6E63),
    ];

    for (int i = 0; i < 2000; i++) {
      final paint = Paint()
        ..color = colors[rand.nextInt(colors.length)].withValues(alpha: 0.7 + rand.nextDouble() * 0.3)
        ..style = PaintingStyle.fill;
        
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      
      canvas.save();
      canvas.translate(x, y);
      
      final type = rand.nextInt(3);
      if (type == 0) {
        canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 100 + rand.nextDouble()*200, height: 20 + rand.nextDouble()*50), paint);
      } else if (type == 1) {
        final path = Path();
        final points = 5 + rand.nextInt(4);
        final rad = 10.0 + rand.nextDouble() * 30.0;
        for (int j = 0; j < points; j++) {
          final angle = (j / points) * pi * 2;
          final r = rad * (0.8 + rand.nextDouble() * 0.4);
          final px = cos(angle) * r;
          final py = sin(angle) * r;
          if (j == 0) {
            path.moveTo(px, py);
          } else {
            path.lineTo(px, py);
          }
        }
        path.close();
        canvas.drawPath(path, paint);
      } else {
        final cw = 5.0 + rand.nextDouble() * 15.0;
        final ch = 20.0 + rand.nextDouble() * 60.0;
        paint.color = const Color(0xFF4CAF50).withValues(alpha: 0.5);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: cw, height: ch), Radius.circular(cw/2)), paint);
      }
      canvas.restore();
    }
  }

  void _drawSnowStorm(Canvas canvas, Size size, Random rand) {
    canvas.drawPaint(Paint()..color = const Color(0xFFB0BEC5));
    final colors = [
      const Color(0xFFFFFFFF),
      const Color(0xFFE0E0E0),
      const Color(0xFFCFD8DC),
      const Color(0xFF90A4AE),
      const Color(0xFF81D4FA),
      const Color(0xFFB3E5FC),
    ];

    for (int i = 0; i < 3000; i++) {
      final paint = Paint()
        ..color = colors[rand.nextInt(colors.length)].withValues(alpha: 0.3 + rand.nextDouble() * 0.7)
        ..style = PaintingStyle.fill;
        
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      final radius = 1.0 + rand.nextDouble() * 8.0;

      canvas.save();
      canvas.translate(x, y);
      
      if (rand.nextBool()) {
        canvas.drawCircle(Offset.zero, radius, paint);
      } else {
        canvas.rotate(rand.nextDouble() * pi);
        canvas.drawLine(Offset(-radius, 0), Offset(radius, 0), paint..strokeWidth = 1.0 + rand.nextDouble()*3.0);
        canvas.drawLine(Offset(0, -radius), Offset(0, radius), paint);
        canvas.drawLine(Offset(-radius*.7, -radius*.7), Offset(radius*.7, radius*.7), paint);
        canvas.drawLine(Offset(-radius*.7, radius*.7), Offset(radius*.7, -radius*.7), paint);
      }
      canvas.restore();
    }
    
    for (int i = 0; i < 500; i++) {
      final paint = Paint()
        ..color = Colors.white.withValues(alpha: 0.4)
        ..style = PaintingStyle.fill;
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      final w = 5.0 + rand.nextDouble() * 20.0;
      final h = 30.0 + rand.nextDouble() * 100.0;
      
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rand.nextDouble() * pi * 2);
      final path = Path();
      path.moveTo(0, -h/2);
      path.lineTo(w/2, 0);
      path.lineTo(0, h/2);
      path.lineTo(-w/2, 0);
      path.close();
      canvas.drawPath(path, paint);
      canvas.restore();
    }
  }

  void _drawCloudCity(Canvas canvas, Size size, Random rand) {
    canvas.drawPaint(Paint()..color = const Color(0xFF4FC3F7));
    final colors = [
      const Color(0xFFE1F5FE),
      const Color(0xFFB3E5FC),
      const Color(0xFF81D4FA),
      const Color(0xFFFFFFFF),
      const Color(0xFFF5F5F5),
      const Color(0xFFFFF9C4),
    ];

    for (int i = 0; i < 1500; i++) {
      final paint = Paint()
        ..color = colors[rand.nextInt(4)].withValues(alpha: 0.5 + rand.nextDouble() * 0.5)
        ..style = PaintingStyle.fill;
        
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      final w = 40.0 + rand.nextDouble() * 120.0;
      final h = 20.0 + rand.nextDouble() * 60.0;

      canvas.drawOval(Rect.fromCenter(center: Offset(x, y), width: w, height: h), paint);
      canvas.drawCircle(Offset(x - w/4, y - h/3), h*0.6, paint);
      canvas.drawCircle(Offset(x + w/4, y - h/4), h*0.5, paint);
    }
    
    for (int i = 0; i < 800; i++) {
      final paint = Paint()
        ..color = (rand.nextBool() ? const Color(0xFFECEFF1) : const Color(0xFFCFD8DC)).withValues(alpha: 0.8)
        ..style = PaintingStyle.fill;
        
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      final w = 10.0 + rand.nextDouble() * 30.0;
      final h = 50.0 + rand.nextDouble() * 200.0;
      
      canvas.drawRect(Rect.fromCenter(center: Offset(x, y), width: w, height: h), paint);
      
      final accent = Paint()..color = colors[5].withValues(alpha: 0.6)..style = PaintingStyle.fill;
      final ww = w * 0.6;
      final wh = 4.0;
      for (double j = y - h/2 + 10; j < y + h/2 - 10; j += 15) {
        if (rand.nextBool()) {
          canvas.drawRect(Rect.fromCenter(center: Offset(x, j), width: ww, height: wh), accent);
        }
      }
      
      if (rand.nextDouble() > 0.5) {
        canvas.drawArc(
          Rect.fromCenter(center: Offset(x, y - h/2), width: w * 1.5, height: w * 1.5),
          pi, pi, true, paint..color = const Color(0xFFFFD54F)
        );
      }
    }
  }

  void _drawCastleRuins(Canvas canvas, Size size, Random rand) {
    canvas.drawPaint(Paint()..color = const Color(0xFF37474F));
    final colors = [
      const Color(0xFF455A64),
      const Color(0xFF546E7A),
      const Color(0xFF607D8B),
      const Color(0xFF78909C),
      const Color(0xFF2E3131),
      const Color(0xFF424242),
      const Color(0xFF616161),
      const Color(0xFF33691E),
    ];

    for (int i = 0; i < 2500; i++) {
      final paint = Paint()
        ..color = colors[rand.nextInt(colors.length)].withValues(alpha: 0.7 + rand.nextDouble() * 0.3)
        ..style = PaintingStyle.fill;
        
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate((rand.nextDouble() - 0.5) * pi * 0.4);
      
      final type = rand.nextInt(10);
      if (type < 6) {
        final w = 15.0 + rand.nextDouble() * 40.0;
        final h = 10.0 + rand.nextDouble() * 20.0;
        final rRect = RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: w, height: h), const Radius.circular(2));
        canvas.drawRRect(rRect, paint);
      } else if (type < 8) {
        final w = 20.0 + rand.nextDouble() * 30.0;
        final h = 60.0 + rand.nextDouble() * 150.0;
        canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: w, height: h), paint);
        canvas.drawLine(Offset(-w/3, -h/2), Offset(-w/3, h/2), Paint()..color=Colors.black26..strokeWidth=2);
        canvas.drawLine(Offset(w/3, -h/2), Offset(w/3, h/2), Paint()..color=Colors.black26..strokeWidth=2);
      } else {
        final paintMoss = Paint()
          ..color = const Color(0xFF2E7D32).withValues(alpha: 0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0 + rand.nextDouble() * 4.0;
        final path = Path();
        path.moveTo(0, 0);
        for(int j=0; j<5; j++) {
          path.quadraticBezierTo(
            (rand.nextDouble()-0.5)*30, (rand.nextDouble()-0.5)*30,
            (rand.nextDouble()-0.5)*50, (rand.nextDouble()-0.5)*50
          );
        }
        canvas.drawPath(path, paintMoss);
      }
      canvas.restore();
    }
  }

  void _drawBeeHive(Canvas canvas, Size size, Random rand) {
    canvas.drawPaint(Paint()..color = const Color(0xFFF9A825));
    final colors = [
      const Color(0xFFFBC02D),
      const Color(0xFFFFB300),
      const Color(0xFFFFA000),
      const Color(0xFFFF8F00),
      const Color(0xFFFFCA28),
      const Color(0xFFFFD54F),
      const Color(0xFFF57F17),
      const Color(0xFFE65100),
    ];

    for (int i = 0; i < 2200; i++) {
      final paint = Paint()
        ..color = colors[rand.nextInt(colors.length)].withValues(alpha: 0.6 + rand.nextDouble() * 0.4)
        ..style = rand.nextBool() ? PaintingStyle.fill : PaintingStyle.stroke
        ..strokeWidth = 2.0 + rand.nextDouble() * 4.0;
        
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      
      canvas.save();
      canvas.translate(x, y);
      
      final type = rand.nextInt(4);
      if (type < 3) {
        final radius = 10.0 + rand.nextDouble() * 40.0;
        final path = Path();
        for (int j = 0; j < 6; j++) {
          final angle = (j * pi / 3) + (pi / 6);
          final px = cos(angle) * radius;
          final py = sin(angle) * radius;
          if (j == 0) {
            path.moveTo(px, py);
          } else {
            path.lineTo(px, py);
          }
        }
        path.close();
        canvas.drawPath(path, paint);
        
        if (rand.nextDouble() > 0.7 && paint.style == PaintingStyle.fill) {
          final drip = Paint()..color = const Color(0xFFE65100).withValues(alpha: 0.8)..style = PaintingStyle.fill;
          canvas.drawCircle(Offset(0, radius*0.3), radius*0.3, drip);
        }
      } else {
        final w = 8.0 + rand.nextDouble() * 15.0;
        final h = 15.0 + rand.nextDouble() * 25.0;
        canvas.rotate(rand.nextDouble() * pi * 2);
        
        canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: w, height: h), Paint()..color=Colors.black87);
        final stripe = Paint()..color = Colors.yellow..strokeWidth=3;
        canvas.drawLine(Offset(-w/2, -h/4), Offset(w/2, -h/4), stripe);
        canvas.drawLine(Offset(-w/2, h/4), Offset(w/2, h/4), stripe);
        
        final wing = Paint()..color = Colors.white.withValues(alpha: 0.5)..style=PaintingStyle.fill;
        canvas.drawOval(Rect.fromCenter(center: Offset(-w, 0), width: w*1.5, height: h*0.8), wing);
        canvas.drawOval(Rect.fromCenter(center: Offset(w, 0), width: w*1.5, height: h*0.8), wing);
      }
      
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
