
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../html_canvas.dart';
import '../puzzle_model.dart';

class Puzzle06 extends PuzzleDefinition {
  @override
  int get id => 6;

  @override
  void drawBaseScene(HtmlCanvas c) {
    
    // Sky
    c.fillStyle = '#87ceeb'; c.fillRect(0,0,800,250);
    // Sun
    c.fillStyle = '#d4af37'; c.beginPath(); c.arc(700, 100, 50, 0, math.pi*2); c.fill();
    // Sea
    c.fillStyle = '#5baad4'; c.fillRect(0,250,800,100);
    c.strokeStyle = '#e8efe9'; c.lineWidth = 2;
    c.beginPath(); c.moveTo(100, 280); c.lineTo(200, 280); c.moveTo(500, 310); c.lineTo(650, 310); c.stroke();
    // Sand
    c.fillStyle = '#e4c49d'; c.fillRect(0,350,800,250);
    c.beginPath(); c.ellipse(400, 350, 400, 30, 0, 0, math.pi*2); c.fill(); // Curve
    // Umbrella
    c.fillStyle = '#a5b2bc'; c.fillRect(245, 350, 10, 120); // Pole
    c.fillStyle = '#d14949'; c.beginPath(); c.arc(250, 350, 100, math.pi, math.pi*2); c.fill();
    c.fillStyle = '#e8efe9'; c.beginPath(); c.moveTo(250, 250); c.lineTo(280, 350); c.lineTo(220, 350); c.fill(); // Stripe
    // Towel
    c.fillStyle = '#4c8f5e'; c.fillRect(180, 480, 140, 60);
    c.fillStyle = '#e8efe9'; c.fillRect(190, 480, 10, 60); c.fillRect(300, 480, 10, 60);
    // Sandcastle
    c.fillStyle = '#d4b48c'; c.fillRect(550, 400, 80, 60); c.fillRect(560, 370, 20, 30); c.fillRect(600, 370, 20, 30);
    // Crab
    c.fillStyle = '#d14949'; c.beginPath(); c.ellipse(650, 520, 20, 15, 0, 0, math.pi*2); c.fill();
    // Palm Tree
    c.strokeStyle = '#5a3d2b'; c.lineWidth = 20; c.beginPath(); c.moveTo(50, 600); c.quadraticCurveTo(120, 400, 80, 200); c.stroke();
    c.fillStyle = '#4c8f5e';
    c.beginPath(); c.ellipse(80, 150, 80, 20, math.pi/4, 0, math.pi*2); c.fill();
    c.beginPath(); c.ellipse(130, 220, 80, 20, -math.pi/4, 0, math.pi*2); c.fill();
    c.beginPath(); c.ellipse(20, 220, 80, 20, math.pi/4, 0, math.pi*2); c.fill();
  }

  @override
  List<Difference> get differences => [
    
    Difference(
      'towelStripMissing',
      const Rect.fromLTWH(175.0, 490.0, 40, 40),
      const Offset(195, 510),
      (HtmlCanvas c) {
         c.fillStyle = '#4c8f5e'; c.fillRect(190, 480, 10, 60); 
      }
    ),
    Difference(
      'sandcastleTowerMissing',
      const Rect.fromLTWH(550.0, 365.0, 40, 40),
      const Offset(570, 385),
      (HtmlCanvas c) {
        
        c.fillStyle = '#e4c49d'; c.fillRect(555, 365, 30, 35); // مسح البرج
        c.fillStyle = '#d4b48c'; c.fillRect(550, 400, 80, 60); // إعادة رسم القاعدة لمنع التقطيع (Glitch fix)
    
      }
    ),
    Difference(
      'crabColor',
      const Rect.fromLTWH(630.0, 500.0, 40, 40),
      const Offset(650, 520),
      (HtmlCanvas c) {
        
        c.fillStyle = '#5baad4'; // تحويل لون السلطعون إلى أزرق
        c.beginPath(); c.ellipse(650, 520, 20, 15, 0, 0, math.pi*2); c.fill();
    
      }
    ),
    Difference(
      'waveExtra',
      const Rect.fromLTWH(380.0, 280.0, 40, 40),
      const Offset(400, 300),
      (HtmlCanvas c) {
        
        c.strokeStyle = '#e8efe9'; c.lineWidth = 2; c.beginPath(); c.moveTo(350, 300); c.lineTo(450, 300); c.stroke();
    
      }
    ),
    Difference(
      'sunRay',
      const Rect.fromLTWH(595.0, 80.0, 40, 40),
      const Offset(615, 100),
      (HtmlCanvas c) {
        
        c.strokeStyle = '#d4af37'; c.lineWidth = 4; 
        c.beginPath(); c.moveTo(630, 100); c.lineTo(600, 100); c.stroke();
    
      }
    )
  ];
}
