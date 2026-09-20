import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../html_canvas.dart';
import '../puzzle_model.dart';

class Puzzle31 extends PuzzleDefinition {
  @override
  int get id => 31;

  @override
  void drawBaseScene(HtmlCanvas c) {
    // Dark room background
    final bg = c.createLinearGradient(0, 0, 0, 600);
    bg..addColorStop(0, '#1a1025')..addColorStop(1, '#0d0812');
    c.fillStyle = bg;
    c.fillRect(0, 0, 800, 600);

    // Stone wall texture (busy)
    c.strokeStyle = '#2a1a35';
    c.lineWidth = 2;
    for (int i = 0; i < 20; i++) {
      for (int j = 0; j < 15; j++) {
        c.strokeRect(j * 60 - (i % 2) * 30, i * 30, 60, 30);
      }
    }

    // Large wooden bookshelf
    c.fillStyle = '#3e2723';
    c.fillRect(50, 50, 700, 500);
    c.fillStyle = '#1b100e';
    c.fillRect(70, 70, 660, 460); // Inner shadow

    // Shelves
    c.fillStyle = '#5d4037';
    for (int i = 1; i < 4; i++) {
      c.fillRect(50, 50 + i * 120, 700, 15);
      // Shelf shadow
      c.fillStyle = '#261a16';
      c.fillRect(70, 65 + i * 120, 660, 10);
      c.fillStyle = '#5d4037';
    }

    // Books on Shelf 1 (busy pattern)
    for (int i = 0; i < 40; i++) {
      double x = 80 + i * 16.0;
      if (i % 7 == 3) continue; // gaps
      c.fillStyle = (i % 3 == 0) ? '#4a148c' : ((i % 3 == 1) ? '#b71c1c' : '#01579b');
      double h = 60.0 + (i % 5) * 10;
      c.fillRect(x, 170 - h, 14, h);
      c.fillStyle = '#d4af37';
      c.fillRect(x + 2, 175 - h, 10, 4);
    }

    // Potions on Shelf 2
    for (int i = 0; i < 15; i++) {
      double x = 100 + i * 42.0;
      // Bottle base
      c.fillStyle = 'rgba(255, 255, 255, 0.2)';
      c.beginPath();
      c.arc(x, 270, 15, 0, math.pi * 2);
      c.fill();
      // Bottle neck
      c.fillRect(x - 5, 240, 10, 20);
      // Liquid
      c.fillStyle = (i % 4 == 0) ? '#00e676' : ((i % 4 == 1) ? '#d50000' : '#2979ff');
      c.beginPath();
      c.arc(x, 275, 12, 0, math.pi);
      c.fill();
      // Label
      if (i != 8) { // The missing label diff
        c.fillStyle = '#ffecb3';
        c.fillRect(x - 8, 265, 16, 8);
      }
      // Cork
      c.fillStyle = '#795548';
      c.fillRect(x - 6, 235, 12, 5);
    }

    // Magical Artifacts on Shelf 3
    // Crystal ball
    c.fillStyle = '#37474f';
    c.fillRect(150, 400, 40, 10);
    final glow = c.createRadialGradient(170, 370, 5, 170, 370, 30);
    glow..addColorStop(0, '#e0f7fa')..addColorStop(1, 'rgba(0, 188, 212, 0.1)');
    c.fillStyle = glow;
    c.beginPath(); c.arc(170, 370, 30, 0, math.pi * 2); c.fill();

    // Scattered scrolls
    for (int i = 0; i < 5; i++) {
      c.fillStyle = '#fff9c4';
      c.save();
      c.translate(300 + i * 40, 400);
      c.rotate(i * 0.2 - 0.4);
      c.fillRect(-10, -20, 20, 30);
      c.fillStyle = '#d32f2f';
      c.fillRect(-10, -5, 20, 4); // ribbon
      c.restore();
    }

    // Constellation chart on wall
    c.fillStyle = '#263238';
    c.fillRect(500, 290, 160, 110);
    c.strokeStyle = '#d4af37';
    c.lineWidth = 1;
    c.beginPath();
    c.moveTo(520, 380); c.lineTo(550, 330); c.lineTo(590, 350); c.lineTo(630, 310);
    c.stroke();
    c.fillStyle = '#fff';
    c.beginPath(); c.arc(520, 380, 2, 0, math.pi * 2); c.fill();
    c.beginPath(); c.arc(550, 330, 2, 0, math.pi * 2); c.fill();
    c.beginPath(); c.arc(590, 350, 2, 0, math.pi * 2); c.fill();
    c.beginPath(); c.arc(630, 310, 2, 0, math.pi * 2); c.fill();
    
    // Star that will be missing
    c.beginPath(); c.arc(570, 315, 2, 0, math.pi * 2); c.fill();

    // Table at the bottom
    c.fillStyle = '#4e342e';
    c.fillRect(0, 530, 800, 70);
    
    // Candle on table
    c.fillStyle = '#e0e0e0';
    c.fillRect(600, 470, 20, 60);
    c.fillStyle = '#ff9800';
    c.beginPath(); c.ellipse(610, 460, 6, 12, 0, 0, math.pi * 2); c.fill();
    // Shadow
    c.fillStyle = 'rgba(0, 0, 0, 0.4)';
    c.beginPath(); c.moveTo(600, 530); c.lineTo(530, 560); c.lineTo(550, 560); c.lineTo(620, 530); c.fill();

    // Giant spellbook
    c.fillStyle = '#3e2723';
    c.save();
    c.translate(200, 530);
    c.rotate(-0.1);
    c.fillRect(-80, -20, 160, 40);
    c.fillStyle = '#f5f5dc';
    c.fillRect(-75, -15, 150, 30);
    c.fillStyle = '#111';
    for (int i = 0; i < 5; i++) {
      c.fillRect(-60, -5 + i * 4, 50, 2);
      c.fillRect(10, -5 + i * 4, 50, 2);
    }
    c.restore();
  }

