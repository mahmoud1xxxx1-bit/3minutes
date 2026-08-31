import 'dart:math';
import 'package:flutter/material.dart';

class PigeonPainterPack11 extends CustomPainter {
  final int seed;
  final int themeIndex;

  PigeonPainterPack11(this.seed, this.themeIndex);

  @override
  void paint(Canvas canvas, Size size) {
    final rand = Random(seed * 100 + themeIndex);
    switch (themeIndex) {
      case 0:
        _drawCoffeeBeans(canvas, size, rand);
        break;
      case 1:
        _drawKeys(canvas, size, rand);
        break;
      case 2:
        _drawCacti(canvas, size, rand);
        break;
      case 3:
        _drawLanterns(canvas, size, rand);
        break;
      case 4:
        _drawUmbrellas(canvas, size, rand);
        break;
      case 5:
        _drawSnowflakes(canvas, size, rand);
        break;
    }
  }

  void _drawCoffeeBeans(Canvas canvas, Size size, Random rand) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF3E2723),
    );

    final colors = [
      const Color(0xFF4E342E),
      const Color(0xFF5D4037),
      const Color(0xFF6D4C41),
      const Color(0xFF795548),
      const Color(0xFF8D6E63),
    ];

    for (int i = 0; i < 2000; i++) {
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      final w = rand.nextDouble() * 20 + 15;
      final h = rand.nextDouble() * 30 + 20;
      final angle = rand.nextDouble() * pi * 2;
      final color = colors[rand.nextInt(colors.length)];

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle);

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: w, height: h), paint);

      final linePaint = Paint()
        ..color = const Color(0xFF21130D)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      final path = Path();
      path.moveTo(0, -h / 2.5);
      path.quadraticBezierTo(-w / 3, 0, 0, h / 2.5);
      canvas.drawPath(path, linePaint);

      canvas.restore();
    }
  }

  void _drawKeys(Canvas canvas, Size size, Random rand) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF263238),
    );

    final colors = [
      const Color(0xFFFFD54F), // Gold
      const Color(0xFFE0E0E0), // Silver
      const Color(0xFFBCAAA4), // Bronze/Copper
      const Color(0xFF90A4AE), // Steel
    ];

    for (int i = 0; i < 1500; i++) {
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      final length = rand.nextDouble() * 40 + 30;
      final angle = rand.nextDouble() * pi * 2;
      final color = colors[rand.nextInt(colors.length)];

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle);

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      // Key head
      canvas.drawCircle(const Offset(-10, 0), 8, paint);
      
      final headHolePaint = Paint()
        ..color = const Color(0xFF263238)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(const Offset(-10, 0), 4, headHolePaint);

      // Key shaft
      canvas.drawRect(Rect.fromLTWH(-2, -2, length, 4), paint);

      // Key teeth
      int teethCount = rand.nextInt(3) + 1;
      for (int t = 0; t < teethCount; t++) {
        double tX = length - 5 - (t * 6);
        canvas.drawRect(Rect.fromLTWH(tX, 2, 4, 6 + rand.nextDouble() * 4), paint);
      }

      canvas.restore();
    }
  }

  void _drawCacti(Canvas canvas, Size size, Random rand) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFFFE082),
    );

    final colors = [
      const Color(0xFF388E3C),
      const Color(0xFF43A047),
      const Color(0xFF4CAF50),
      const Color(0xFF66BB6A),
      const Color(0xFF81C784),
    ];

    for (int i = 0; i < 2000; i++) {
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      final h = rand.nextDouble() * 50 + 30;
      final w = rand.nextDouble() * 15 + 10;
      final angle = rand.nextDouble() * pi * 2;
      final color = colors[rand.nextInt(colors.length)];

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle);

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      
      final rect = Rect.fromCenter(center: Offset.zero, width: w, height: h);
      final rrect = RRect.fromRectAndRadius(rect, Radius.circular(w / 2));
      canvas.drawRRect(rrect, paint);

      // Draw arms
      if (rand.nextBool()) {
        final path = Path();
        path.moveTo(w / 2, 0);
        path.quadraticBezierTo(w + 10, 0, w + 10, -h / 3);
        canvas.drawPath(
          path,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = w * 0.6
            ..strokeCap = StrokeCap.round,
        );
      }
      if (rand.nextBool()) {
        final path = Path();
        path.moveTo(-w / 2, 10);
        path.quadraticBezierTo(-w - 10, 10, -w - 10, -h / 4);
        canvas.drawPath(
          path,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = w * 0.6
            ..strokeCap = StrokeCap.round,
        );
      }

      // Needles
      final needlePaint = Paint()
        ..color = const Color(0xFF1B5E20)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      for (int n = 0; n < 10; n++) {
        final nY = -h / 2 + rand.nextDouble() * h;
        final nX = -w / 2 + rand.nextDouble() * w;
        canvas.drawLine(Offset(nX, nY), Offset(nX + (rand.nextDouble() * 6 - 3), nY + (rand.nextDouble() * 6 - 3)), needlePaint);
      }

      canvas.restore();
    }
  }

  void _drawLanterns(Canvas canvas, Size size, Random rand) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF1C1C1C),
    );

    final bodyColors = [
      const Color(0xFFD32F2F),
      const Color(0xFFC2185B),
      const Color(0xFFF57C00),
      const Color(0xFFE64A19),
    ];
    final glowColors = [
      const Color(0xFFFFD54F),
      const Color(0xFFFFCA28),
      const Color(0xFFFFB300),
      const Color(0xFFFFA000),
    ];

    for (int i = 0; i < 1800; i++) {
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      final w = rand.nextDouble() * 20 + 15;
      final h = rand.nextDouble() * 30 + 20;
      final angle = (rand.nextDouble() - 0.5) * 0.4;
      final bodyColor = bodyColors[rand.nextInt(bodyColors.length)];
      final glowColor = glowColors[rand.nextInt(glowColors.length)];

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle);

      // Line
      canvas.drawLine(
        Offset(0, -h * 2),
        Offset(0, -h / 2),
        Paint()..color = Colors.black87..strokeWidth = 1,
      );

      final paint = Paint()
        ..color = bodyColor
        ..style = PaintingStyle.fill;
      
      canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: w, height: h), paint);
      
      // Top/bottom caps
      final capPaint = Paint()..color = const Color(0xFFFFD700);
      canvas.drawRect(Rect.fromCenter(center: Offset(0, -h / 2), width: w * 0.6, height: 4), capPaint);
      canvas.drawRect(Rect.fromCenter(center: Offset(0, h / 2), width: w * 0.6, height: 4), capPaint);

      // Glow
      final glowPaint = Paint()
        ..color = glowColor.withValues(alpha: 0.8)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
      canvas.drawCircle(Offset.zero, w / 3, glowPaint);

      // Tassel
      canvas.drawLine(
        Offset(0, h / 2),
        Offset(0, h / 2 + 10),
        Paint()..color = const Color(0xFFFFD700)..strokeWidth = 1,
      );

      canvas.restore();
    }
  }

  void _drawUmbrellas(Canvas canvas, Size size, Random rand) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFE3F2FD),
    );

    final colors = [
      const Color(0xFFE53935),
      const Color(0xFF8E24AA),
      const Color(0xFF3949AB),
      const Color(0xFF039BE5),
      const Color(0xFF00ACC1),
      const Color(0xFF43A047),
      const Color(0xFFFFB300),
      const Color(0xFFF4511E),
    ];

    for (int i = 0; i < 2000; i++) {
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      final radius = rand.nextDouble() * 30 + 20;
      final angle = rand.nextDouble() * pi * 2;
      final color1 = colors[rand.nextInt(colors.length)];
      final color2 = colors[rand.nextInt(colors.length)];

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle);

      // Handle
      final handlePaint = Paint()
        ..color = const Color(0xFF5D4037)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;
      
      canvas.drawLine(Offset.zero, Offset(0, radius), handlePaint);
      
      final hookPath = Path();
      hookPath.moveTo(0, radius);
      hookPath.quadraticBezierTo(radius * 0.3, radius * 1.3, radius * 0.3, radius);
      canvas.drawPath(hookPath, handlePaint);

      // Canopy
      final path = Path();
      path.moveTo(-radius, 0);
      path.quadraticBezierTo(0, -radius, radius, 0);
      
      final points = 4;
      final width = (radius * 2) / points;
      for (int p = points - 1; p >= 0; p--) {
        double currentX = -radius + p * width;
        path.quadraticBezierTo(currentX + width / 2, -radius * 0.2, currentX, 0);
      }
      
      canvas.drawPath(path, Paint()..color = color1..style = PaintingStyle.fill);

      // Stripes
      final stripePath = Path();
      stripePath.moveTo(0, -radius / 2);
      stripePath.lineTo(-radius * 0.4, 0);
      stripePath.quadraticBezierTo(0, -radius * 0.1, radius * 0.4, 0);
      stripePath.close();
      canvas.drawPath(stripePath, Paint()..color = color2.withValues(alpha: 0.5)..style = PaintingStyle.fill);

      // Top point
      canvas.drawCircle(Offset(0, -radius / 2 - 2), 2, handlePaint..style = PaintingStyle.fill);

      canvas.restore();
    }
  }

  void _drawSnowflakes(Canvas canvas, Size size, Random rand) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF0D47A1), // Deep blue
    );

    final colors = [
      const Color(0xFFE3F2FD),
      const Color(0xFFBBDEFB),
      const Color(0xFF90CAF9),
      const Color(0xFF64B5F6),
      const Color(0xFFFFFFFF),
    ];

    for (int i = 0; i < 1500; i++) {
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      final r = rand.nextDouble() * 25 + 10;
      final angle = rand.nextDouble() * pi;
      final color = colors[rand.nextInt(colors.length)];

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle);

      final paint = Paint()
        ..color = color.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = rand.nextDouble() * 1.5 + 0.5
        ..strokeCap = StrokeCap.round;

      for (int arm = 0; arm < 6; arm++) {
        canvas.save();
        canvas.rotate(arm * pi / 3);
        
        // Main line
        canvas.drawLine(Offset.zero, Offset(0, -r), paint);
        
        // Branches
        int branches = rand.nextInt(3) + 1;
        for (int b = 1; b <= branches; b++) {
          double bY = -r * (b / (branches + 1));
          double bL = r * 0.3 * (1.0 - (b / (branches + 2)));
          
          canvas.drawLine(Offset(0, bY), Offset(bL, bY - bL), paint);
          canvas.drawLine(Offset(0, bY), Offset(-bL, bY - bL), paint);
        }

        canvas.restore();
      }

      // Center
      if (rand.nextBool()) {
        canvas.drawCircle(Offset.zero, r * 0.1, Paint()..color = color);
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
