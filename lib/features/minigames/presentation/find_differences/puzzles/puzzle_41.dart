import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../html_canvas.dart';
import '../puzzle_model.dart';

class Puzzle41 extends PuzzleDefinition {
  @override
  int get id => 41;

  @override
  void drawBaseScene(HtmlCanvas c) {
    // Dark grimy background
    c.fillStyle = '#1c1411';
    c.fillRect(0, 0, 800, 600);

    // Large Boiler
    final boiler = c.createLinearGradient(100, 0, 400, 0);
    boiler..addColorStop(0, '#3e2723')..addColorStop(0.5, '#5d4037')..addColorStop(1, '#3e2723');
    c.fillStyle = boiler;
    c.fillRect(100, 100, 300, 400);
    
    // Boiler Rivets
    c.fillStyle = '#1b100e';
    for(int i=0; i<8; i++) {
      c.beginPath(); c.arc(115, 120 + i*50, 4, 0, math.pi*2); c.fill();
      c.beginPath(); c.arc(385, 120 + i*50, 4, 0, math.pi*2); c.fill();
    }

    // Furnace Door
    c.fillStyle = '#212121';
    c.beginPath(); c.arc(250, 380, 80, 0, math.pi*2); c.fill();
    // Glowing Embers
    c.fillStyle = '#ff3d00'; c.beginPath(); c.arc(230, 400, 15, 0, math.pi*2); c.fill();
    c.fillStyle = '#ff9100'; c.beginPath(); c.arc(270, 410, 10, 0, math.pi*2); c.fill();
    c.fillStyle = '#dd2c00'; c.beginPath(); c.arc(250, 390, 20, 0, math.pi*2); c.fill(); // Ember to change
    
    // Pipes
    c.fillStyle = '#424242';
    c.fillRect(400, 200, 250, 40); // Horizontal pipe
    c.fillRect(610, 200, 40, 300); // Vertical pipe down
    
    // Pipe Flanges
    c.fillStyle = '#616161';
    c.fillRect(380, 190, 30, 60);
    c.fillRect(595, 190, 70, 60); // Corner flange
    c.fillRect(595, 450, 70, 30);
    
    // Flange Bolts
    c.fillStyle = '#212121';
    c.beginPath(); c.arc(395, 200, 4, 0, math.pi*2); c.fill();
    c.beginPath(); c.arc(395, 240, 4, 0, math.pi*2); c.fill(); // Bolt to remove
    c.beginPath(); c.arc(610, 205, 4, 0, math.pi*2); c.fill();
    c.beginPath(); c.arc(650, 205, 4, 0, math.pi*2); c.fill();

    // Valve Wheel
    c.strokeStyle = '#d32f2f';
    c.lineWidth = 10;
    c.beginPath(); c.arc(520, 220, 40, 0, math.pi*2); c.stroke();
    // Spokes
    c.lineWidth = 6;
    for(int i=0; i<6; i++) {
      double a = i * math.pi/3;
      c.beginPath(); c.moveTo(520, 220); c.lineTo(520 + math.cos(a)*40, 220 + math.sin(a)*40); c.stroke();
    }
    c.fillStyle = '#b71c1c'; c.beginPath(); c.arc(520, 220, 12, 0, math.pi*2); c.fill();

    // Gauge
    c.fillStyle = '#fff';
    c.beginPath(); c.arc(250, 180, 40, 0, math.pi*2); c.fill();
    c.strokeStyle = '#fbc02d'; c.lineWidth = 8;
    c.beginPath(); c.arc(250, 180, 40, 0, math.pi*2); c.stroke();
    c.strokeStyle = '#000'; c.lineWidth = 2;
    for(int i=0; i<9; i++) {
      double a = math.pi + i*math.pi/8;
      c.beginPath(); c.moveTo(250 + math.cos(a)*30, 180 + math.sin(a)*30); c.lineTo(250 + math.cos(a)*40, 180 + math.sin(a)*40); c.stroke();
    }
    // Needle
    c.strokeStyle = '#d32f2f'; c.lineWidth = 4;
    c.beginPath(); c.moveTo(250, 180); c.lineTo(250 + math.cos(math.pi*1.3)*30, 180 + math.sin(math.pi*1.3)*30); c.stroke();
    c.fillStyle = '#000'; c.beginPath(); c.arc(250, 180, 6, 0, math.pi*2); c.fill();

    // Steam
    c.fillStyle = 'rgba(236, 239, 241, 0.4)';
    c.beginPath(); c.arc(630, 120, 40, 0, math.pi*2); c.fill();
    c.beginPath(); c.arc(670, 90, 50, 0, math.pi*2); c.fill(); // Steam puff to move
    c.beginPath(); c.arc(710, 110, 30, 0, math.pi*2); c.fill();
  }

