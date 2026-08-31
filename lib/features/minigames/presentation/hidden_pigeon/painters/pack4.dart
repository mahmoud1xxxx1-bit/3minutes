import 'dart:math';
import 'package:flutter/material.dart';

class PigeonPainterPack4 extends CustomPainter {
  final int seed;
  final int themeIndex;
  
  PigeonPainterPack4(this.seed, this.themeIndex);

  @override
  void paint(Canvas canvas, Size size) {
    final rand = Random(seed * 100 + themeIndex);
    switch (themeIndex) {
      case 0: _drawMusicNotes(canvas, size, rand); break;
      case 1: _drawGeometryGrid(canvas, size, rand); break;
      case 2: _drawTangledWires(canvas, size, rand); break;
      case 3: _drawFeathers(canvas, size, rand); break;
      case 4: _drawEyeballs(canvas, size, rand); break;
      case 5: _drawDragonScales(canvas, size, rand); break;
    }
  }

  void _drawMusicNotes(Canvas canvas, Size size, Random rand) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFF0F0F0));
    final staffPaint = Paint()..color = Colors.black26..strokeWidth = 2;
    for (int i = 0; i < 200; i++) {
      double y = rand.nextDouble() * size.height;
      for(int j = 0; j < 5; j++) {
        canvas.drawLine(Offset(0, y + j * 10), Offset(size.width, y + j * 10), staffPaint);
      }
    }
    
    final noteColors = [Colors.black87, Colors.black, Colors.deepPurple[900]!, Colors.blueGrey[900]!];
    for (int i = 0; i < 2500; i++) {
      double x = rand.nextDouble() * size.width;
      double y = rand.nextDouble() * size.height;
      double scale = 0.5 + rand.nextDouble() * 1.5;
      
      final paint = Paint()..color = noteColors[rand.nextInt(noteColors.length)];
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(-0.2);
      canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 15 * scale, height: 10 * scale), paint);
      
      if (rand.nextBool()) {
        paint.strokeWidth = 2 * scale;
        double stemDir = rand.nextBool() ? 1 : -1;
        canvas.drawLine(Offset(7 * scale, 0), Offset(7 * scale, -30 * stemDir * scale), paint);
        if (rand.nextBool()) {
          canvas.drawLine(Offset(7 * scale, -30 * stemDir * scale), Offset(15 * scale, -25 * stemDir * scale), paint);
        }
      }
      canvas.restore();
    }
  }

  void _drawGeometryGrid(Canvas canvas, Size size, Random rand) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF1E1E24));
    final colors = [
      const Color(0xFFE54B4B).withValues(alpha: 0.6),
      const Color(0xFFF7EBE8).withValues(alpha: 0.6),
      const Color(0xFF444140).withValues(alpha: 0.6),
      const Color(0xFF1E1E24).withValues(alpha: 0.6),
      const Color(0xFFF2D0A9).withValues(alpha: 0.6),
    ];
    
    for (int i = 0; i < 3000; i++) {
      double cx = rand.nextDouble() * size.width;
      double cy = rand.nextDouble() * size.height;
      double radius = 10 + rand.nextDouble() * 40;
      int edges = 3 + rand.nextInt(4); // 3 to 6
      
      final paint = Paint()
        ..color = colors[rand.nextInt(colors.length)]
        ..style = rand.nextBool() ? PaintingStyle.fill : PaintingStyle.stroke
        ..strokeWidth = 1 + rand.nextDouble() * 4;
        
      Path path = Path();
      double startAngle = rand.nextDouble() * pi * 2;
      for (int j = 0; j < edges; j++) {
        double angle = startAngle + (j * 2 * pi / edges);
        double px = cx + cos(angle) * radius;
        double py = cy + sin(angle) * radius;
        if (j == 0) {
          path.moveTo(px, py);
        } else {
          path.lineTo(px, py);
        }
      }
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  void _drawTangledWires(Canvas canvas, Size size, Random rand) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF222222));
    final colors = [Colors.red, Colors.blue, Colors.yellow, Colors.green, Colors.orange, Colors.white, Colors.black];
    
    for (int i = 0; i < 1800; i++) {
      final paint = Paint()
        ..color = colors[rand.nextInt(colors.length)].withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 + rand.nextDouble() * 6
        ..strokeCap = StrokeCap.round;
        
      double startX = rand.nextDouble() * size.width;
      double startY = rand.nextDouble() * size.height;
      
      Path path = Path()..moveTo(startX, startY);
      
      double currX = startX;
      double currY = startY;
      for (int j = 0; j < 4; j++) {
        double cp1x = currX + (rand.nextDouble() - 0.5) * 150;
        double cp1y = currY + (rand.nextDouble() - 0.5) * 150;
        double cp2x = currX + (rand.nextDouble() - 0.5) * 150;
        double cp2y = currY + (rand.nextDouble() - 0.5) * 150;
        double endX = currX + (rand.nextDouble() - 0.5) * 200;
        double endY = currY + (rand.nextDouble() - 0.5) * 200;
        path.cubicTo(cp1x, cp1y, cp2x, cp2y, endX, endY);
        currX = endX;
        currY = endY;
      }
      canvas.drawPath(path, paint);
      
      if (rand.nextDouble() < 0.2) {
        canvas.drawCircle(Offset(currX, currY), paint.strokeWidth * 1.5, Paint()..color = Colors.grey[800]!);
      }
    }
  }

  void _drawFeathers(Canvas canvas, Size size, Random rand) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFD8E2DC));
    final colors = [
      const Color(0xFFFFCAD4).withValues(alpha: 0.8),
      const Color(0xFFF4ACB7).withValues(alpha: 0.8),
      const Color(0xFF9D8189).withValues(alpha: 0.8),
      const Color(0xFFFFE5D9).withValues(alpha: 0.8),
    ];
    
    for (int i = 0; i < 2500; i++) {
      double cx = rand.nextDouble() * size.width;
      double cy = rand.nextDouble() * size.height;
      double length = 30 + rand.nextDouble() * 50;
      double width = length * (0.2 + rand.nextDouble() * 0.2);
      double angle = rand.nextDouble() * pi * 2;
      
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(angle);
      
      Path path = Path();
      path.moveTo(0, -length / 2);
      path.quadraticBezierTo(width, 0, 0, length / 2);
      path.quadraticBezierTo(-width, 0, 0, -length / 2);
      
      canvas.drawPath(path, Paint()..color = colors[rand.nextInt(colors.length)]);
      canvas.drawLine(Offset(0, -length / 2), Offset(0, length / 2), Paint()..color = Colors.black26..strokeWidth = 1.5);
      
      int barbs = 10 + rand.nextInt(15);
      for(int j = 0; j < barbs; j++) {
        double py = -length/2 + (length * j / barbs);
        double py2 = py + rand.nextDouble() * 10;
        canvas.drawLine(Offset(0, py), Offset(width * 0.8 * sin(j/barbs * pi), py2), Paint()..color = Colors.black12..strokeWidth = 1);
        canvas.drawLine(Offset(0, py), Offset(-width * 0.8 * sin(j/barbs * pi), py2), Paint()..color = Colors.black12..strokeWidth = 1);
      }
      canvas.restore();
    }
  }

  void _drawEyeballs(Canvas canvas, Size size, Random rand) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF110000));
    final irisColors = [Colors.blue, Colors.green, Colors.brown, Colors.amber, Colors.purple, Colors.red];
    
    for (int i = 0; i < 2000; i++) {
      double cx = rand.nextDouble() * size.width;
      double cy = rand.nextDouble() * size.height;
      double r = 10 + rand.nextDouble() * 25;
      
      // Sclera
      canvas.drawCircle(Offset(cx, cy), r, Paint()..color = Colors.white);
      
      // Veins
      if (rand.nextDouble() < 0.4) {
        final veinPaint = Paint()..color = Colors.red.withValues(alpha: 0.5)..strokeWidth = 1..style = PaintingStyle.stroke;
        int numVeins = rand.nextInt(5);
        for(int v=0; v<numVeins; v++) {
          Path p = Path()..moveTo(cx + cos(rand.nextDouble()*2*pi)*r, cy + sin(rand.nextDouble()*2*pi)*r);
          p.quadraticBezierTo(cx + (rand.nextDouble()-0.5)*r, cy + (rand.nextDouble()-0.5)*r, cx + (rand.nextDouble()-0.5)*r*0.5, cy + (rand.nextDouble()-0.5)*r*0.5);
          canvas.drawPath(p, veinPaint);
        }
      }
      
      // Iris
      double irisR = r * (0.4 + rand.nextDouble() * 0.3);
      double lookAngle = rand.nextDouble() * pi * 2;
      double lookDist = rand.nextDouble() * (r - irisR - 2);
      Offset irisCenter = Offset(cx + cos(lookAngle) * lookDist, cy + sin(lookAngle) * lookDist);
      
      canvas.drawCircle(irisCenter, irisR, Paint()..color = irisColors[rand.nextInt(irisColors.length)]);
      
      // Pupil
      double pupilR = irisR * (0.3 + rand.nextDouble() * 0.4);
      canvas.drawCircle(irisCenter, pupilR, Paint()..color = Colors.black);
      
      // Highlight
      canvas.drawCircle(irisCenter + Offset(-irisR * 0.3, -irisR * 0.3), irisR * 0.2, Paint()..color = Colors.white.withValues(alpha: 0.8));
    }
  }

  void _drawDragonScales(Canvas canvas, Size size, Random rand) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF0F1A12));
    final colors = [
      const Color(0xFF1B4332).withValues(alpha: 0.9),
      const Color(0xFF2D6A4F).withValues(alpha: 0.9),
      const Color(0xFF40916C).withValues(alpha: 0.9),
      const Color(0xFF52B788).withValues(alpha: 0.9),
      const Color(0xFF74C69D).withValues(alpha: 0.9),
      const Color(0xFFFFD700).withValues(alpha: 0.5), // rare gold
    ];
    
    double scaleWidth = 30.0;
    double scaleHeight = 40.0;
    
    // Draw scales in overlapping rows
    for (int i = 0; i < 2500; i++) {
      double cx = rand.nextDouble() * size.width;
      double cy = rand.nextDouble() * size.height;
      double scaleSize = 0.5 + rand.nextDouble();
      double w = scaleWidth * scaleSize;
      double h = scaleHeight * scaleSize;
      double angle = (rand.nextDouble() - 0.5) * pi * 0.5;
      
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(angle);
      
      Path path = Path();
      path.moveTo(0, -h / 2);
      path.quadraticBezierTo(w / 2, -h / 4, w / 2, h / 4);
      path.lineTo(0, h / 2);
      path.lineTo(-w / 2, h / 4);
      path.quadraticBezierTo(-w / 2, -h / 4, 0, -h / 2);
      
      Color c = (rand.nextDouble() < 0.05) ? colors.last : colors[rand.nextInt(colors.length - 1)];
      
      canvas.drawPath(path, Paint()..color = c);
      canvas.drawPath(path, Paint()..color = Colors.black54..style = PaintingStyle.stroke..strokeWidth = 2);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
