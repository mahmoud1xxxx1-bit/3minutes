import 'dart:math';
import 'package:flutter/material.dart';

class PigeonBackgroundPainter extends CustomPainter {
  final int seed;
  final int roundIndex;
  
  PigeonBackgroundPainter(this.seed, this.roundIndex);

  @override
  void paint(Canvas canvas, Size size) {
    final rand = Random(seed * 100 + roundIndex);
    
    // Pick 3 random distinct themes for the 3 rounds of this X
    final themeRand = Random(seed);
    List<int> availableThemes = [0, 1, 2, 3, 4, 5];
    availableThemes.shuffle(themeRand);
    
    int currentTheme = availableThemes[roundIndex];
    int difficultyMultiplier = roundIndex + 1; // 1, 2, 3

    switch (currentTheme) {
      case 0: _drawDenseTown(canvas, size, rand, difficultyMultiplier); break;
      case 1: _drawDenseForest(canvas, size, rand, difficultyMultiplier); break;
      case 2: _drawDenseAbstract(canvas, size, rand, difficultyMultiplier); break;
      case 3: _drawDenseFactory(canvas, size, rand, difficultyMultiplier); break;
      case 4: _drawDenseSpace(canvas, size, rand, difficultyMultiplier); break;
      case 5: _drawDenseCastle(canvas, size, rand, difficultyMultiplier); break;
    }
  }

