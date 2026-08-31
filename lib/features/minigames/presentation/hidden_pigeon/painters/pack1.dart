import 'dart:math';
import 'package:flutter/material.dart';

class PigeonPainterPack1 extends CustomPainter {
  final int seed;
  final int themeIndex;
  
  PigeonPainterPack1(this.seed, this.themeIndex);

  @override
  void paint(Canvas canvas, Size size) {
    final rand = Random(seed * 100 + themeIndex);
    switch (themeIndex) {
      case 0: _drawCyberpunkCity(canvas, size, rand); break;
      case 1: _drawUnderwaterReef(canvas, size, rand); break;
      case 2: _drawCandyLand(canvas, size, rand); break;
      case 3: _drawSkeletonBones(canvas, size, rand); break;
      case 4: _drawCircuitBoard(canvas, size, rand); break;
      case 5: _drawVolcanicLava(canvas, size, rand); break;
    }
  }

  // 0: Cyberpunk City
  void _drawCyberpunkCity(Canvas canvas, Size size, Random rand) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF0D0221));
    for (int i = 0; i < 2000; i++) {
      double x = rand.nextDouble() * size.width;
      double w = rand.nextDouble() * 40 + 10;
      double h = rand.nextDouble() * size.height * 0.8 + size.height * 0.2;
      double y = size.height - h + rand.nextDouble() * 50;
      
      Color c = rand.nextBool() 
          ? Color.fromARGB(255, 10 + rand.nextInt(40), 10 + rand.nextInt(40), 50 + rand.nextInt(50))
          : Color.fromARGB(255, rand.nextInt(20), rand.nextInt(20), rand.nextInt(30));
          
      canvas.drawRect(Rect.fromLTWH(x, y, w, h), Paint()..color = c);
      
      // Windows
      if (rand.nextBool()) {
        int windowRows = 5 + rand.nextInt(20);
        int windowCols = 2 + rand.nextInt(4);
        Color neonColor = [
          const Color(0xFF00FFCC),
          const Color(0xFFFF00FF),
          const Color(0xFFFFFF00),
          const Color(0xFFFF0055),
        ][rand.nextInt(4)].withOpacity(0.8);
        Paint windowPaint = Paint()..color = neonColor;
        for (int r = 0; r < windowRows; r++) {
          for (int c = 0; c < windowCols; c++) {
            if (rand.nextDouble() > 0.3) {
              canvas.drawRect(Rect.fromLTWH(x + 2 + c * (w / windowCols), y + 2 + r * (h / windowRows), (w / windowCols) - 4, (h / windowRows) - 4), windowPaint);
            }
          }
        }
      }
    }
    
    // Flying cars/lights
    for (int i = 0; i < 1500; i++) {
      double x = rand.nextDouble() * size.width;
      double y = rand.nextDouble() * size.height;
      double w = rand.nextDouble() * 30 + 5;
      double h = rand.nextDouble() * 5 + 1;
      Color neonColor = [
          const Color(0xFF00FFCC),
          const Color(0xFFFF00FF),
          const Color(0xFFFFFF00),
      ][rand.nextInt(3)].withOpacity(0.6);
      canvas.drawRect(Rect.fromLTWH(x, y, w, h), Paint()..color = neonColor..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0));
    }
  }

  // 1: Underwater Reef
  void _drawUnderwaterReef(Canvas canvas, Size size, Random rand) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF001F3F));
    
    // Water gradient
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [const Color(0xFF004080).withOpacity(0.8), const Color(0xFF001122).withOpacity(0.9)],
    );
    canvas.drawRect(Offset.zero & size, Paint()..shader = gradient.createShader(Offset.zero & size));

    // Corals & Plants
    for (int i = 0; i < 2500; i++) {
      double x = rand.nextDouble() * size.width;
      double y = size.height - rand.nextDouble() * size.height * 0.9;
      
      Color coralColor = [
        const Color(0xFFFF6B6B),
        const Color(0xFF4ECDC4),
        const Color(0xFFFFD93D),
        const Color(0xFF95E1D3),
        const Color(0xFFF38181),
        const Color(0xFF845EC2),
      ][rand.nextInt(6)];

      int type = rand.nextInt(3);
      if (type == 0) {
        // Tube coral
        double w = rand.nextDouble() * 20 + 5;
        double h = rand.nextDouble() * 100 + 20;
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(x, y - h, w, h), Radius.circular(w/2)),
          Paint()..color = coralColor,
        );
      } else if (type == 1) {
        // Brain coral
        double r = rand.nextDouble() * 40 + 10;
        canvas.drawCircle(Offset(x, y), r, Paint()..color = coralColor);
        for(int j=0; j<20; j++) {
           Path p = Path();
           p.moveTo(x + rand.nextDouble()*r - r/2, y + rand.nextDouble()*r - r/2);
           p.quadraticBezierTo(x + rand.nextDouble()*r - r/2, y + rand.nextDouble()*r - r/2, x + rand.nextDouble()*r - r/2, y + rand.nextDouble()*r - r/2);
           canvas.drawPath(p, Paint()..color = coralColor.withOpacity(0.5)..style = PaintingStyle.stroke..strokeWidth = 2);
        }
      } else {
        // Seaweed
        Path path = Path();
        path.moveTo(x, y);
        double curX = x;
        double curY = y;
        int segments = 5 + rand.nextInt(10);
        for (int j = 0; j < segments; j++) {
          double nx = curX + (rand.nextDouble() - 0.5) * 30;
          double ny = curY - (rand.nextDouble() * 20 + 10);
          path.quadraticBezierTo(curX + (rand.nextDouble() - 0.5) * 40, curY - 10, nx, ny);
          curX = nx;
          curY = ny;
        }
        canvas.drawPath(path, Paint()
          ..color = coralColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = rand.nextDouble() * 5 + 2
          ..strokeCap = StrokeCap.round
        );
      }
    }
    
    // Bubbles
    for (int i = 0; i < 1500; i++) {
      double x = rand.nextDouble() * size.width;
      double y = rand.nextDouble() * size.height;
      double r = rand.nextDouble() * 15 + 2;
      canvas.drawCircle(Offset(x, y), r, Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
      );
    }
  }

  // 2: Candy Land
  void _drawCandyLand(Canvas canvas, Size size, Random rand) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFFFD1DC));
    
    for (int i = 0; i < 2500; i++) {
      double x = rand.nextDouble() * size.width;
      double y = rand.nextDouble() * size.height;
      int type = rand.nextInt(4);
      
      Color c1 = [
        const Color(0xFFFF9AA2),
        const Color(0xFFFFB7B2),
        const Color(0xFFFFDAC1),
        const Color(0xFFE2F0CB),
        const Color(0xFFB5EAD7),
        const Color(0xFFC7CEEA),
        Colors.white,
      ][rand.nextInt(7)];
      
      Color c2 = [
        const Color(0xFFFF9AA2),
        const Color(0xFFFFB7B2),
        const Color(0xFFFFDAC1),
        const Color(0xFFE2F0CB),
        const Color(0xFFB5EAD7),
        const Color(0xFFC7CEEA),
        Colors.white,
      ][rand.nextInt(7)];

      if (type == 0) {
        // Lollipop
        double stickH = rand.nextDouble() * 50 + 20;
        canvas.drawLine(Offset(x, y), Offset(x, y + stickH), Paint()..color = Colors.white..strokeWidth = 4);
        double r = rand.nextDouble() * 20 + 10;
        canvas.drawCircle(Offset(x, y), r, Paint()..color = c1);
        
        // Swirl
        Path swirl = Path();
        for(double t = 0; t < pi * 4; t+=0.1) {
           double r2 = (t / (pi * 4)) * r;
           double px = x + r2 * cos(t);
           double py = y + r2 * sin(t);
           if (t == 0) swirl.moveTo(px, py);
           else swirl.lineTo(px, py);
        }
        canvas.drawPath(swirl, Paint()..color = c2..style = PaintingStyle.stroke..strokeWidth = 3);

      } else if (type == 1) {
        // Wrapped Candy
        double w = rand.nextDouble() * 30 + 15;
        double h = rand.nextDouble() * 15 + 10;
        canvas.drawRect(Rect.fromCenter(center: Offset(x, y), width: w, height: h), Paint()..color = c1);
        
        // Wrappers
        Path wrapper = Path();
        wrapper.moveTo(x - w/2, y);
        wrapper.lineTo(x - w, y - h);
        wrapper.lineTo(x - w, y + h);
        wrapper.close();
        wrapper.moveTo(x + w/2, y);
        wrapper.lineTo(x + w, y - h);
        wrapper.lineTo(x + w, y + h);
        wrapper.close();
        canvas.drawPath(wrapper, Paint()..color = c2);
      } else if (type == 2) {
        // Jelly bean
        double w = rand.nextDouble() * 25 + 15;
        double h = rand.nextDouble() * 15 + 10;
        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(rand.nextDouble() * pi);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: w, height: h), Radius.circular(h/2)), Paint()..color = c1);
        canvas.restore();
      } else {
         // Sprinkles
         double l = rand.nextDouble() * 15 + 5;
         double ang = rand.nextDouble() * pi;
         canvas.drawLine(Offset(x, y), Offset(x + cos(ang)*l, y + sin(ang)*l), Paint()..color = c1..strokeWidth=4..strokeCap=StrokeCap.round);
      }
    }
  }

  // 3: Skeleton/Bones
  void _drawSkeletonBones(Canvas canvas, Size size, Random rand) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF1A1A1A));
    
    for (int i = 0; i < 2000; i++) {
      double x = rand.nextDouble() * size.width;
      double y = rand.nextDouble() * size.height;
      int type = rand.nextInt(3);
      
      Color boneColor = [
        const Color(0xFFE0E0E0),
        const Color(0xFFF5F5DC),
        const Color(0xFFD3D3D3),
        const Color(0xFFC0C0C0),
        const Color(0xFFA9A9A9).withOpacity(0.8),
      ][rand.nextInt(5)];

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rand.nextDouble() * pi * 2);

      if (type == 0) {
        // Femur-like bone
        double len = rand.nextDouble() * 80 + 30;
        double w = len * 0.2;
        canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: len, height: w), Paint()..color = boneColor);
        // Bone ends
        canvas.drawCircle(Offset(-len/2, -w/1.5), w, Paint()..color = boneColor);
        canvas.drawCircle(Offset(-len/2, w/1.5), w, Paint()..color = boneColor);
        canvas.drawCircle(Offset(len/2, -w/1.5), w, Paint()..color = boneColor);
        canvas.drawCircle(Offset(len/2, w/1.5), w, Paint()..color = boneColor);
      } else if (type == 1) {
        // Skull-like shape
        double r = rand.nextDouble() * 20 + 10;
        canvas.drawCircle(Offset.zero, r, Paint()..color = boneColor);
        canvas.drawRect(Rect.fromLTWH(-r*0.6, r*0.2, r*1.2, r*0.8), Paint()..color = boneColor);
        
        // Eyes
        canvas.drawCircle(Offset(-r*0.4, -r*0.2), r*0.3, Paint()..color = const Color(0xFF1A1A1A));
        canvas.drawCircle(Offset(r*0.4, -r*0.2), r*0.3, Paint()..color = const Color(0xFF1A1A1A));
      } else {
        // Rib-like curve
        double w = rand.nextDouble() * 60 + 20;
        double h = rand.nextDouble() * 30 + 10;
        Path rib = Path();
        rib.moveTo(-w/2, 0);
        rib.quadraticBezierTo(0, -h, w/2, 0);
        rib.quadraticBezierTo(0, -h*0.6, -w/2, 0);
        canvas.drawPath(rib, Paint()..color = boneColor);
      }
      canvas.restore();
    }
  }

  // 4: Circuit Board
  void _drawCircuitBoard(Canvas canvas, Size size, Random rand) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF003300));
    
    for (int i = 0; i < 2500; i++) {
      Color c = [
        const Color(0xFF00FF00),
        const Color(0xFF00CC00),
        const Color(0xFF33FF33),
        const Color(0xFFCCFFCC),
        const Color(0xFFFFCC00), // Gold pins
      ][rand.nextInt(5)];

      int type = rand.nextInt(3);
      double x = rand.nextDouble() * size.width;
      double y = rand.nextDouble() * size.height;

      if (type == 0) {
        // Trace lines
        Path p = Path();
        p.moveTo(x, y);
        double cx = x;
        double cy = y;
        int segments = 2 + rand.nextInt(4);
        for (int j = 0; j < segments; j++) {
           if (rand.nextBool()) {
              cx += (rand.nextBool() ? 1 : -1) * (rand.nextDouble() * 40 + 10);
           } else {
              cy += (rand.nextBool() ? 1 : -1) * (rand.nextDouble() * 40 + 10);
           }
           p.lineTo(cx, cy);
           // sometimes diagonal
           if (rand.nextDouble() > 0.7) {
              double d = rand.nextDouble() * 20 + 10;
              cx += (rand.nextBool() ? 1 : -1) * d;
              cy += (rand.nextBool() ? 1 : -1) * d;
              p.lineTo(cx, cy);
           }
        }
        canvas.drawPath(p, Paint()
          ..color = c
          ..style = PaintingStyle.stroke
          ..strokeWidth = rand.nextDouble() * 3 + 1
          ..strokeCap = StrokeCap.square
          ..strokeJoin = StrokeJoin.miter
        );
        
        // End node
        canvas.drawCircle(Offset(cx, cy), rand.nextDouble() * 4 + 2, Paint()..color = c);
      } else if (type == 1) {
        // Chip
        double w = rand.nextDouble() * 60 + 20;
        double h = rand.nextDouble() * 60 + 20;
        canvas.drawRect(Rect.fromCenter(center: Offset(x, y), width: w, height: h), Paint()..color = const Color(0xFF111111));
        
        // Pins
        Paint pinPaint = Paint()..color = const Color(0xFFC0C0C0);
        int pins = 4 + rand.nextInt(10);
        double pinSpacing = w / pins;
        for (int j = 0; j < pins; j++) {
           canvas.drawRect(Rect.fromLTWH(x - w/2 + j*pinSpacing + pinSpacing*0.2, y - h/2 - 5, pinSpacing*0.6, 5), pinPaint);
           canvas.drawRect(Rect.fromLTWH(x - w/2 + j*pinSpacing + pinSpacing*0.2, y + h/2, pinSpacing*0.6, 5), pinPaint);
        }
        pinSpacing = h / pins;
        for (int j = 0; j < pins; j++) {
           canvas.drawRect(Rect.fromLTWH(x - w/2 - 5, y - h/2 + j*pinSpacing + pinSpacing*0.2, 5, pinSpacing*0.6), pinPaint);
           canvas.drawRect(Rect.fromLTWH(x + w/2, y - h/2 + j*pinSpacing + pinSpacing*0.2, 5, pinSpacing*0.6), pinPaint);
        }
      } else {
        // Capacitors/Resistors
        double w = rand.nextDouble() * 10 + 5;
        double h = rand.nextDouble() * 25 + 10;
        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(rand.nextBool() ? 0 : pi/2);
        canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: w, height: h), Paint()..color = const Color(0xFF884400));
        canvas.drawLine(Offset(0, -h/2), Offset(0, -h/2 - 10), Paint()..color = const Color(0xFFC0C0C0)..strokeWidth=2);
        canvas.drawLine(Offset(0, h/2), Offset(0, h/2 + 10), Paint()..color = const Color(0xFFC0C0C0)..strokeWidth=2);
        canvas.restore();
      }
    }
  }

  // 5: Volcanic Lava
  void _drawVolcanicLava(Canvas canvas, Size size, Random rand) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF220000));
    
    // Background rock
    for (int i = 0; i < 1000; i++) {
       double x = rand.nextDouble() * size.width;
       double y = rand.nextDouble() * size.height;
       double r = rand.nextDouble() * 50 + 20;
       Color rock = [
         const Color(0xFF111111),
         const Color(0xFF222222),
         const Color(0xFF333333),
         const Color(0xFF442222),
       ][rand.nextInt(4)];
       
       Path p = Path();
       p.moveTo(x, y - r);
       for (int j = 1; j < 8; j++) {
         double a = j * pi * 2 / 8;
         double rad = r * (0.8 + rand.nextDouble() * 0.4);
         p.lineTo(x + cos(a) * rad, y + sin(a) * rad);
       }
       p.close();
       canvas.drawPath(p, Paint()..color = rock);
    }

    // Lava rivers and blobs
    for (int i = 0; i < 2000; i++) {
      double x = rand.nextDouble() * size.width;
      double y = rand.nextDouble() * size.height;
      int type = rand.nextInt(3);
      
      Color lavaColor = [
        const Color(0xFFFF0000),
        const Color(0xFFFF4500),
        const Color(0xFFFF8C00),
        const Color(0xFFFFD700),
      ][rand.nextInt(4)];

      if (type == 0) {
        // Blob
        double r = rand.nextDouble() * 30 + 5;
        canvas.drawCircle(Offset(x, y), r, Paint()
          ..color = lavaColor
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0)
        );
        canvas.drawCircle(Offset(x, y), r * 0.6, Paint()..color = const Color(0xFFFFFFFF).withOpacity(0.5));
      } else if (type == 1) {
        // Flow
        Path p = Path();
        p.moveTo(x, y);
        double cx = x;
        double cy = y;
        for (int j = 0; j < 5; j++) {
           cx += (rand.nextDouble() - 0.5) * 40;
           cy += rand.nextDouble() * 50;
           p.lineTo(cx, cy);
        }
        canvas.drawPath(p, Paint()
          ..color = lavaColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = rand.nextDouble() * 15 + 5
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0)
        );
      } else {
        // Sparks / Ash
        double r = rand.nextDouble() * 4 + 1;
        canvas.drawCircle(Offset(x, y), r, Paint()..color = [Colors.yellow, Colors.orange, Colors.red, Colors.black][rand.nextInt(4)]);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
