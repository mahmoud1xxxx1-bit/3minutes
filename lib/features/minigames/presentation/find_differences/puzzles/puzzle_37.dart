import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../html_canvas.dart';
import '../puzzle_model.dart';

class Puzzle37 extends PuzzleDefinition {
  @override
  int get id => 37;

  @override
  void drawBaseScene(HtmlCanvas c) {
    // Sky
    c.fillStyle = '#add8e6'; c.fillRect(0, 0, 800, 600);
    
    // Dirt Ground
    c.fillStyle = '#cd853f'; c.fillRect(0, 450, 800, 150);
    c.fillStyle = '#8b4513'; c.fillRect(0, 430, 800, 20); // pavement edge
    
    // Under Construction Building
    c.fillStyle = '#808080'; c.fillRect(100, 200, 300, 250);
    // Steel beams (columns)
    c.fillStyle = '#4f4f4f';
    for (double x = 100; x <= 400; x += 100) {
      c.fillRect(x - 10, 200, 20, 250);
    }
    // Steel beams (floors)
    for (double y = 200; y <= 450; y += 80) {
      c.fillRect(90, y - 5, 320, 10);
    }
    
    // Scaffolding
    c.strokeStyle = '#a9a9a9'; c.lineWidth = 4;
    for (double x = 80; x <= 420; x += 60) {
      c.beginPath(); c.moveTo(x, 200); c.lineTo(x, 450); c.stroke();
    }
    for (double y = 220; y <= 450; y += 60) {
      c.beginPath(); c.moveTo(80, y); c.lineTo(420, y); c.stroke();
      // Cross braces
      c.beginPath(); c.moveTo(80, y); c.lineTo(140, y-60); c.stroke();
      c.beginPath(); c.moveTo(140, y); c.lineTo(200, y-60); c.stroke();
      c.beginPath(); c.moveTo(200, y); c.lineTo(260, y-60); c.stroke();
      c.beginPath(); c.moveTo(260, y); c.lineTo(320, y-60); c.stroke();
      c.beginPath(); c.moveTo(320, y); c.lineTo(380, y-60); c.stroke();
    }
    
    // Crane
    c.fillStyle = '#ffd700'; // Crane yellow
    c.fillRect(550, 100, 40, 350); // Tower
    c.fillRect(300, 120, 350, 20); // Jib
    c.fillRect(590, 130, 80, 20); // Counter-jib
    c.fillStyle = '#696969'; c.fillRect(650, 120, 20, 40); // Counterweight
    c.fillStyle = '#000000'; c.beginPath(); c.moveTo(570, 70); c.lineTo(320, 120); c.stroke(); // Cable
    c.beginPath(); c.moveTo(570, 70); c.lineTo(650, 120); c.stroke(); // Back cable
    
    // Crane Hook and Block
    c.strokeStyle = '#000000'; c.lineWidth = 2;
    c.beginPath(); c.moveTo(350, 140); c.lineTo(350, 250); c.stroke();
    c.fillStyle = '#ff0000'; c.fillRect(340, 250, 20, 15);
    c.strokeStyle = '#000000'; c.lineWidth = 5;
    c.beginPath(); c.arc(350, 275, 10, -math.pi/2, math.pi); c.stroke();
    
    // Cement Mixer
    c.fillStyle = '#ffd700';
    c.beginPath(); c.ellipse(650, 400, 40, 60, math.pi/4, 0, math.pi*2); c.fill();
    c.fillStyle = '#333333'; c.fillRect(610, 430, 80, 20); // base
    c.beginPath(); c.arc(630, 450, 15, 0, math.pi*2); c.fill(); // wheel
    c.beginPath(); c.arc(670, 450, 15, 0, math.pi*2); c.fill(); // wheel
    c.fillStyle = '#a9a9a9'; c.beginPath(); c.ellipse(620, 370, 20, 10, math.pi/4, 0, math.pi*2); c.fill(); // opening

    // Dirt Piles
    c.fillStyle = '#8b4513';
    c.beginPath(); c.moveTo(450, 450); c.lineTo(500, 380); c.lineTo(550, 450); c.fill();
    c.beginPath(); c.moveTo(520, 450); c.lineTo(560, 400); c.lineTo(600, 450); c.fill();
    
    // Caution Cones
    void drawCone(double cx, double cy) {
      c.fillStyle = '#ff4500';
      c.beginPath(); c.moveTo(cx, cy - 30); c.lineTo(cx - 15, cy); c.lineTo(cx + 15, cy); c.fill();
      c.fillStyle = '#ffffff';
      c.beginPath(); c.moveTo(cx - 5, cy - 10); c.lineTo(cx - 10, cy - 20); c.lineTo(cx + 10, cy - 20); c.lineTo(cx + 5, cy - 10); c.fill();
    }
    drawCone(200, 500);
    drawCone(400, 520);
    drawCone(700, 480);
  }

  @override
  List<Difference> get differences => [
    Difference(
      'craneHook',
      const Rect.fromLTWH(335.0, 260.0, 30.0, 35.0),
      const Offset(350, 275),
      (HtmlCanvas c) {
        c.fillStyle = '#add8e6'; c.fillRect(335, 260, 30, 35);
        c.fillStyle = '#ff0000'; c.fillRect(340, 250, 20, 15);
        c.strokeStyle = '#000000'; c.lineWidth = 4;
        c.beginPath(); c.moveTo(350, 265); c.lineTo(350, 290); c.stroke();
        c.beginPath(); c.moveTo(335, 290); c.lineTo(365, 290); c.stroke();
      }
    ),
    Difference(
      'coneStripeMissing',
      const Rect.fromLTWH(385.0, 495.0, 30.0, 30.0),
      const Offset(400, 510),
      (HtmlCanvas c) {
        c.fillStyle = '#ff4500';
        c.beginPath(); c.moveTo(400, 490); c.lineTo(385, 520); c.lineTo(415, 520); c.fill();
      }
    ),
    Difference(
      'dirtPileSize',
      const Rect.fromLTWH(440.0, 340.0, 120.0, 110.0),
      const Offset(500, 380),
      (HtmlCanvas c) {
        c.fillStyle = '#add8e6'; c.fillRect(440, 340, 120, 110);
        c.fillStyle = '#8b4513';
        c.beginPath(); c.moveTo(450, 450); c.lineTo(500, 340); c.lineTo(550, 450); c.fill();
        c.beginPath(); c.moveTo(520, 450); c.lineTo(560, 400); c.lineTo(600, 450); c.fill();
      }
    ),
    Difference(
      'mixerColor',
      const Rect.fromLTWH(610.0, 360.0, 80.0, 80.0),
      const Offset(650, 400),
      (HtmlCanvas c) {
        c.fillStyle = '#ff8c00'; // Dark orange
        c.beginPath(); c.ellipse(650, 400, 40, 60, math.pi/4, 0, math.pi*2); c.fill();
        c.fillStyle = '#a9a9a9'; c.beginPath(); c.ellipse(620, 370, 20, 10, math.pi/4, 0, math.pi*2); c.fill();
      }
    ),
    Difference(
      'extraBeam',
      const Rect.fromLTWH(210.0, 210.0, 80.0, 60.0),
      const Offset(250, 240),
      (HtmlCanvas c) {
        c.fillStyle = '#4f4f4f';
        c.fillRect(245, 200, 10, 80);
        c.strokeStyle = '#a9a9a9'; c.lineWidth = 4;
        c.beginPath(); c.moveTo(250, 200); c.lineTo(250, 280); c.stroke();
      }
    )
  ];
}
