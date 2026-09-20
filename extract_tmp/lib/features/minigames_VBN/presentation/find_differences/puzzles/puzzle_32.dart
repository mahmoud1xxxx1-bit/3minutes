import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../html_canvas.dart';
import '../puzzle_model.dart';

class Puzzle32 extends PuzzleDefinition {
  @override
  int get id => 32;

  void drawGear(HtmlCanvas c, double cx, double cy, double radius, int teeth, String color) {
    c.fillStyle = color;
    c.beginPath(); c.arc(cx, cy, radius, 0, math.pi * 2); c.fill();
    for (int i = 0; i < teeth; i++) {
      double a = i * (math.pi * 2 / teeth);
      c.save();
      c.translate(cx, cy);
      c.rotate(a);
      c.fillRect(radius - 5, -5, 15, 10);
      c.restore();
    }
    // Inner holes
    c.fillStyle = '#111';
    c.beginPath(); c.arc(cx, cy, radius * 0.7, 0, math.pi * 2); c.fill();
    c.fillStyle = color;
    c.beginPath(); c.arc(cx, cy, radius * 0.2, 0, math.pi * 2); c.fill();
    // Crossbars
    for(int i=0; i<4; i++) {
      c.save(); c.translate(cx, cy); c.rotate(i * math.pi/4);
      c.fillRect(-radius*0.7, -5, radius*1.4, 10);
      c.restore();
    }
    c.fillStyle = '#111';
    c.beginPath(); c.arc(cx, cy, radius * 0.05, 0, math.pi * 2); c.fill();
  }

  @override
  void drawBaseScene(HtmlCanvas c) {
    c.fillStyle = '#0a0a0a';
    c.fillRect(0, 0, 800, 600);

    // Beams
    c.fillStyle = '#263238';
    c.fillRect(0, 100, 800, 40);
    c.fillRect(300, 0, 40, 600);
    c.fillRect(0, 450, 800, 50);

    // Rivets
    c.fillStyle = '#546e7a';
    for (int i = 0; i < 20; i++) {
      c.beginPath(); c.arc(20 + i * 40, 120, 4, 0, math.pi * 2); c.fill();
      c.beginPath(); c.arc(20 + i * 40, 475, 4, 0, math.pi * 2); c.fill();
    }
    for (int i = 0; i < 15; i++) {
      c.beginPath(); c.arc(320, 20 + i * 40, 4, 0, math.pi * 2); c.fill();
    }

    // Lots of gears
    drawGear(c, 150, 250, 120, 16, '#795548'); // Bronze
    drawGear(c, 280, 350, 80, 12, '#b0bec5'); // Silver
    drawGear(c, 450, 200, 150, 24, '#f57f17'); // Gold
    drawGear(c, 600, 400, 100, 14, '#795548'); // Bronze
    drawGear(c, 100, 500, 60, 8, '#b0bec5');  // Silver

    // Sub-dials (Pressure gauges)
    c.fillStyle = '#fff';
    c.beginPath(); c.arc(700, 150, 40, 0, math.pi * 2); c.fill();
    c.strokeStyle = '#f57f17';
    c.lineWidth = 5;
    c.beginPath(); c.arc(700, 150, 40, 0, math.pi * 2); c.stroke();
    // Ticks
    c.strokeStyle = '#111';
    c.lineWidth = 2;
    for(int i=0; i<8; i++) {
      double a = i * math.pi/4;
      c.beginPath(); c.moveTo(700 + math.cos(a)*30, 150 + math.sin(a)*30);
      c.lineTo(700 + math.cos(a)*40, 150 + math.sin(a)*40); c.stroke();
    }
    // Hand
    c.strokeStyle = '#d32f2f';
    c.lineWidth = 3;
    c.beginPath(); c.moveTo(700, 150); c.lineTo(700 - 20, 150 - 20); c.stroke(); // Angle -45 deg

    // Chain
    c.strokeStyle = '#546e7a';
    c.lineWidth = 8;
    for (int i = 0; i < 10; i++) {
      c.beginPath(); c.arc(50, 50 + i * 25, 10, 0, math.pi * 2); c.stroke();
    }

    // Small brass fitting
    c.fillStyle = '#fbc02d';
    c.fillRect(350, 460, 20, 30);
  }

  @override
  List<Difference> get differences => [
    Difference(
      'missingGearTooth',
      const Rect.fromLTWH(110, 110, 80, 40),
      const Offset(150, 125),
      (HtmlCanvas c) {
        c.fillStyle = '#0a0a0a'; // Background color to hide top tooth
        c.save();
        c.translate(150, 250);
        c.rotate(-math.pi/2); // Top tooth
        c.fillRect(120 - 6, -6, 17, 12);
        c.restore();
      }
    ),
    Difference(
      'missingRivet',
      const Rect.fromLTWH(200, 455, 40, 40),
      const Offset(220, 475),
      (HtmlCanvas c) {
        c.fillStyle = '#263238'; // Beam color
        c.beginPath(); c.arc(220, 475, 5, 0, math.pi * 2); c.fill();
      }
    ),
    Difference(
      'subDialHandAngle',
      const Rect.fromLTWH(660, 110, 80, 80),
      const Offset(700, 150),
      (HtmlCanvas c) {
        // Erase old hand
        c.fillStyle = '#fff';
        c.beginPath(); c.arc(700, 150, 38, 0, math.pi * 2); c.fill();
        c.strokeStyle = '#111';
        c.lineWidth = 2;
        for(int i=0; i<8; i++) {
          double a = i * math.pi/4;
          c.beginPath(); c.moveTo(700 + math.cos(a)*30, 150 + math.sin(a)*30);
          c.lineTo(700 + math.cos(a)*38, 150 + math.sin(a)*38); c.stroke();
        }
        // Draw new hand
        c.strokeStyle = '#d32f2f';
        c.lineWidth = 3;
        c.beginPath(); c.moveTo(700, 150); c.lineTo(700 + 20, 150 - 20); c.stroke(); // Flipped angle
      }
    ),
    Difference(
      'missingChainLink',
      const Rect.fromLTWH(30, 165, 40, 40),
      const Offset(50, 175), // i=5 -> 50 + 125 = 175
      (HtmlCanvas c) {
        c.fillStyle = '#0a0a0a';
        c.fillRect(35, 160, 30, 30);
      }
    ),
    Difference(
      'brassFittingColor',
      const Rect.fromLTWH(340, 450, 40, 50),
      const Offset(360, 475),
      (HtmlCanvas c) {
        c.fillStyle = '#d84315'; // Dark orange/copper instead of yellow
        c.fillRect(350, 460, 20, 30);
      }
    )
  ];
}