  @override
  List<Difference> get differences => [
    Difference(
      'emberColor',
      const Rect.fromLTWH(220, 360, 60, 60),
      const Offset(250, 390),
      (HtmlCanvas c) {
        c.fillStyle = '#ff3d00'; // Lighter color instead of deep red
        c.beginPath(); c.arc(250, 390, 20, 0, math.pi*2); c.fill();
      }
    ),
    Difference(
      'missingBolt',
      const Rect.fromLTWH(380, 220, 30, 40),
      const Offset(395, 240),
      (HtmlCanvas c) {
        c.fillStyle = '#616161';
        c.fillRect(390, 235, 10, 10); // Paint over bolt
      }
    ),
    Difference(
      'valveSpokeMissing',
      const Rect.fromLTWH(470, 170, 100, 100),
      const Offset(520, 220),
      (HtmlCanvas c) {
        c.fillStyle = '#424242'; c.fillRect(470, 170, 100, 100); // Erase wheel area
        c.strokeStyle = '#d32f2f'; c.lineWidth = 10;
        c.beginPath(); c.arc(520, 220, 40, 0, math.pi*2); c.stroke();
        c.lineWidth = 6;
        for(int i=0; i<6; i++) {
          if (i==3) continue; // Skip one spoke
          double a = i * math.pi/3;
          c.beginPath(); c.moveTo(520, 220); c.lineTo(520 + math.cos(a)*40, 220 + math.sin(a)*40); c.stroke();
        }
        c.fillStyle = '#b71c1c'; c.beginPath(); c.arc(520, 220, 12, 0, math.pi*2); c.fill();
      }
    ),
    Difference(
      'gaugeNeedleAngle',
      const Rect.fromLTWH(210, 140, 80, 80),
      const Offset(250, 180),
      (HtmlCanvas c) {
        c.fillStyle = '#fff'; c.beginPath(); c.arc(250, 180, 38, 0, math.pi*2); c.fill(); // Erase needle
        c.strokeStyle = '#000'; c.lineWidth = 2;
        for(int i=0; i<9; i++) {
          double a = math.pi + i*math.pi/8;
          c.beginPath(); c.moveTo(250 + math.cos(a)*30, 180 + math.sin(a)*30); c.lineTo(250 + math.cos(a)*38, 180 + math.sin(a)*38); c.stroke();
        }
        c.strokeStyle = '#d32f2f'; c.lineWidth = 4;
        c.beginPath(); c.moveTo(250, 180); c.lineTo(250 + math.cos(math.pi*1.6)*30, 180 + math.sin(math.pi*1.6)*30); c.stroke(); // Different angle
        c.fillStyle = '#000'; c.beginPath(); c.arc(250, 180, 6, 0, math.pi*2); c.fill();
      }
    ),
    Difference(
      'steamPuffMoved',
      const Rect.fromLTWH(600, 30, 160, 130),
      const Offset(670, 90),
      (HtmlCanvas c) {
        c.fillStyle = '#1c1411'; c.fillRect(600, 30, 160, 130); // Erase steam
        c.fillStyle = 'rgba(236, 239, 241, 0.4)';
        c.beginPath(); c.arc(630, 120, 40, 0, math.pi*2); c.fill();
        c.beginPath(); c.arc(680, 70, 50, 0, math.pi*2); c.fill(); // Shifted up and right
        c.beginPath(); c.arc(710, 110, 30, 0, math.pi*2); c.fill();
      }
    )
  ];
}
