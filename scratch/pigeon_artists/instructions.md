You are an expert Flutter Generative Artist.
Your task is to write a single Dart file containing 6 DISTINCT procedural background drawing algorithms for a Hidden Object game.
The backgrounds MUST be EXTREMELY DENSE and CLUTTERED (thousands of overlapping elements) to hide small items.

For example, a dense city has 1500 overlapping rectangles. A forest has 3000 overlapping circles and lines.
Do NOT use Size.infinite. The canvas size will be provided in the paint method.
Do NOT use external images. Use ONLY Canvas drawing methods (drawRect, drawCircle, drawPath, drawLine, etc.).

You must create a class PigeonPainterPack that extends CustomPainter.
It takes inal int seed; and inal int themeIndex; (0 to 5) in its constructor.
In the paint method, switch on 	hemeIndex to call one of 6 distinct private drawing functions.

IMPORTANT RULES:
1. Make the drawings EXTREMELY dense visually. Use loops of 1500 to 3000 iterations.
2. Use beautiful, harmonious colors for each theme.
3. Be highly creative. Use complex paths, bezier curves, overlapping geometry.

Example structure:
`dart
import 'dart:math';
import 'package:flutter/material.dart';

class PigeonPainterPack_A extends CustomPainter {
  final int seed;
  final int themeIndex;
  
  PigeonPainterPack_A(this.seed, this.themeIndex);

  @override
  void paint(Canvas canvas, Size size) {
    final rand = Random(seed * 100 + themeIndex);
    switch (themeIndex) {
      case 0: _drawTheme0(canvas, size, rand); break;
      case 1: _drawTheme1(canvas, size, rand); break;
      case 2: _drawTheme2(canvas, size, rand); break;
      case 3: _drawTheme3(canvas, size, rand); break;
      case 4: _drawTheme4(canvas, size, rand); break;
      case 5: _drawTheme5(canvas, size, rand); break;
    }
  }

  void _drawTheme0(Canvas canvas, Size size, Random rand) { ... }
  // ... implement all 6 themes with EXTREME visual density
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
`

Use the exact class name and filename given in your initial prompt!
