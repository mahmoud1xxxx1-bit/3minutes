import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../html_canvas.dart';
import '../puzzle_model.dart';

class Puzzle44 extends PuzzleDefinition {
  @override
  int get id => 44;

  @override
  void drawBaseScene(HtmlCanvas c) {
    c.fillStyle = '#2d1b10'; // Dark wood bg
    c.fillRect(0, 0, 800, 600);

    // Stained Glass Window
    c.fillStyle = '#111';
    c.beginPath(); c.moveTo(400, 50); c.quadraticCurveTo(500, 50, 500, 150); c.lineTo(500, 400); c.lineTo(300, 400); c.lineTo(300, 150); c.quadraticCurveTo(300, 50, 400, 50); c.fill();
    
    // Glass Panes
    List<String> colors = ['#b71c1c', '#0d47a1', '#fbc02d', '#1b5e20', '#6a1b9a'];
    math.Random rand = math.Random(15);
    for(int i=0; i<10; i++) {
      for(int j=0; j<15; j++) {
        if ((i*20 - 100)*(i*20 - 100) + (j*20 - 150)*(j*20 - 150) < 9000 || (i>1 && i<8 && j>4)) {
          c.fillStyle = colors[rand.nextInt(colors.length)];
          c.fillRect(300 + i*20, 100 + j*20, 18, 18);
        }
      }
    }
    // Specific Pane to change (i=5, j=8) -> 400, 260
    c.fillStyle = '#b71c1c'; // Force red
    c.fillRect(400, 260, 18, 18);

    // Light Beam
    final beam = c.createLinearGradient(400, 200, 700, 600);
    beam..addColorStop(0, 'rgba(255, 235, 150, 0.3)')..addColorStop(1, 'rgba(255, 235, 150, 0)');
    c.fillStyle = beam;
    c.beginPath(); c.moveTo(350, 200); c.lineTo(450, 200); c.lineTo(800, 600); c.lineTo(600, 600); c.fill();

    // Floating Dust Motes
    c.fillStyle = '#fff';
    for(int i=0; i<60; i++) {
      double x = 400 + rand.nextDouble()*200;
      double y = 300 + rand.nextDouble()*250;
      c.beginPath(); c.arc(x, y, rand.nextDouble()*2, 0, math.pi*2); c.fill();
    }
    // Specific Dust Mote to remove
    c.beginPath(); c.arc(550, 450, 3, 0, math.pi*2); c.fill();

    // Bookshelves
    c.fillStyle = '#3e2723';
    c.fillRect(50, 0, 200, 600);
    c.fillRect(550, 0, 200, 600);
    // Shelf planks
    c.fillStyle = '#4e342e';
    for(int i=0; i<5; i++) {
      c.fillRect(40, 100 + i*100, 220, 15);
      c.fillRect(540, 100 + i*100, 220, 15);
    }
    
    // Decorative Carving on Shelf Corner (Right Shelf, Top)
    c.fillStyle = '#5d4037';
    c.beginPath(); c.arc(550, 50, 20, 0, math.pi*2); c.fill();
    c.fillStyle = '#3e2723';
    c.beginPath(); c.arc(550, 50, 10, 0, math.pi*2); c.fill();

    // Books
    for(int i=0; i<5; i++) {
      for(int j=0; j<12; j++) {
        c.fillStyle = colors[(i+j)%colors.length];
        // Straight books
        c.fillRect(60 + j*14, 20 + i*100, 12, 80);
        c.fillRect(560 + j*14, 20 + i*100, 12, 80);
      }
    }
    // Specific Leaning Book (Left shelf, 3rd row, last book) -> 60 + 11*14 = 214, 20 + 200 = 220
    c.fillStyle = '#2d1b10'; c.fillRect(200, 220, 50, 80); // Clear space
    c.save(); c.translate(210, 300); c.rotate(0.2);
    c.fillStyle = '#fbc02d'; c.fillRect(0, -80, 12, 80);
    c.restore();

    // Chandelier
    c.strokeStyle = '#212121'; c.lineWidth = 4;
    c.beginPath(); c.moveTo(400, 0); c.lineTo(400, 80); c.stroke();
    c.beginPath(); c.moveTo(320, 80); c.lineTo(480, 80); c.stroke();
    // Candles
    for(int i=0; i<3; i++) {
      c.fillStyle = '#fff'; c.fillRect(320 + i*80 - 5, 50, 10, 30);
      c.fillStyle = '#ffb300'; c.beginPath(); c.arc(320 + i*80, 40, 5, 0, math.pi*2); c.fill(); // Flames
    }
    // Specific Flame: i=1 -> 400, 40
  }

  @override
  List<Difference> get differences => [
    Difference(
      'stainedGlassColor',
      const Rect.fromLTWH(395, 255, 28, 28),
      const Offset(409, 269),
      (HtmlCanvas c) {
        c.fillStyle = '#0d47a1'; // Blue instead of Red
        c.fillRect(400, 260, 18, 18);
        // Re-apply light beam over it
        final beam = c.createLinearGradient(400, 200, 700, 600);
        beam..addColorStop(0, 'rgba(255, 235, 150, 0.3)')..addColorStop(1, 'rgba(255, 235, 150, 0)');
        c.fillStyle = beam;
        c.fillRect(400, 260, 18, 18);
      }
    ),
    Difference(
      'straightenedBook',
      const Rect.fromLTWH(190, 210, 50, 100),
      const Offset(215, 260),
      (HtmlCanvas c) {
        c.fillStyle = '#2d1b10'; c.fillRect(190, 210, 50, 90); // Clear space completely
        // Draw book straight instead of leaning
        c.fillStyle = '#fbc02d'; c.fillRect(205, 220, 12, 80);
      }
    ),
    Difference(
      'missingCandleFlame',
      const Rect.fromLTWH(390, 30, 20, 20),
      const Offset(400, 40),
      (HtmlCanvas c) {
        c.fillStyle = '#2d1b10'; c.fillRect(390, 30, 20, 20); // Erase flame
        // Redraw chandelier wire behind it
        c.strokeStyle = '#212121'; c.lineWidth = 4;
        c.beginPath(); c.moveTo(400, 30); c.lineTo(400, 50); c.stroke();
      }
    ),
    Difference(
      'missingDustMote',
      const Rect.fromLTWH(540, 440, 20, 20),
      const Offset(550, 450),
      (HtmlCanvas c) {
        // Erase mote by drawing the background + beam
        c.fillStyle = '#2d1b10'; c.fillRect(540, 440, 20, 20);
        final beam = c.createLinearGradient(400, 200, 700, 600);
        beam..addColorStop(0, 'rgba(255, 235, 150, 0.3)')..addColorStop(1, 'rgba(255, 235, 150, 0)');
        c.fillStyle = beam; c.fillRect(540, 440, 20, 20);
      }
    ),
    Difference(
      'decorativeCarvingChanged',
      const Rect.fromLTWH(520, 20, 60, 60),
      const Offset(550, 50),
      (HtmlCanvas c) {
        c.fillStyle = '#3e2723'; c.fillRect(520, 20, 60, 60); // Erase old carving
        // Draw new carving (Square instead of circle)
        c.fillStyle = '#5d4037'; c.fillRect(535, 35, 30, 30);
        c.fillStyle = '#3e2723'; c.fillRect(545, 45, 10, 10);
      }
    )
  ];
}
