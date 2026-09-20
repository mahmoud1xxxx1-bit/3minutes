import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../html_canvas.dart';
import '../puzzle_model.dart';

class Puzzle33 extends PuzzleDefinition {
  @override
  int get id => 33;

  @override
  void drawBaseScene(HtmlCanvas c) {
    // Deep forest bg
    final bg = c.createLinearGradient(0, 0, 0, 600);
    bg..addColorStop(0, '#0f380f')..addColorStop(1, '#051205');
    c.fillStyle = bg;
    c.fillRect(0, 0, 800, 600);

    // Tree trunks
    c.fillStyle = '#3e2723';
    c.fillRect(100, 0, 80, 600);
    c.fillRect(550, 0, 120, 600);

    // Bark texture (busy lines)
    c.strokeStyle = '#1b100e';
    c.lineWidth = 3;
    for (int i = 0; i < 40; i++) {
      c.beginPath();
      c.moveTo(110 + (i % 3) * 20, i * 15);
      c.lineTo(130 + (i % 2) * 20, i * 15 + 20);
      c.stroke();
      c.beginPath();
      c.moveTo(560 + (i % 4) * 25, i * 15);
      c.lineTo(590 + (i % 3) * 20, i * 15 + 30);
      c.stroke();
    }

    // Dense leaves
    void drawLeafCluster(double cx, double cy, String color) {
      c.fillStyle = color;
      for (int i = 0; i < 5; i++) {
        double a = i * math.pi * 2 / 5;
        c.beginPath();
        c.ellipse(cx + math.cos(a) * 20, cy + math.sin(a) * 20, 25, 10, a, 0, math.pi * 2);
        c.fill();
      }
    }

    for (int i = 0; i < 40; i++) {
      double x = (i * 87) % 800;
      double y = (i * 41) % 300;
      String color = (i % 3 == 0) ? '#1b5e20' : ((i % 3 == 1) ? '#2e7d32' : '#388e3c');
      drawLeafCluster(x, y, color);
    }

    // Vines
    c.strokeStyle = '#558b2f';
    c.lineWidth = 6;
    c.beginPath();
    c.moveTo(180, 100);
    c.quadraticCurveTo(350, 300, 550, 150);
    c.stroke();
    
    // Vine leaves
    c.fillStyle = '#7cb342';
    for (int i = 0; i < 10; i++) {
      double t = i / 10.0;
      double x = 180 * (1 - t)*(1 - t) + 2 * 350 * (1 - t) * t + 550 * t * t;
      double y = 100 * (1 - t)*(1 - t) + 2 * 300 * (1 - t) * t + 150 * t * t;
      c.beginPath(); c.arc(x, y, 8, 0, math.pi * 2); c.fill();
    }

    // Small hanging vine to flip
    c.beginPath(); c.moveTo(350, 200); c.quadraticCurveTo(320, 250, 360, 300); c.stroke();

    // Fireflies
    c.fillStyle = '#cddc39';
    for (int i = 0; i < 30; i++) {
      double x = (i * 113) % 800;
      double y = 200 + (i * 71) % 400;
      c.beginPath(); c.arc(x, y, 3, 0, math.pi * 2); c.fill();
      // Glow
      c.fillStyle = 'rgba(205, 220, 57, 0.2)';
      c.beginPath(); c.arc(x, y, 10, 0, math.pi * 2); c.fill();
      c.fillStyle = '#cddc39';
    }
    


    // Mushrooms at base
    c.fillStyle = '#d32f2f';
    c.beginPath(); c.arc(150, 550, 30, math.pi, 0); c.fill();
    c.fillStyle = '#fff';
    c.beginPath(); c.arc(135, 535, 4, 0, math.pi * 2); c.fill();
    c.beginPath(); c.arc(150, 525, 5, 0, math.pi * 2); c.fill();
    c.beginPath(); c.arc(165, 540, 4, 0, math.pi * 2); c.fill();
  }

  @override
  List<Difference> get differences => [
    Difference(
      'extraFirefly',
      const Rect.fromLTWH(380, 430, 40, 40),
      const Offset(400, 450),
      (HtmlCanvas c) {
        c.fillStyle = '#cddc39';
        c.beginPath(); c.arc(400, 450, 3, 0, math.pi * 2); c.fill();
        c.fillStyle = 'rgba(205, 220, 57, 0.2)';
        c.beginPath(); c.arc(400, 450, 10, 0, math.pi * 2); c.fill();
      }
    ),
    Difference(
      'leafColorShift',
      const Rect.fromLTWH(660, 20, 60, 60), // Cluster around 696, 41 (from i=8)
      const Offset(696, 41), // 8*87%800 = 696, 8*41%300 = 28. Wait, i=8: 696, 28
      (HtmlCanvas c) {
        // Redraw cluster with different color
        c.fillStyle = '#9ccc65'; // Lighter green
        for (int i = 0; i < 5; i++) {
          double a = i * math.pi * 2 / 5;
          c.beginPath();
          c.ellipse(696 + math.cos(a) * 20, 28 + math.sin(a) * 20, 25, 10, a, 0, math.pi * 2);
          c.fill();
        }
      }
    ),
        Difference(
      'extraVine',
      const Rect.fromLTWH(310, 190, 60, 120),
      const Offset(340, 250),
      (HtmlCanvas c) {
        c.strokeStyle = '#558b2f';
        c.lineWidth = 6;
        c.beginPath(); c.moveTo(350, 200); c.quadraticCurveTo(380, 250, 360, 300); c.stroke();
      }
    ),
    Difference(
      'mushroomSpots',
      const Rect.fromLTWH(115, 515, 70, 40),
      const Offset(150, 535),
      (HtmlCanvas c) {
        // Erase cap
        c.fillStyle = '#d32f2f';
        c.beginPath(); c.arc(150, 550, 30, math.pi, 0); c.fill();
        // New spots
        c.fillStyle = '#fff';
        c.beginPath(); c.arc(140, 525, 6, 0, math.pi * 2); c.fill();
        c.beginPath(); c.arc(160, 535, 6, 0, math.pi * 2); c.fill();
      }
    ),
    Difference(
      'missingBarkTexture',
      const Rect.fromLTWH(555, 300, 60, 60), // i=20 -> y=300
      const Offset(570, 315),
      (HtmlCanvas c) {
        c.fillStyle = '#3e2723'; // Trunk color
        c.fillRect(555, 295, 60, 40); // Hides the lines in this area
      }
    )
  ];
}
