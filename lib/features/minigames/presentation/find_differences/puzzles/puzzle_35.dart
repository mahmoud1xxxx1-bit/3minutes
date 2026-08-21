import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../html_canvas.dart';
import '../puzzle_model.dart';

class Puzzle35 extends PuzzleDefinition {
  @override
  int get id => 35;

  @override
  void drawBaseScene(HtmlCanvas c) {
    // Water gradient
    final bg = c.createLinearGradient(0, 0, 0, 600);
    bg..addColorStop(0, '#0277bd')..addColorStop(1, '#013a5e');
    c.fillStyle = bg;
    c.fillRect(0, 0, 800, 600);

    // Light rays
    c.fillStyle = 'rgba(255, 255, 255, 0.1)';
    c.beginPath(); c.moveTo(200, 0); c.lineTo(300, 0); c.lineTo(100, 600); c.lineTo(50, 600); c.fill();
    c.beginPath(); c.moveTo(500, 0); c.lineTo(550, 0); c.lineTo(700, 600); c.lineTo(600, 600); c.fill();
    // Specific ray to move
    c.beginPath(); c.moveTo(700, 0); c.lineTo(750, 0); c.lineTo(500, 600); c.lineTo(470, 600); c.fill();

    // Ocean floor
    c.fillStyle = '#ffe082';
    c.beginPath(); c.moveTo(0, 500); c.quadraticCurveTo(200, 450, 400, 550); c.quadraticCurveTo(600, 480, 800, 520);
    c.lineTo(800, 600); c.lineTo(0, 600); c.fill();

    // Coral branches
    c.strokeStyle = '#e91e63';
    c.lineWidth = 10;
    c.lineCap = 'round';
    c.beginPath(); c.moveTo(150, 520); c.quadraticCurveTo(120, 400, 100, 350); c.stroke();
    c.beginPath(); c.moveTo(135, 460); c.quadraticCurveTo(180, 400, 190, 380); c.stroke();
    // Missing branch
    c.beginPath(); c.moveTo(125, 380); c.quadraticCurveTo(160, 340, 150, 310); c.stroke();

    // Sponges
    c.fillStyle = '#7b1fa2';
    c.beginPath(); c.ellipse(650, 550, 40, 80, 0.2, 0, math.pi*2); c.fill();
    c.fillStyle = '#9c27b0';
    c.beginPath(); c.ellipse(600, 570, 30, 60, -0.3, 0, math.pi*2); c.fill();

    // Clownfish
    c.save();
    c.translate(350, 300);
    c.fillStyle = '#ff6d00';
    c.beginPath(); c.ellipse(0, 0, 30, 15, 0, 0, math.pi*2); c.fill();
    c.beginPath(); c.moveTo(-30, 0); c.lineTo(-45, -15); c.lineTo(-45, 15); c.fill(); // tail
    c.fillStyle = '#fff';
    c.fillRect(-15, -13, 5, 26); // Stripe 1
    c.fillRect(5, -14, 5, 28);   // Stripe 2
    c.fillStyle = '#000';
    c.beginPath(); c.arc(20, -3, 2, 0, math.pi*2); c.fill(); // eye
    c.restore();

    // Bubbles
    c.strokeStyle = 'rgba(255,255,255,0.6)';
    c.lineWidth = 2;
    for(int i=0; i<20; i++) {
      c.beginPath(); c.arc(50 + (i*83)%700, 100 + (i*113)%400, (i%4)+2, 0, math.pi*2); c.stroke();
    }
    // Specific bubble to hide
    c.beginPath(); c.arc(450, 200, 4, 0, math.pi*2); c.stroke();
  }

  @override
  List<Difference> get differences => [
    Difference(
      'missingClownfishStripe',
      const Rect.fromLTWH(320, 280, 60, 40),
      const Offset(357, 300),
      (HtmlCanvas c) {
        // Redraw fish body part to hide stripe
        c.fillStyle = '#ff6d00';
        c.fillRect(355, 285, 5, 30);
      }
    ),
    Difference(
      'missingBubble',
      const Rect.fromLTWH(435, 185, 30, 30),
      const Offset(450, 200),
      (HtmlCanvas c) {
        c.fillStyle = '#015783'; // Approx water color
        c.beginPath(); c.arc(450, 200, 6, 0, math.pi*2); c.fill();
      }
    ),
    Difference(
      'missingCoralBranch',
      const Rect.fromLTWH(110, 290, 60, 100),
      const Offset(140, 340),
      (HtmlCanvas c) {
        // Erase branch with water gradient
        final bg = c.createLinearGradient(0, 0, 0, 600);
        bg..addColorStop(0, '#0277bd')..addColorStop(1, '#013a5e');
        c.fillStyle = bg;
        c.fillRect(115, 305, 50, 90);
        // Redraw main branch to cover erasure
        c.strokeStyle = '#e91e63'; c.lineWidth = 10; c.lineCap = 'round';
        c.beginPath(); c.moveTo(150, 520); c.quadraticCurveTo(120, 400, 100, 350); c.stroke();
      }
    ),
    Difference(
      'spongeColorShift',
      const Rect.fromLTWH(560, 500, 80, 100),
      const Offset(600, 570),
      (HtmlCanvas c) {
        c.fillStyle = '#e91e63'; // Pink instead of purple
        c.beginPath(); c.ellipse(600, 570, 30, 60, -0.3, 0, math.pi*2); c.fill();
      }
    ),
            Difference(
      'extraStarfish',
      const Rect.fromLTWH(500, 500, 60, 60),
      const Offset(530, 530),
      (HtmlCanvas c) {
        c.save();
        c.translate(530, 530);
        c.fillStyle = '#ff5252';
        c.beginPath();
        double a0 = -math.pi / 2;
        c.moveTo(math.cos(a0)*20, math.sin(a0)*20);
        for(int i=0; i<5; i++) {
          double a = i * math.pi * 2 / 5 - math.pi / 2;
          c.lineTo(math.cos(a)*20, math.sin(a)*20);
          a += math.pi / 5;
          c.lineTo(math.cos(a)*8, math.sin(a)*8);
        }
        c.fill();
        c.restore();
      }
    )
  ];
}