  void _drawDenseTown(Canvas canvas, Size size, Random rand, int diff) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Color(0xFFFDEBD0));
    int count = 1000 * diff;
    for (int i = 0; i < count; i++) {
      double x = rand.nextDouble() * size.width;
      double y = rand.nextDouble() * size.height;
      double w = 15 + rand.nextDouble() * 60;
      double h = 15 + rand.nextDouble() * 80;
      
      Color c = [Color(0xFFE67E22), Color(0xFFD35400), Color(0xFFBDC3C7), Color(0xFF95A5A6), Color(0xFF34495E)][rand.nextInt(5)];
      canvas.drawRect(Rect.fromLTWH(x, y, w, h), Paint()..color = c);
      canvas.drawRect(Rect.fromLTWH(x, y, w, h), Paint()..color = Colors.black87..style = PaintingStyle.stroke..strokeWidth = 1.0);
      
      if (rand.nextBool()) {
        for(int j = 0; j < 5; j++) {
           double wx = x + rand.nextDouble() * (w - 10);
           double wy = y + rand.nextDouble() * (h - 10);
           canvas.drawRect(Rect.fromLTWH(wx, wy, 8, 12), Paint()..color = Color(0xFFF1C40F));
           canvas.drawRect(Rect.fromLTWH(wx, wy, 8, 12), Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 1);
        }
      }
    }
  }

  void _drawDenseForest(Canvas canvas, Size size, Random rand, int diff) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Color(0xFF1E8449));
    int count = 2000 * diff;
    for (int i = 0; i < count; i++) {
      double x = rand.nextDouble() * size.width;
      double y = rand.nextDouble() * size.height;
      double r = 8 + rand.nextDouble() * 25;
      
      Color c = [Color(0xFF27AE60), Color(0xFF2ECC71), Color(0xFF196F3D), Color(0xFFF1C40F)][rand.nextInt(4)];
      canvas.drawCircle(Offset(x, y), r, Paint()..color = c);
      canvas.drawCircle(Offset(x, y), r, Paint()..color = Colors.black54..style = PaintingStyle.stroke..strokeWidth = 1);
      
      if (i % 5 == 0) {
        double bx = x + (rand.nextDouble() - 0.5) * 80;
        double by = y + (rand.nextDouble() - 0.5) * 80;
        canvas.drawLine(Offset(x, y), Offset(bx, by), Paint()..color = Color(0xFF5D4037)..strokeWidth = 3);
      }
    }
  }

  void _drawDenseAbstract(Canvas canvas, Size size, Random rand, int diff) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Color(0xFF85C1E9));
    int count = 1500 * diff;
    for (int i = 0; i < count; i++) {
      double x = rand.nextDouble() * size.width;
      double y = rand.nextDouble() * size.height;
      Color c = [Color(0xFFE74C3C), Color(0xFF8E44AD), Color(0xFF3498DB), Colors.white][rand.nextInt(4)];
      int shape = rand.nextInt(3);
      
      final paint = Paint()..color = c.withValues(alpha: 0.9);
      final stroke = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 1.5;

      if (shape == 0) {
        canvas.drawCircle(Offset(x, y), 15 + rand.nextDouble() * 30, paint);
        canvas.drawCircle(Offset(x, y), 15 + rand.nextDouble() * 30, stroke);
      } else if (shape == 1) {
        canvas.drawRect(Rect.fromLTWH(x, y, 20 + rand.nextDouble()*40, 20 + rand.nextDouble()*40), paint);
        canvas.drawRect(Rect.fromLTWH(x, y, 20 + rand.nextDouble()*40, 20 + rand.nextDouble()*40), stroke);
      } else {
        final path = Path()
          ..moveTo(x, y)
          ..lineTo(x + rand.nextDouble() * 60, y + rand.nextDouble() * 60)
          ..lineTo(x - rand.nextDouble() * 60, y + rand.nextDouble() * 60)
          ..close();
        canvas.drawPath(path, paint);
        canvas.drawPath(path, stroke);
      }
    }
  }

  void _drawDenseFactory(Canvas canvas, Size size, Random rand, int diff) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Color(0xFF2C3E50));
    int count = 1000 * diff;
    for (int i = 0; i < count; i++) {
      double x = rand.nextDouble() * size.width;
      double y = rand.nextDouble() * size.height;
      Color c = [Color(0xFF95A5A6), Color(0xFF7F8C8D), Color(0xFFE67E22), Color(0xFFF39C12)][rand.nextInt(4)];
      
      if (rand.nextBool()) {
        canvas.drawRect(Rect.fromLTWH(x, y, 15 + rand.nextDouble()*15, 80 + rand.nextDouble()*80), Paint()..color = c);
        canvas.drawRect(Rect.fromLTWH(x, y, 15 + rand.nextDouble()*15, 80 + rand.nextDouble()*80), Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 1.5);
      } else {
        canvas.drawCircle(Offset(x, y), 20 + rand.nextDouble()*20, Paint()..color = c);
        canvas.drawCircle(Offset(x, y), 20 + rand.nextDouble()*20, Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 1.5);
        canvas.drawCircle(Offset(x, y), 8, Paint()..color = Color(0xFF2C3E50));
      }
    }
  }

  void _drawDenseSpace(Canvas canvas, Size size, Random rand, int diff) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Color(0xFF000000));
    int count = 1500 * diff;
    for (int i = 0; i < count; i++) {
      double x = rand.nextDouble() * size.width;
      double y = rand.nextDouble() * size.height;
      int type = rand.nextInt(10);
      
      if (type < 7) {
        canvas.drawCircle(Offset(x, y), 1 + rand.nextDouble()*4, Paint()..color = Colors.white);
      } else if (type < 9) {
        Color c = [Color(0xFF7F8C8D), Color(0xFF95A5A6), Color(0xFF5D6D7E)][rand.nextInt(3)];
        canvas.drawCircle(Offset(x, y), 15 + rand.nextDouble()*30, Paint()..color = c);
        canvas.drawCircle(Offset(x, y), 15 + rand.nextDouble()*30, Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 1.5);
      } else {
        Color c = [Color(0xFF9B59B6), Color(0xFF3498DB), Color(0xFFE74C3C)][rand.nextInt(3)];
        canvas.drawCircle(Offset(x, y), 30 + rand.nextDouble()*60, Paint()..color = c);
        canvas.drawCircle(Offset(x, y), 30 + rand.nextDouble()*60, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 1.5);
      }
    }
  }

  void _drawDenseCastle(Canvas canvas, Size size, Random rand, int diff) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Color(0xFF34495E));
    int count = 1500 * diff;
    for (int i = 0; i < count; i++) {
      double x = rand.nextDouble() * size.width;
      double y = rand.nextDouble() * size.height;
      
      if (rand.nextInt(4) > 0) {
        Color c = [Color(0xFF7F8C8D), Color(0xFF95A5A6), Color(0xFF5D6D7E)][rand.nextInt(3)];
        double w = 30 + rand.nextDouble()*30;
        double h = 15 + rand.nextDouble()*15;
        canvas.drawRect(Rect.fromLTWH(x, y, w, h), Paint()..color = c);
        canvas.drawRect(Rect.fromLTWH(x, y, w, h), Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 1.5);
      } else {
        Color c = [Color(0xFFE74C3C), Color(0xFFF1C40F), Color(0xFF2980B9)][rand.nextInt(3)];
        final path = Path()
          ..moveTo(x, y)
          ..lineTo(x + 20, y + 15)
          ..lineTo(x + 10, y + 40)
          ..lineTo(x - 10, y + 40)
          ..lineTo(x - 20, y + 15)
          ..close();
        canvas.drawPath(path, Paint()..color = c);
        canvas.drawPath(path, Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 1.5);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
