import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../html_canvas.dart';
import '../puzzle_model.dart';

class Puzzle40 extends PuzzleDefinition {
  @override
  int get id => 40;

  @override
  void drawBaseScene(HtmlCanvas c) {
    c.fillStyle = '#212121';
    c.fillRect(0, 0, 800, 600);

    c.fillStyle = '#424242';
    c.fillRect(180, 80, 440, 240);
    c.fillStyle = '#000';
    c.fillRect(200, 100, 400, 200);

    c.strokeStyle = '#00e676';
    c.lineWidth = 2;
    c.beginPath();
    for(int i=0; i<400; i++) {
      double x = 200.0 + i;
      double y = 200.0 + math.sin(i * 0.05) * 50;
      if (i==0) {
        c.moveTo(x,y);
      } else {
        c.lineTo(x,y);
      }
    }
    c.stroke();

    c.fillStyle = '#424242'; c.fillRect(20, 80, 140, 140);
    c.fillStyle = '#000'; c.beginPath(); c.arc(90, 150, 60, 0, math.pi*2); c.fill();
    c.strokeStyle = '#00e676'; c.lineWidth = 1;
    c.beginPath(); c.arc(90, 150, 20, 0, math.pi*2); c.stroke();
    c.beginPath(); c.arc(90, 150, 40, 0, math.pi*2); c.stroke();
    c.beginPath(); c.arc(90, 150, 60, 0, math.pi*2); c.stroke();
    c.beginPath(); c.moveTo(90, 90); c.lineTo(90, 210); c.stroke();
    c.beginPath(); c.moveTo(30, 150); c.lineTo(150, 150); c.stroke();
    
    c.fillStyle = 'rgba(0, 230, 118, 0.3)';
    c.beginPath(); c.moveTo(90,150); c.arc(90,150, 60, 0, math.pi/4); c.lineTo(90,150); c.fill();
    
    c.fillStyle = '#00e676'; c.beginPath(); c.arc(120, 120, 3, 0, math.pi*2); c.fill();

    c.fillStyle = '#424242'; c.fillRect(640, 80, 140, 240);
    c.fillStyle = '#000'; c.fillRect(650, 90, 120, 220);
    c.fillStyle = '#00e676';
    for(int i=0; i<10; i++) {
      c.fillText((i%2==0) ? "010110" : "110001", 660, 110 + i*20);
    }

    c.fillStyle = '#616161';
    c.beginPath(); c.moveTo(0, 350); c.lineTo(800, 350); c.lineTo(800, 600); c.lineTo(0, 600); c.fill();
    c.strokeStyle = '#424242'; c.lineWidth = 4;
    c.beginPath(); c.moveTo(0, 400); c.lineTo(800, 400); c.stroke();

    for(int i=0; i<20; i++) {
      for(int j=0; j<4; j++) {
        c.fillStyle = (i*j%7==0) ? '#d50000' : '#424242';
        c.fillRect(50 + i*35, 450 + j*30, 20, 20);
      }
    }
    c.fillStyle = '#d50000'; c.fillRect(575, 510, 20, 20);

    c.fillStyle = '#9e9e9e';
    for(int i=0; i<5; i++) {
      c.beginPath(); c.arc(100 + i*150, 375, 15, 0, math.pi*2); c.fill();
      c.strokeStyle = '#000'; c.lineWidth = 2;
      c.beginPath(); c.moveTo(100 + i*150, 375); c.lineTo(100 + i*150 + math.cos(i)*10, 375 + math.sin(i)*10); c.stroke();
    }

    c.strokeStyle = '#fdd835'; c.lineWidth = 5;
    c.beginPath(); c.moveTo(350, 350); c.quadraticCurveTo(400, 380, 450, 350); c.stroke();
  }

  @override
  List<Difference> get differences => [
    Difference(
      'buttonColorChange',
      const Rect.fromLTWH(565, 500, 40, 40),
      const Offset(585, 520),
      (HtmlCanvas c) {
        c.fillStyle = '#00e676';
        c.fillRect(575, 510, 20, 20);
      }
    ),
    Difference(
      'sineWaveFrequency',
      const Rect.fromLTWH(200, 100, 400, 200),
      const Offset(400, 200),
      (HtmlCanvas c) {
        c.fillStyle = '#000'; c.fillRect(200, 100, 400, 200);
        c.strokeStyle = '#00e676'; c.lineWidth = 2;
        c.beginPath();
        for(int i=0; i<400; i++) {
          double x = 200.0 + i;
          double y = 200.0 + math.sin(i * 0.1) * 50;
          if (i==0) {
            c.moveTo(x,y);
          } else {
            c.lineTo(x,y);
          }
        }
        c.stroke();
      }
    ),
    Difference(
      'missingRadarBlip',
      const Rect.fromLTWH(110, 110, 20, 20),
      const Offset(120, 120),
      (HtmlCanvas c) {
        c.fillStyle = '#000';
        c.fillRect(115, 115, 10, 10);
        c.strokeStyle = '#00e676'; c.lineWidth = 1;
        c.beginPath(); c.arc(90, 150, 40, 0, math.pi*2); c.stroke(); 
      }
    ),
    Difference(
      'binaryBitFlip',
      const Rect.fromLTWH(650, 140, 120, 40),
      const Offset(680, 160), 
      (HtmlCanvas c) {
        c.fillStyle = '#000'; c.fillRect(650, 150, 120, 20);
        c.fillStyle = '#00e676';
        c.fillText("111001", 660, 170); 
      }
    ),
    Difference(
      'missingWire',
      const Rect.fromLTWH(340, 340, 120, 50),
      const Offset(400, 365),
      (HtmlCanvas c) {
        c.fillStyle = '#616161';
        c.fillRect(345, 351, 110, 40);
      }
    )
  ];
}
