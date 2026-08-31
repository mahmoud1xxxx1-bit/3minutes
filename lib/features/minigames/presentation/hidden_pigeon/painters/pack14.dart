import 'dart:math';
import 'package:flutter/material.dart';

class PigeonPainterPack14 extends CustomPainter {
  final int seed;
  final int themeIndex;

  PigeonPainterPack14(this.seed, this.themeIndex);

  @override
  void paint(Canvas canvas, Size size) {
    final rand = Random(seed * 100 + themeIndex);
    switch (themeIndex) {
      case 0:
        _drawCircuitNodes(canvas, size, rand);
        break;
      case 1:
        _drawTargetDartboards(canvas, size, rand);
        break;
      case 2:
        _drawCraters(canvas, size, rand);
        break;
      case 3:
        _drawTornadoes(canvas, size, rand);
        break;
      case 4:
        _drawSpringCoils(canvas, size, rand);
        break;
      case 5:
        _drawAbstractSparks(canvas, size, rand);
        break;
    }
  }

  void _drawCircuitNodes(Canvas canvas, Size size, Random rand) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF0D1B2A),
    );

    final colors = [
      const Color(0xFF1B263B),
      const Color(0xFF415A77),
      const Color(0xFF778DA9),
      const Color(0xFFE0E1DD),
      const Color(0xFFF9C80E),
    ];

    for (int i = 0; i < 2000; i++) {
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      final length = rand.nextDouble() * 50 + 10;
      final paint = Paint()
        ..color = colors[rand.nextInt(colors.length)].withValues(alpha: 0.6)
        ..strokeWidth = rand.nextDouble() * 3 + 1
        ..style = PaintingStyle.stroke;

      if (rand.nextBool()) {
        canvas.drawLine(Offset(x, y), Offset(x + length, y), paint);
        canvas.drawLine(
            Offset(x + length, y),
            Offset(
                x + length + (rand.nextBool() ? 20 : -20), y + (rand.nextBool() ? 20 : -20)),
            paint);
      } else {
        canvas.drawLine(Offset(x, y), Offset(x, y + length), paint);
        canvas.drawLine(
            Offset(x, y + length),
            Offset(
                x + (rand.nextBool() ? 20 : -20), y + length + (rand.nextBool() ? 20 : -20)),
            paint);
      }

      if (rand.nextDouble() > 0.7) {
        canvas.drawCircle(
            Offset(x, y),
            rand.nextDouble() * 6 + 2,
            Paint()
              ..color = colors[rand.nextInt(colors.length)]
              ..style = PaintingStyle.fill);
      }
    }
  }

  void _drawTargetDartboards(Canvas canvas, Size size, Random rand) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFFAF3DD),
    );

    final colors = [
      const Color(0xFFC8D5B9),
      const Color(0xFF8FC0A9),
      const Color(0xFF68B0AB),
      const Color(0xFF4A7C59),
      const Color(0xFFF25F5C),
    ];

    for (int i = 0; i < 1500; i++) {
      final cx = rand.nextDouble() * size.width;
      final cy = rand.nextDouble() * size.height;
      final radius = rand.nextDouble() * 60 + 20;

      final paintBase = Paint()
        ..color = colors[rand.nextInt(colors.length)].withValues(alpha: 0.5)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(cx, cy), radius, paintBase);

      int rings = rand.nextInt(5) + 3;
      for (int j = 1; j < rings; j++) {
        final ringRadius = radius - (radius / rings) * j;
        final paintRing = Paint()
          ..color = colors[rand.nextInt(colors.length)]
          ..style = PaintingStyle.stroke
          ..strokeWidth = rand.nextDouble() * 3 + 1;
        canvas.drawCircle(Offset(cx, cy), ringRadius, paintRing);
      }
      
      final paintCenter = Paint()
        ..color = const Color(0xFFF25F5C)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(cx, cy), radius / rings * 0.8, paintCenter);
    }
  }

  void _drawCraters(Canvas canvas, Size size, Random rand) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF2B2D42),
    );

    final colors = [
      const Color(0xFF8D99AE),
      const Color(0xFFEDF2F4),
      const Color(0xFFEF233C),
      const Color(0xFFD90429),
      const Color(0xFF5E6472),
    ];

    for (int i = 0; i < 2000; i++) {
      final cx = rand.nextDouble() * size.width;
      final cy = rand.nextDouble() * size.height;
      final rX = rand.nextDouble() * 50 + 10;
      final rY = rX * (rand.nextDouble() * 0.5 + 0.5);

      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(rand.nextDouble() * pi);

      final craterColor = colors[rand.nextInt(colors.length)];
      
      canvas.drawOval(
          Rect.fromCenter(center: Offset.zero, width: rX * 2, height: rY * 2),
          Paint()
            ..color = craterColor.withValues(alpha: 0.4)
            ..style = PaintingStyle.fill);

      canvas.drawOval(
          Rect.fromCenter(center: const Offset(3, 3), width: rX * 2, height: rY * 2),
          Paint()
            ..color = Colors.black.withValues(alpha: 0.3)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2);

      canvas.drawOval(
          Rect.fromCenter(center: Offset.zero, width: rX * 2, height: rY * 2),
          Paint()
            ..color = craterColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = rand.nextDouble() * 2 + 1);

      canvas.restore();
    }
  }

  void _drawTornadoes(Canvas canvas, Size size, Random rand) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF22223B),
    );

    final colors = [
      const Color(0xFF4A4E69),
      const Color(0xFF9A8C98),
      const Color(0xFFC9ADA7),
      const Color(0xFFF2E9E4),
      const Color(0xFF1B263B),
    ];

    for (int i = 0; i < 2500; i++) {
      final cx = rand.nextDouble() * size.width;
      final cy = rand.nextDouble() * size.height;
      final height = rand.nextDouble() * 80 + 20;

      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(rand.nextDouble() * pi * 2);

      final paint = Paint()
        ..color = colors[rand.nextInt(colors.length)].withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = rand.nextDouble() * 2 + 0.5;

      final path = Path();
      double currentY = -height / 2;
      double radius = rand.nextDouble() * 20 + 10;

      path.moveTo(rand.nextDouble() * radius * 2 - radius, currentY);

      for (int j = 0; j < 10; j++) {
        currentY += height / 10;
        radius *= 0.8;
        path.quadraticBezierTo(
            (rand.nextBool() ? 1 : -1) * radius * 3, currentY - height / 20,
            rand.nextDouble() * radius * 2 - radius, currentY);
      }

      canvas.drawPath(path, paint);
      canvas.restore();
    }
  }

  void _drawSpringCoils(Canvas canvas, Size size, Random rand) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFF4F1DE),
    );

    final colors = [
      const Color(0xFFE07A5F),
      const Color(0xFF3D405B),
      const Color(0xFF81B29A),
      const Color(0xFFF2CC8F),
      const Color(0xFFC44536),
    ];

    for (int i = 0; i < 2000; i++) {
      final startX = rand.nextDouble() * size.width;
      final startY = rand.nextDouble() * size.height;
      final length = rand.nextDouble() * 100 + 40;
      final coilRadius = rand.nextDouble() * 15 + 5;
      final coils = rand.nextInt(8) + 4;

      canvas.save();
      canvas.translate(startX, startY);
      canvas.rotate(rand.nextDouble() * pi * 2);

      final paint = Paint()
        ..color = colors[rand.nextInt(colors.length)].withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = rand.nextDouble() * 2 + 1;

      final path = Path();
      path.moveTo(0, 0);

      for (int j = 1; j <= coils; j++) {
        final cx = (length / coils) * j;
        path.cubicTo(
            cx - (length / coils) * 0.5, -coilRadius * 2,
            cx - (length / coils) * 0.5, coilRadius * 2,
            cx, 0);
      }

      canvas.drawPath(path, paint);
      canvas.restore();
    }
  }

  void _drawAbstractSparks(Canvas canvas, Size size, Random rand) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF14213D),
    );

    final colors = [
      const Color(0xFFFCA311),
      const Color(0xFFE5E5E5),
      const Color(0xFFFFFFFF),
      const Color(0xFF000000),
      const Color(0xFFFFD166),
    ];

    for (int i = 0; i < 3000; i++) {
      final cx = rand.nextDouble() * size.width;
      final cy = rand.nextDouble() * size.height;
      final rays = rand.nextInt(6) + 3;
      final radius = rand.nextDouble() * 30 + 5;

      final paint = Paint()
        ..color = colors[rand.nextInt(colors.length)].withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = rand.nextDouble() * 2 + 0.5
        ..strokeCap = StrokeCap.round;

      for (int j = 0; j < rays; j++) {
        final angle = (pi * 2 / rays) * j + rand.nextDouble() * 0.5;
        final r = radius * (rand.nextDouble() * 0.5 + 0.5);
        canvas.drawLine(
            Offset(cx, cy),
            Offset(cx + cos(angle) * r, cy + sin(angle) * r),
            paint);
      }
      
      if (rand.nextDouble() > 0.8) {
        canvas.drawCircle(
            Offset(cx, cy),
            rand.nextDouble() * 3 + 1,
            Paint()
              ..color = colors[rand.nextInt(colors.length)]
              ..style = PaintingStyle.fill);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
