import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../html_canvas.dart';
import '../puzzle_model.dart';

class Puzzle39 extends PuzzleDefinition {
  @override
  int get id => 39;

  @override
  void drawBaseScene(HtmlCanvas c) {
    // Sky
    c.fillStyle = '#87ceeb'; c.fillRect(0, 0, 800, 600);
    
    // Sun and rays
    c.fillStyle = '#ffd700'; c.beginPath(); c.arc(700, 100, 50, 0, math.pi*2); c.fill();
    c.strokeStyle = '#ffd700'; c.lineWidth = 5;
    for (double i = 0; i < 12; i++) {
      double angle = i * math.pi / 6;
      c.beginPath();
      c.moveTo(700 + math.cos(angle) * 60, 100 + math.sin(angle) * 60);
      c.lineTo(700 + math.cos(angle) * 100, 100 + math.sin(angle) * 100);
      c.stroke();
    }
    
    // Sand Dunes
    c.fillStyle = '#f4a460'; c.fillRect(0, 400, 800, 200);
    c.fillStyle = '#deb887';
    c.beginPath(); c.ellipse(200, 450, 400, 150, 0, math.pi, 0); c.fill();
    c.beginPath(); c.ellipse(600, 420, 350, 120, 0, math.pi, 0); c.fill();
    
    // Great Pyramid
    c.fillStyle = '#d2b48c'; // Tan color
    c.beginPath(); c.moveTo(350, 150); c.lineTo(150, 400); c.lineTo(550, 400); c.fill();
    c.fillStyle = '#cd853f'; // Shaded side
    c.beginPath(); c.moveTo(350, 150); c.lineTo(550, 400); c.lineTo(350, 400); c.fill();
    // Pyramid Blocks Lines
    c.strokeStyle = '#8b4513'; c.lineWidth = 1;
    for (double y = 170; y <= 400; y += 15) {
      double w = (y - 150) / 250 * 200;
      c.beginPath(); c.moveTo(350 - w, y); c.lineTo(350 + w, y); c.stroke();
      for (double x = 350 - w; x <= 350 + w; x += 30) {
        c.beginPath(); c.moveTo(x + (y % 30 == 0 ? 15 : 0), y); c.lineTo(x + (y % 30 == 0 ? 15 : 0), y + 15); c.stroke();
      }
    }
    
    // Missing block space (we'll fill it in base, remove in difference)
    c.fillStyle = '#cd853f'; c.fillRect(365, 335, 30, 15);
    c.strokeStyle = '#8b4513'; c.strokeRect(365, 335, 30, 15);

    // Sphinx (Simplified)
    c.fillStyle = '#d2b48c';
    c.fillRect(550, 350, 150, 50); // Body
    c.beginPath(); c.arc(600, 320, 30, 0, math.pi*2); c.fill(); // Head
    c.fillStyle = '#b8860b'; // Headdress
    c.beginPath(); c.arc(600, 320, 35, math.pi, 0); c.fill();
    c.fillRect(565, 320, 15, 40); c.fillRect(620, 320, 15, 40);
    // Sphinx Face
    c.fillStyle = '#000000';
    c.beginPath(); c.arc(590, 315, 3, 0, math.pi*2); c.fill(); // Eye
    c.beginPath(); c.arc(610, 315, 3, 0, math.pi*2); c.fill(); // Eye
    c.fillStyle = '#8b4513'; c.fillRect(595, 320, 10, 15); // Nose

    // Palm Tree
    c.fillStyle = '#8b4513';
    c.beginPath(); c.moveTo(100, 480); c.lineTo(120, 480); c.lineTo(110, 300); c.fill();
    c.fillStyle = '#228b22';
    for (double angle = 0; angle < math.pi * 2; angle += math.pi / 4) {
      c.beginPath(); c.ellipse(110 + math.cos(angle)*40, 300 + math.sin(angle)*20, 50, 10, angle, 0, math.pi*2); c.fill();
    }
    // Coconuts
    c.fillStyle = '#8b4513';
    c.beginPath(); c.arc(100, 310, 8, 0, math.pi*2); c.fill();
    c.beginPath(); c.arc(120, 310, 8, 0, math.pi*2); c.fill();

    // Camel
    c.fillStyle = '#cdaa7d';
    c.beginPath(); c.ellipse(300, 520, 40, 25, 0, 0, math.pi*2); c.fill(); // Body
    c.beginPath(); c.arc(300, 495, 20, math.pi, 0); c.fill(); // Hump
    c.beginPath(); c.ellipse(345, 485, 12, 10, 0, 0, math.pi*2); c.fill(); // Head
    c.strokeStyle = '#cdaa7d'; c.lineWidth = 10;
    c.beginPath(); c.moveTo(330, 510); c.lineTo(340, 490); c.stroke(); // Neck
    // Legs
    c.lineWidth = 6;
    c.beginPath(); c.moveTo(270, 530); c.lineTo(270, 570); c.stroke();
    c.beginPath(); c.moveTo(280, 530); c.lineTo(285, 570); c.stroke();
    c.beginPath(); c.moveTo(320, 530); c.lineTo(320, 570); c.stroke();
    c.beginPath(); c.moveTo(330, 530); c.lineTo(335, 570); c.stroke();
  }

  @override
  List<Difference> get differences => [
    Difference(
      'pyramidBlock',
      const Rect.fromLTWH(360.0, 330.0, 40.0, 25.0),
      const Offset(380, 340),
      (HtmlCanvas c) {
        c.fillStyle = '#000000'; c.fillRect(365, 335, 30, 15);
      }
    ),
    Difference(
      'sphinxNose',
      const Rect.fromLTWH(590.0, 315.0, 20.0, 25.0),
      const Offset(600, 327),
      (HtmlCanvas c) {
        c.fillStyle = '#d2b48c'; c.fillRect(595, 320, 10, 15); // Cover nose
      }
    ),
    Difference(
      'palmTreeCoconuts',
      const Rect.fromLTWH(100.0, 310.0, 30.0, 20.0),
      const Offset(110, 320),
      (HtmlCanvas c) {
        c.fillStyle = '#8b4513';
        c.beginPath(); c.arc(110, 315, 8, 0, math.pi*2); c.fill(); // Third coconut
      }
    ),
    Difference(
      'camelHump',
      const Rect.fromLTWH(270.0, 475.0, 60.0, 30.0),
      const Offset(300, 490),
      (HtmlCanvas c) {
        c.fillStyle = '#deb887'; // Sky/sand background to clear old hump
        c.fillRect(270, 475, 60, 25);
        c.fillStyle = '#cdaa7d';
        c.beginPath(); c.arc(285, 495, 15, math.pi, 0); c.fill(); // Hump 1
        c.beginPath(); c.arc(315, 495, 15, math.pi, 0); c.fill(); // Hump 2
      }
    ),
    Difference(
      'sunRays',
      const Rect.fromLTWH(730.0, 40.0, 60.0, 60.0),
      const Offset(760, 60),
      (HtmlCanvas c) {
        c.fillStyle = '#87ceeb'; // Clear top right ray
        c.beginPath(); c.moveTo(740, 60); c.lineTo(790, 10); c.lineTo(800, 40); c.lineTo(750, 80); c.fill();
      }
    )
  ];
}
