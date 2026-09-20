import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../html_canvas.dart';
import '../puzzle_model.dart';

class Puzzle45 extends PuzzleDefinition {
  @override
  int get id => 45;

  void drawPlane(HtmlCanvas c, double x, double y, double scale, String tailColor) {
    c.save(); c.translate(x, y); c.scale(scale, scale);
    
    // Shadow
    c.fillStyle = 'rgba(0,0,0,0.2)'; c.beginPath(); c.ellipse(0, 30, 80, 20, 0, 0, math.pi*2); c.fill();
    
    // Wings
    c.fillStyle = '#cfd8dc';
    c.beginPath(); c.moveTo(-20, 0); c.lineTo(-80, 40); c.lineTo(-80, 50); c.lineTo(-20, 20); c.fill(); // Left wing
    c.beginPath(); c.moveTo(20, 0); c.lineTo(80, 40); c.lineTo(80, 50); c.lineTo(20, 20); c.fill(); // Right wing
    
    // Engines
    c.fillStyle = '#90a4ae'; c.fillRect(-60, 30, 15, 25); c.fillRect(45, 30, 15, 25);

    // Body
    c.fillStyle = '#ffffff';
    c.beginPath(); c.ellipse(0, 0, 25, 100, 0, 0, math.pi*2); c.fill();
    
    // Cockpit
    c.fillStyle = '#1e88e5';
    c.beginPath(); c.ellipse(0, -70, 15, 10, 0, 0, math.pi*2); c.fill();
    
    // Tail
    c.fillStyle = tailColor;
    c.beginPath(); c.moveTo(-5, 70); c.lineTo(-25, 120); c.lineTo(25, 120); c.lineTo(5, 70); c.fill();
    
    // Wing Lights
    c.fillStyle = '#f44336'; c.beginPath(); c.arc(-80, 45, 3, 0, math.pi*2); c.fill();
    c.fillStyle = '#4caf50'; c.beginPath(); c.arc(80, 45, 3, 0, math.pi*2); c.fill();

    c.restore();
  }

  void drawLuggageCart(HtmlCanvas c, double x, double y, int bags) {
    c.save(); c.translate(x, y);
    c.fillStyle = '#ffb300'; c.fillRect(0, 0, 40, 15); // Cart base
    c.fillStyle = '#424242'; c.beginPath(); c.arc(10, 15, 5, 0, math.pi*2); c.fill(); // Wheels
    c.beginPath(); c.arc(30, 15, 5, 0, math.pi*2); c.fill();
    
    List<String> bagColors = ['#e53935', '#1e88e5', '#43a047', '#8e24aa'];
    for(int i=0; i<bags; i++) {
      c.fillStyle = bagColors[i%4];
      c.fillRect(2 + i*8, -12, 10, 12);
    }
    c.restore();
  }

  @override
  void drawBaseScene(HtmlCanvas c) {
    // Sky
    c.fillStyle = '#64b5f6'; c.fillRect(0, 0, 800, 200);
    // Ground (Tarmac)
    c.fillStyle = '#9e9e9e'; c.fillRect(0, 200, 800, 400);

    // Clouds
    c.fillStyle = '#ffffff';
    c.beginPath(); c.arc(150, 80, 30, 0, math.pi*2); c.arc(180, 70, 40, 0, math.pi*2); c.arc(210, 90, 25, 0, math.pi*2); c.fill();
    // Specific cloud to modify: 600, 100
    c.beginPath(); c.arc(580, 100, 30, 0, math.pi*2); c.arc(620, 90, 45, 0, math.pi*2); c.arc(660, 110, 30, 0, math.pi*2); c.fill();

    // Runway markings
    c.fillStyle = '#ffffff';
    for(int i=0; i<15; i++) {
      c.fillRect(390, 220 + i*40, 20, 20); // Center dashed line
    }
    // Mark to remove: i=10 -> y=620 wait, 220 + 400 = 620 offscreen. i=8 -> 220+320 = 540.
    c.fillRect(390, 540, 20, 20); // Target dash

    // Edge lines
    c.fillStyle = '#ffb300';
    c.beginPath(); c.moveTo(300, 200); c.lineTo(50, 600); c.lineTo(60, 600); c.lineTo(310, 200); c.fill();
    c.beginPath(); c.moveTo(500, 200); c.lineTo(750, 600); c.lineTo(740, 600); c.lineTo(490, 200); c.fill();

    // Planes
    drawPlane(c, 400, 350, 1.2, '#1565c0'); // Main plane
    drawPlane(c, 150, 250, 0.5, '#d32f2f'); // Background plane left
    drawPlane(c, 650, 260, 0.6, '#00796b'); // Background plane right (Target for tail color)

    // Luggage Carts
    for(int i=0; i<3; i++) {
      drawLuggageCart(c, 100 + i*50, 500, 4);
    }
    // Target cart: 100 + 100 = 200, 500. Currently 4 bags.
  }

  @override
  List<Difference> get differences => [
    Difference(
      'runwayDashMissing',
      const Rect.fromLTWH(380, 530, 40, 40),
      const Offset(400, 550),
      (HtmlCanvas c) {
        c.fillStyle = '#9e9e9e'; // Tarmac color
        c.fillRect(380, 530, 40, 40); // Erase dash
      }
    ),
    Difference(
      'luggageBagMissing',
      const Rect.fromLTWH(220, 480, 25, 25), // 200+24 = 224
      const Offset(230, 490),
      (HtmlCanvas c) {
        c.fillStyle = '#9e9e9e'; // Erase one bag (i=3 -> 2 + 24 = 26)
        c.fillRect(200 + 26, 500 - 12, 10, 12);
      }
    ),
    Difference(
      'distantPlaneTailColor',
      const Rect.fromLTWH(630, 280, 40, 40),
      const Offset(650, 310), // y = 260 + 0.6 * (70 to 120) = 260 + 42 to 72 = 302 to 332
      (HtmlCanvas c) {
        c.save(); c.translate(650, 260); c.scale(0.6, 0.6);
        c.fillStyle = '#f57f17'; // Orange instead of teal
        c.beginPath(); c.moveTo(-5, 70); c.lineTo(-25, 120); c.lineTo(25, 120); c.lineTo(5, 70); c.fill();
        c.restore();
      }
    ),
    Difference(
      'mainPlaneWingLightMissing',
      const Rect.fromLTWH(290, 390, 30, 30), // x = 400 - 80*1.2 = 304, y = 350 + 45*1.2 = 404
      const Offset(304, 404),
      (HtmlCanvas c) {
        c.fillStyle = '#cfd8dc'; // Wing color
        c.beginPath(); c.arc(304, 404, 6, 0, math.pi*2); c.fill(); // Erase red light
      }
    ),
    Difference(
      'cloudShapeAltered',
      const Rect.fromLTWH(630, 60, 60, 60),
      const Offset(660, 90),
      (HtmlCanvas c) {
        c.fillStyle = '#64b5f6'; // Sky color
        c.fillRect(630, 60, 80, 80); // Erase right part of cloud
        c.fillStyle = '#ffffff';
        // Redraw right part differently (smaller, higher)
        c.beginPath(); c.arc(650, 80, 20, 0, math.pi*2); c.fill();
      }
    )
  ];
}
