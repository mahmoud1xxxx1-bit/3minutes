import 'package:flutter/material.dart';
import 'painters/pack1.dart';
import 'painters/pack2.dart';
import 'painters/pack3.dart';
import 'painters/pack4.dart';
import 'painters/pack5.dart';
import 'painters/pack6.dart';
import 'painters/pack7.dart';
import 'painters/pack8.dart';
import 'painters/pack9.dart';
import 'painters/pack10.dart';
import 'painters/pack11.dart';
import 'painters/pack12.dart';
import 'painters/pack13.dart';
import 'painters/pack14.dart';
import 'painters/pack15.dart';

class MasterPigeonPainter extends CustomPainter {
  final int seed; 
  final int roundIndex; 

  MasterPigeonPainter(this.seed, this.roundIndex);

  @override
  void paint(Canvas canvas, Size size) {
    // 15 packs * 6 themes = 90 completely unique themes!
    int globalIndex = ((seed - 1) * 3 + roundIndex) % 90;

    int packNumber = globalIndex ~/ 6; 
    int themeIndex = globalIndex % 6;  

    switch (packNumber) {
      case 0: PigeonPainterPack1(seed, themeIndex).paint(canvas, size); break;
      case 1: PigeonPainterPack2(seed, themeIndex).paint(canvas, size); break;
      case 2: PigeonPainterPack3(seed, themeIndex).paint(canvas, size); break;
      case 3: PigeonPainterPack4(seed, themeIndex).paint(canvas, size); break;
      case 4: PigeonPainterPack5(seed, themeIndex).paint(canvas, size); break;
      case 5: PigeonPainterPack6(seed, themeIndex).paint(canvas, size); break;
      case 6: PigeonPainterPack7(seed, themeIndex).paint(canvas, size); break;
      case 7: PigeonPainterPack8(seed, themeIndex).paint(canvas, size); break;
      case 8: PigeonPainterPack9(seed, themeIndex).paint(canvas, size); break;
      case 9: PigeonPainterPack10(seed, themeIndex).paint(canvas, size); break;
      case 10: PigeonPainterPack11(seed, themeIndex).paint(canvas, size); break;
      case 11: PigeonPainterPack12(seed, themeIndex).paint(canvas, size); break;
      case 12: PigeonPainterPack13(seed, themeIndex).paint(canvas, size); break;
      case 13: PigeonPainterPack14(seed, themeIndex).paint(canvas, size); break;
      case 14: PigeonPainterPack15(seed, themeIndex).paint(canvas, size); break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
