import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../html_canvas.dart';
import '../puzzle_model.dart';

class Puzzle36 extends PuzzleDefinition {
  @override
  int get id => 36;

  @override
  void drawBaseScene(HtmlCanvas c) {
    // Sky
    c.fillStyle = '#87ceeb'; c.fillRect(0, 0, 800, 600);
    
    // Sun
    c.fillStyle = '#ffd700'; c.beginPath(); c.arc(700, 100, 50, 0, math.pi*2); c.fill();
    
    // Clouds
    c.fillStyle = '#ffffff';
    c.beginPath(); c.arc(150, 100, 30, 0, math.pi*2); c.fill();
    c.beginPath(); c.arc(180, 90, 40, 0, math.pi*2); c.fill();
    c.beginPath(); c.arc(220, 100, 30, 0, math.pi*2); c.fill();
    c.fillRect(150, 100, 70, 30);

    c.beginPath(); c.arc(450, 150, 25, 0, math.pi*2); c.fill();
    c.beginPath(); c.arc(480, 140, 35, 0, math.pi*2); c.fill();
    c.beginPath(); c.arc(510, 150, 25, 0, math.pi*2); c.fill();
    c.fillRect(450, 150, 60, 25);

    // Hills
    c.fillStyle = '#3cb371';
    c.beginPath(); c.ellipse(200, 400, 300, 150, 0, math.pi, 0); c.fill();
    c.beginPath(); c.ellipse(600, 450, 400, 200, 0, math.pi, 0); c.fill();

    // Grass Field
    c.fillStyle = '#2e8b57'; c.fillRect(0, 350, 800, 250);

    // Fence
    c.fillStyle = '#8b4513';
    for (double i = 0; i < 800; i += 60) {
      c.fillRect(i, 480, 10, 50);
    }
    c.fillRect(0, 490, 800, 8);
    c.fillRect(0, 510, 800, 8);

    // Silo
    c.fillStyle = '#a9a9a9'; c.fillRect(600, 150, 100, 200);
    c.fillStyle = '#696969'; c.beginPath(); c.arc(650, 150, 50, math.pi, 0); c.fill();
    c.fillStyle = '#808080';
    for (double i = 170; i < 350; i += 40) {
      c.fillRect(600, i, 100, 5);
    }

    // Barn
    c.fillStyle = '#b22222';
    c.beginPath(); c.moveTo(250, 250); c.lineTo(400, 150); c.lineTo(550, 250); c.fill();
    c.fillRect(250, 250, 300, 150);
    
    // Barn Roof Trim
    c.strokeStyle = '#ffffff'; c.lineWidth = 8;
    c.beginPath(); c.moveTo(240, 250); c.lineTo(400, 145); c.lineTo(560, 250); c.stroke();
    
    // Barn Door
    c.fillStyle = '#ffffff'; c.fillRect(350, 300, 100, 100);
    c.fillStyle = '#000000'; c.fillRect(355, 305, 42, 95); c.fillRect(403, 305, 42, 95);
    c.strokeStyle = '#ffffff'; c.lineWidth = 4;
    c.beginPath(); c.moveTo(355, 305); c.lineTo(397, 400); c.stroke();
    c.beginPath(); c.moveTo(355, 400); c.lineTo(397, 305); c.stroke();
    c.beginPath(); c.moveTo(403, 305); c.lineTo(445, 400); c.stroke();
    c.beginPath(); c.moveTo(403, 400); c.lineTo(445, 305); c.stroke();

    // Barn Window
    c.fillStyle = '#ffffff';
    c.beginPath(); c.arc(400, 220, 25, 0, math.pi*2); c.fill();
    c.fillStyle = '#000000';
    c.beginPath(); c.arc(400, 220, 20, 0, math.pi*2); c.fill();
    c.strokeStyle = '#ffffff'; c.lineWidth = 4;
    c.beginPath(); c.moveTo(380, 220); c.lineTo(420, 220); c.stroke();
    c.beginPath(); c.moveTo(400, 200); c.lineTo(400, 240); c.stroke();

    // Tractor
    c.fillStyle = '#32cd32'; c.fillRect(100, 380, 80, 50);
    c.fillRect(140, 350, 40, 30);
    c.fillStyle = '#000000';
    c.beginPath(); c.arc(120, 430, 20, 0, math.pi*2); c.fill(); // small wheel
    c.beginPath(); c.arc(170, 430, 30, 0, math.pi*2); c.fill(); // big wheel
    c.fillStyle = '#808080';
    c.beginPath(); c.arc(120, 430, 10, 0, math.pi*2); c.fill();
    c.beginPath(); c.arc(170, 430, 15, 0, math.pi*2); c.fill();
    c.fillStyle = '#ff4500'; // exhaust
    c.fillRect(110, 350, 5, 30);
  }

  @override
  List<Difference> get differences => [
    Difference(
      'barnWindowShape',
      const Rect.fromLTWH(370.0, 190.0, 60.0, 60.0),
      const Offset(400, 220),
      (HtmlCanvas c) {
        c.fillStyle = '#b22222'; c.fillRect(370, 190, 60, 60);
        c.fillStyle = '#ffffff'; c.fillRect(375, 195, 50, 50);
        c.fillStyle = '#000000'; c.fillRect(380, 200, 40, 40);
        c.strokeStyle = '#ffffff'; c.lineWidth = 4;
        c.beginPath(); c.moveTo(380, 220); c.lineTo(420, 220); c.stroke();
        c.beginPath(); c.moveTo(400, 200); c.lineTo(400, 240); c.stroke();
      }
    ),
    Difference(
      'tractorColor',
      const Rect.fromLTWH(95.0, 345.0, 90.0, 90.0),
      const Offset(140, 390),
      (HtmlCanvas c) {
        c.fillStyle = '#1e90ff'; c.fillRect(100, 380, 80, 50); c.fillRect(140, 350, 40, 30);
      }
    ),
    Difference(
      'siloRoofColor',
      const Rect.fromLTWH(595.0, 95.0, 110.0, 60.0),
      const Offset(650, 125),
      (HtmlCanvas c) {
        c.fillStyle = '#b22222'; c.beginPath(); c.arc(650, 150, 50, math.pi, 0); c.fill();
      }
    ),
    Difference(
      'fencePostMissing',
      const Rect.fromLTWH(475.0, 475.0, 20.0, 60.0),
      const Offset(485, 500),
      (HtmlCanvas c) {
        c.fillStyle = '#2e8b57'; c.fillRect(480, 480, 10, 50);
        c.fillStyle = '#8b4513'; 
        c.fillRect(475, 490, 20, 8); c.fillRect(475, 510, 20, 8);
      }
    ),
    Difference(
      'extraCloud',
      const Rect.fromLTWH(300.0, 60.0, 90.0, 60.0),
      const Offset(340, 90),
      (HtmlCanvas c) {
        c.fillStyle = '#ffffff';
        c.beginPath(); c.arc(320, 90, 20, 0, math.pi*2); c.fill();
        c.beginPath(); c.arc(340, 80, 25, 0, math.pi*2); c.fill();
        c.beginPath(); c.arc(360, 90, 20, 0, math.pi*2); c.fill();
        c.fillRect(320, 90, 40, 20);
      }
    )
  ];
}
