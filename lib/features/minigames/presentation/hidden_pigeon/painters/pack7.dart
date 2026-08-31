import 'dart:math';
import 'package:flutter/material.dart';

class PigeonPainterPack7 extends CustomPainter {
  final int seed;
  final int themeIndex;

  PigeonPainterPack7(this.seed, this.themeIndex);

  @override
  void paint(Canvas canvas, Size size) {
    final rand = Random(seed * 100 + themeIndex);
    switch (themeIndex) {
      case 0:
        _drawClockFaces(canvas, size, rand);
        break;
      case 1:
        _drawBambooForest(canvas, size, rand);
        break;
      case 2:
        _drawFireFlames(canvas, size, rand);
        break;
      case 3:
        _drawIceShards(canvas, size, rand);
        break;
      case 4:
        _drawHoneycombHexagons(canvas, size, rand);
        break;
      case 5:
        _drawSpikyThorns(canvas, size, rand);
        break;
    }
  }

  void _drawClockFaces(Canvas canvas, Size size, Random rand) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF1A1A1D),
    );

    final colors = [
      const Color(0xFFC4A484),
      const Color(0xFFD2B48C),
      const Color(0xFFF5DEB3),
      const Color(0xFF8B4513),
      const Color(0xFFA0522D),
      const Color(0xFFCD853F),
      const Color(0xFFE8E8E8),
    ];

    for (int i = 0; i < 2000; i++) {
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      final radius = rand.nextDouble() * 60 + 10;
      final color = colors[rand.nextInt(colors.length)];

      final paint = Paint()
        ..color = color.withOpacity(rand.nextDouble() * 0.4 + 0.1)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), radius, paint);

      final borderPaint = Paint()
        ..color = color.withOpacity(rand.nextDouble() * 0.6 + 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = rand.nextDouble() * 3 + 1;
      canvas.drawCircle(Offset(x, y), radius, borderPaint);

      // Draw hands
      final center = Offset(x, y);
      for (int j = 0; j < 3; j++) {
        final angle = rand.nextDouble() * 2 * pi;
        final length = radius * (rand.nextDouble() * 0.6 + 0.3);
        final handPaint = Paint()
          ..color = colors[rand.nextInt(colors.length)]
          ..strokeWidth = rand.nextDouble() * 3 + 1
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(
          center,
          center + Offset(cos(angle) * length, sin(angle) * length),
          handPaint,
        );
      }
      
      // Draw some tick marks
      if (rand.nextBool()) {
        for(int k=0; k<12; k++) {
          final angle = k * (2 * pi / 12);
          final innerR = radius * 0.8;
          final outerR = radius * 0.95;
          final tickPaint = Paint()..color = color.withOpacity(0.5)..strokeWidth = 1.5;
          canvas.drawLine(
            center + Offset(cos(angle) * innerR, sin(angle) * innerR),
            center + Offset(cos(angle) * outerR, sin(angle) * outerR),
            tickPaint,
          );
        }
      }
    }
  }

  void _drawBambooForest(Canvas canvas, Size size, Random rand) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF0A2E0F),
    );

    final colors = [
      const Color(0xFF2E8B57),
      const Color(0xFF3CB371),
      const Color(0xFF8FBC8F),
      const Color(0xFF556B2F),
      const Color(0xFF6B8E23),
      const Color(0xFF9ACD32),
    ];

    for (int i = 0; i < 2500; i++) {
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      final length = rand.nextDouble() * 300 + 100;
      final angle = (rand.nextDouble() - 0.5) * 0.5 - pi / 2; // mostly vertical
      final thickness = rand.nextDouble() * 12 + 2;
      final color = colors[rand.nextInt(colors.length)];

      final endX = x + cos(angle) * length;
      final endY = y + sin(angle) * length;

      final paint = Paint()
        ..color = color.withOpacity(rand.nextDouble() * 0.6 + 0.4)
        ..strokeWidth = thickness
        ..strokeCap = StrokeCap.square;

      canvas.drawLine(Offset(x, y), Offset(endX, endY), paint);

      // Draw nodes (horizontal lines across bamboo)
      final numNodes = rand.nextInt(5) + 2;
      final nodePaint = Paint()
        ..color = const Color(0xFF1B4D2E).withOpacity(0.8)
        ..strokeWidth = thickness * 0.3;
      for (int j = 1; j < numNodes; j++) {
        final f = j / numNodes;
        final nodeX = x + (endX - x) * f;
        final nodeY = y + (endY - y) * f;
        canvas.drawLine(
          Offset(nodeX - thickness * 0.6, nodeY - thickness * 0.2),
          Offset(nodeX + thickness * 0.6, nodeY + thickness * 0.2),
          nodePaint,
        );
      }

      // Draw random leaves
      if (rand.nextBool()) {
        final leafX = x + (endX - x) * 0.5;
        final leafY = y + (endY - y) * 0.5;
        final leafPaint = Paint()..color = colors[rand.nextInt(colors.length)].withOpacity(0.8);
        final path = Path();
        path.moveTo(leafX, leafY);
        path.quadraticBezierTo(leafX + 20, leafY - 10, leafX + 30, leafY);
        path.quadraticBezierTo(leafX + 20, leafY + 10, leafX, leafY);
        canvas.drawPath(path, leafPaint);
      }
    }
  }

  void _drawFireFlames(Canvas canvas, Size size, Random rand) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF1A0000),
    );

    final colors = [
      const Color(0xFFFF4500),
      const Color(0xFFFF0000),
      const Color(0xFFFF8C00),
      const Color(0xFFFFA500),
      const Color(0xFFFFD700),
      const Color(0xFF8B0000),
      const Color(0xFFFFFFFF), // hot core
    ];

    for (int i = 0; i < 3000; i++) {
      final startX = rand.nextDouble() * size.width;
      final startY = rand.nextDouble() * size.height + 50; // shift down to let flames rise
      final height = rand.nextDouble() * 200 + 50;
      final width = rand.nextDouble() * 60 + 10;
      final color = colors[rand.nextInt(colors.length)];

      final path = Path();
      path.moveTo(startX, startY);
      
      // Flame curve
      path.quadraticBezierTo(
        startX - width, startY - height / 2,
        startX, startY - height
      );
      path.quadraticBezierTo(
        startX + width / 2, startY - height * 0.3,
        startX, startY
      );

      final paint = Paint()
        ..color = color.withOpacity(rand.nextDouble() * 0.3 + 0.1)
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, paint);

      if (rand.nextDouble() < 0.2) {
        final strokePaint = Paint()
          ..color = color.withOpacity(0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = rand.nextDouble() * 2 + 0.5;
        canvas.drawPath(path, strokePaint);
      }
    }
  }

  void _drawIceShards(Canvas canvas, Size size, Random rand) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF0B1D2E),
    );

    final colors = [
      const Color(0xFFE0FFFF),
      const Color(0xFFAFEEEE),
      const Color(0xFF40E0D0),
      const Color(0xFF48D1CC),
      const Color(0xFF00CED1),
      const Color(0xFF5F9EA0),
      const Color(0xFF4682B4),
      const Color(0xFFFFFFFF),
    ];

    for (int i = 0; i < 2800; i++) {
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      final scale = rand.nextDouble() * 80 + 20;
      final angle = rand.nextDouble() * 2 * pi;
      final color = colors[rand.nextInt(colors.length)];

      final path = Path();
      path.moveTo(x, y);
      path.lineTo(x + cos(angle - 0.2) * scale, y + sin(angle - 0.2) * scale);
      path.lineTo(x + cos(angle) * scale * 1.5, y + sin(angle) * scale * 1.5);
      path.lineTo(x + cos(angle + 0.2) * scale, y + sin(angle + 0.2) * scale);
      path.close();

      final paint = Paint()
        ..color = color.withOpacity(rand.nextDouble() * 0.4 + 0.2)
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, paint);

      final strokePaint = Paint()
        ..color = const Color(0xFFFFFFFF).withOpacity(rand.nextDouble() * 0.5 + 0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawPath(path, strokePaint);
    }
  }

  void _drawHoneycombHexagons(Canvas canvas, Size size, Random rand) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF2E1B0A),
    );

    final colors = [
      const Color(0xFFFFD700),
      const Color(0xFFDAA520),
      const Color(0xFFB8860B),
      const Color(0xFFCD853F),
      const Color(0xFFD2691E),
      const Color(0xFF8B4513),
      const Color(0xFFF5DEB3),
    ];

    for (int i = 0; i < 2200; i++) {
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      final r = rand.nextDouble() * 30 + 10;
      final color = colors[rand.nextInt(colors.length)];

      final path = Path();
      for (int j = 0; j < 6; j++) {
        final angle = j * pi / 3;
        final px = x + cos(angle) * r;
        final py = y + sin(angle) * r;
        if (j == 0) {
          path.moveTo(px, py);
        } else {
          path.lineTo(px, py);
        }
      }
      path.close();

      final paint = Paint()
        ..color = color.withOpacity(rand.nextDouble() * 0.5 + 0.3)
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, paint);

      final strokePaint = Paint()
        ..color = colors[rand.nextInt(colors.length)].withOpacity(0.8)
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = rand.nextDouble() * 3 + 1;
      canvas.drawPath(path, strokePaint);
      
      // Draw inner highlight
      if (rand.nextBool()) {
        final innerPath = Path();
        final innerR = r * 0.6;
        for (int j = 0; j < 6; j++) {
          final angle = j * pi / 3;
          final px = x + cos(angle) * innerR;
          final py = y + sin(angle) * innerR;
          if (j == 0) {
            innerPath.moveTo(px, py);
          } else {
            innerPath.lineTo(px, py);
          }
        }
        innerPath.close();
        final innerPaint = Paint()
          ..color = const Color(0xFFFFFFFF).withOpacity(0.2)
          ..style = PaintingStyle.fill;
        canvas.drawPath(innerPath, innerPaint);
      }
    }
  }

  void _drawSpikyThorns(Canvas canvas, Size size, Random rand) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF1C201A),
    );

    final colors = [
      const Color(0xFF2F4F4F),
      const Color(0xFF556B2F),
      const Color(0xFF6B8E23),
      const Color(0xFF8B4513),
      const Color(0xFFA0522D),
      const Color(0xFF000000),
      const Color(0xFF3E2723),
    ];

    for (int i = 0; i < 2400; i++) {
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      final controlX = x + (rand.nextDouble() - 0.5) * 200;
      final controlY = y + (rand.nextDouble() - 0.5) * 200;
      final endX = x + (rand.nextDouble() - 0.5) * 200;
      final endY = y + (rand.nextDouble() - 0.5) * 200;
      final color = colors[rand.nextInt(colors.length)];

      final path = Path();
      path.moveTo(x, y);
      path.quadraticBezierTo(controlX, controlY, endX, endY);

      final paint = Paint()
        ..color = color.withOpacity(rand.nextDouble() * 0.6 + 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = rand.nextDouble() * 6 + 1;
      canvas.drawPath(path, paint);

      // Draw thorns along the vine
      final numThorns = rand.nextInt(4) + 1;
      for (int j = 0; j < numThorns; j++) {
        final t = rand.nextDouble();
        final thornX = x + (endX - x) * t;
        final thornY = y + (endY - y) * t;
        
        final thornAngle = rand.nextDouble() * 2 * pi;
        final thornLen = rand.nextDouble() * 25 + 5;
        
        final thornPath = Path();
        thornPath.moveTo(thornX, thornY);
        thornPath.lineTo(
          thornX + cos(thornAngle - 0.2) * thornLen * 0.2, 
          thornY + sin(thornAngle - 0.2) * thornLen * 0.2
        );
        thornPath.lineTo(
          thornX + cos(thornAngle) * thornLen, 
          thornY + sin(thornAngle) * thornLen
        );
        thornPath.lineTo(
          thornX + cos(thornAngle + 0.2) * thornLen * 0.2, 
          thornY + sin(thornAngle + 0.2) * thornLen * 0.2
        );
        thornPath.close();

        final thornPaint = Paint()
          ..color = (rand.nextBool() ? color : const Color(0xFF111111)).withOpacity(0.9)
          ..style = PaintingStyle.fill;
        canvas.drawPath(thornPath, thornPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