  @override
  List<Difference> get differences => [
    Difference(
      'missingLabel',
      const Rect.fromLTWH(420, 255, 30, 30),
      const Offset(436, 269),
      (HtmlCanvas c) {
        double x = 100 + 8 * 42.0;
        c.fillStyle = '#ffecb3';
        c.fillRect(x - 8, 265, 16, 8);
      }
    ),
    Difference(
      'missingConstellationStar',
      const Rect.fromLTWH(555, 300, 30, 30),
      const Offset(570, 315),
      (HtmlCanvas c) {
        c.fillStyle = '#263238'; // paint over it with background color
        c.fillRect(560, 305, 20, 20);
      }
    ),
    Difference(
      'crystalGlowColor',
      const Rect.fromLTWH(135, 335, 70, 70),
      const Offset(170, 370),
      (HtmlCanvas c) {
        final glow = c.createRadialGradient(170, 370, 5, 170, 370, 30);
        glow..addColorStop(0, '#f8bbd0')..addColorStop(1, 'rgba(233, 30, 99, 0.1)'); // Pinkish glow instead of cyan
        c.fillStyle = glow;
        c.beginPath(); c.arc(170, 370, 30, 0, math.pi * 2); c.fill();
      }
    ),
    Difference(
      'candleShadowAngle',
      const Rect.fromLTWH(515, 525, 60, 40),
      const Offset(545, 545),
      (HtmlCanvas c) {
        // Erase old shadow
        c.fillStyle = '#4e342e';
        c.beginPath(); c.moveTo(600, 530); c.lineTo(530, 560); c.lineTo(550, 560); c.lineTo(620, 530); c.fill();
        // Draw new shadow at different angle
        c.fillStyle = 'rgba(0, 0, 0, 0.4)';
        c.beginPath(); c.moveTo(600, 530); c.lineTo(670, 560); c.lineTo(650, 560); c.lineTo(620, 530); c.fill();
      }
    ),
    Difference(
      'extraScroll',
      const Rect.fromLTWH(260, 490, 40, 40),
      const Offset(280, 510),
      (HtmlCanvas c) {
        c.fillStyle = '#fff9c4';
        c.save();
        c.translate(280, 510);
        c.rotate(-0.5);
        c.fillRect(-10, -20, 20, 30);
        c.fillStyle = '#1976d2'; // blue ribbon
        c.fillRect(-10, -5, 20, 4);
        c.restore();
      }
    )
  ];
}
