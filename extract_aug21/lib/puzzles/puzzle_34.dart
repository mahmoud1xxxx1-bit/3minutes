import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../html_canvas.dart';
import '../puzzle_model.dart';

class Puzzle34 extends PuzzleDefinition {
  @override
  int get id => 34;

  @override
  void drawBaseScene(HtmlCanvas c) {
    // Night sky
    c.fillStyle = '#0a0a14';
    c.fillRect(0, 0, 800, 600);

    // Buildings
    c.fillStyle = '#111118';
    c.fillRect(50, 0, 200, 500);
    c.fillRect(400, 50, 350, 450);

    // Windows
    c.fillStyle = '#222233';
    for(int i=0; i<10; i++) {
      for(int j=0; j<4; j++) {
        if ((i*j)%5 != 0) {
          c.fillRect(60 + j*40, 20 + i*45, 30, 30);
        }
        if ((i*j)%3 != 0) {
          c.fillRect(420 + j*60, 70 + i*45, 40, 30);
        }
      }
    }
    // Lit windows
    c.fillStyle = '#e6ee9c';
    c.fillRect(100, 110, 30, 30);
    c.fillRect(480, 205, 40, 30);

    // Cables
    c.strokeStyle = '#000';
    c.lineWidth = 4;
    c.beginPath(); c.moveTo(0, 100); c.quadraticCurveTo(200, 150, 400, 80); c.stroke();
    c.beginPath(); c.moveTo(250, 200); c.quadraticCurveTo(450, 300, 800, 150); c.stroke();
    // Small vertical cable on left wall
    c.beginPath(); c.moveTo(220, 250); c.lineTo(220, 400); c.stroke();

    // Vending machine
    c.fillStyle = '#b71c1c';
    c.fillRect(100, 350, 100, 150);
    c.fillStyle = '#80cbc4';
    c.fillRect(110, 360, 80, 60);
    // Drinks
    c.fillStyle = '#ff5252'; c.fillRect(115, 365, 10, 20);
    c.fillStyle = '#448aff'; c.fillRect(135, 365, 10, 20);
    c.fillStyle = '#69f0ae'; c.fillRect(155, 365, 10, 20);

    // Neon sign
    c.strokeStyle = '#ff4081';
    c.lineWidth = 5;
    c.beginPath(); c.moveTo(500, 150); c.lineTo(550, 150); c.lineTo(525, 200); c.stroke();
    c.beginPath(); c.moveTo(510, 170); c.lineTo(540, 170); c.stroke(); // Kanji-like

    // Street lamp
    c.fillStyle = '#424242';
    c.fillRect(350, 250, 10, 250);
    c.beginPath(); c.arc(355, 250, 15, math.pi, 0); c.fill();
    // Light glow
    final glow = c.createRadialGradient(355, 250, 5, 355, 250, 100);
    glow..addColorStop(0, 'rgba(255, 235, 59, 0.6)')..addColorStop(1, 'rgba(255, 235, 59, 0)');
    c.fillStyle = glow;
    c.beginPath(); c.arc(355, 250, 100, 0, math.pi*2); c.fill();

    // Street
    c.fillStyle = '#1c1c1c';
    c.fillRect(0, 500, 800, 100);

    // Puddle
    c.fillStyle = '#263238';
    c.beginPath(); c.ellipse(300, 550, 80, 20, 0, 0, math.pi*2); c.fill();
    // Reflection
    c.fillStyle = 'rgba(255, 64, 129, 0.4)';
    c.fillRect(280, 545, 40, 10);

    // Rain
    c.strokeStyle = 'rgba(255,255,255,0.2)';
    c.lineWidth = 1;
    for(int i=0; i<100; i++) {
      double x = (i * 37) % 800;
      double y = (i * 53) % 600;
      c.beginPath(); c.moveTo(x, y); c.lineTo(x - 5, y + 15); c.stroke();
    }
  }

  @override
  List<Difference> get differences => [
    Difference(
      'neonSignModified',
      const Rect.fromLTWH(490, 140, 70, 70),
      const Offset(525, 175),
      (HtmlCanvas c) {
        // Redraw sign without the middle crossbar
        c.fillStyle = '#111118';
        c.fillRect(490, 140, 70, 70); // Erase
        c.strokeStyle = '#ff4081';
        c.lineWidth = 5;
        c.beginPath(); c.moveTo(500, 150); c.lineTo(550, 150); c.lineTo(525, 200); c.stroke();
      }
    ),
    Difference(
      'missingWallCable',
      const Rect.fromLTWH(210, 250, 20, 150),
      const Offset(220, 325),
      (HtmlCanvas c) {
        c.fillStyle = '#111118';
        c.fillRect(215, 245, 10, 160); // Paint over cable
      }
    ),
    Difference(
      'puddleReflectionMissing',
      const Rect.fromLTWH(270, 535, 60, 30),
      const Offset(300, 550),
      (HtmlCanvas c) {
        c.fillStyle = '#263238';
        c.fillRect(275, 540, 50, 20); // Paint over reflection
      }
    ),
    Difference(
      'lampGlowRadius',
      const Rect.fromLTWH(255, 150, 200, 200),
      const Offset(355, 250),
      (HtmlCanvas c) {
        // Erase old glow area by redrawing buildings
        c.fillStyle = '#0a0a14'; c.fillRect(255, 150, 200, 200);
        c.fillStyle = '#111118'; c.fillRect(50, 150, 200, 350); c.fillRect(400, 150, 55, 350);
        // Redraw cables
        c.strokeStyle = '#000'; c.lineWidth = 4;
        c.beginPath(); c.moveTo(0, 100); c.quadraticCurveTo(200, 150, 400, 80); c.stroke();
        c.beginPath(); c.moveTo(250, 200); c.quadraticCurveTo(450, 300, 800, 150); c.stroke();
        c.beginPath(); c.moveTo(220, 250); c.lineTo(220, 400); c.stroke();
        // Redraw lamp post
        c.fillStyle = '#424242';
        c.fillRect(350, 250, 10, 250);
        c.beginPath(); c.arc(355, 250, 15, math.pi, 0); c.fill();
        // Smaller glow
        final glow = c.createRadialGradient(355, 250, 5, 355, 250, 50);
        glow..addColorStop(0, 'rgba(255, 235, 59, 0.6)')..addColorStop(1, 'rgba(255, 235, 59, 0)');
        c.fillStyle = glow;
        c.beginPath(); c.arc(355, 250, 50, 0, math.pi*2); c.fill();
      }
    ),
    Difference(
      'extraTinCan',
      const Rect.fromLTWH(550, 540, 30, 30),
      const Offset(565, 555),
      (HtmlCanvas c) {
        c.fillStyle = '#9e9e9e';
        c.fillRect(555, 545, 15, 20);
        c.fillStyle = '#e0e0e0';
        c.fillRect(555, 545, 15, 4);
      }
    )
  ];
}
