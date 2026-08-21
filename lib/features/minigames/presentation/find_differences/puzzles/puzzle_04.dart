
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../html_canvas.dart';
import '../puzzle_model.dart';

class Puzzle04 extends PuzzleDefinition {
  @override
  int get id => 4;



  @override
  void drawBaseScene(HtmlCanvas c) {
    
    math.Random seededRnd = math.Random(1);
    c.fillStyle = '#050914'; c.fillRect(0,0,800,600);
    c.fillStyle = '#fff';
    for(double i=0.0; i<40; i++) { c.beginPath(); c.arc(seededRnd.nextDouble()*800, seededRnd.nextDouble()*450, seededRnd.nextDouble()*2+1, 0, math.pi*2); c.fill(); }
    // Earth
    c.fillStyle = '#5baad4'; c.beginPath(); c.arc(650, 150, 80, 0, math.pi*2); c.fill();
    c.fillStyle = '#5c8a6b'; c.beginPath(); c.arc(620, 130, 25, 0, math.pi*2); c.arc(670, 170, 35, 0, math.pi*2); c.fill();
    // Moon Surface
    c.fillStyle = '#c0c8c3'; c.beginPath(); c.ellipse(400, 550, 500, 150, 0, 0, math.pi*2); c.fill();
    // Craters
    c.fillStyle = '#a5b2bc';
    c.beginPath(); c.ellipse(200, 480, 40, 15, 0, 0, math.pi*2); c.fill();
    c.beginPath(); c.ellipse(550, 520, 60, 20, 0, 0, math.pi*2); c.fill();
    c.beginPath(); c.ellipse(750, 460, 30, 10, 0, 0, math.pi*2); c.fill();
    // Rover
    c.fillStyle = '#e2e2e2'; c.fillRect(250, 380, 100, 50); // Body
    c.fillStyle = '#2b4f60'; c.fillRect(280, 340, 80, 30); // Solar Panel
    c.strokeStyle = '#aab2ad'; c.lineWidth = 4; c.beginPath(); c.moveTo(300,380); c.lineTo(320,340); c.stroke();
    c.fillStyle = '#222'; c.beginPath(); c.arc(270, 440, 20, 0, math.pi*2); c.arc(330, 440, 20, 0, math.pi*2); c.fill(); // Wheels
    // Rocket
    c.fillStyle = '#d14949';
    c.beginPath(); c.moveTo(100, 100); c.lineTo(130, 250); c.lineTo(70, 250); c.fill(); // Body
    c.fillStyle = '#e8efe9'; c.beginPath(); c.arc(100, 160, 12, 0, math.pi*2); c.fill(); // Window
    c.fillStyle = '#d4af37'; c.beginPath(); c.moveTo(85, 250); c.lineTo(115, 250); c.lineTo(100, 290); c.fill(); // Flame
    // Asteroid
    c.fillStyle = '#a5b2bc'; c.beginPath(); c.arc(400, 150, 25, 0, math.pi*2); c.fill();

  }

  @override
  List<Difference> get differences => [
    
    Difference(
      'extraStar',
      const Rect.fromLTWH(295.0, 95.0, 10.0, 10.0),
      const Offset(300, 100),
      (HtmlCanvas c) {
         c.fillStyle = '#fff'; c.beginPath(); c.arc(300,100,5,0,math.pi*2); c.fill(); 
      }
    ),
    Difference(
      'earthContinentMissing',
      const Rect.fromLTWH(594.0, 104.0, 52.0, 52.0),
      const Offset(620, 130),
      (HtmlCanvas c) {
        
        c.fillStyle = '#5baad4'; c.beginPath(); c.arc(620,130,26,0,math.pi*2); c.fill(); 
    
      }
    ),
    Difference(
      'roverWheelColor',
      const Rect.fromLTWH(262.0, 432.0, 16.0, 16.0),
      const Offset(270, 440),
      (HtmlCanvas c) {
        
        c.fillStyle = '#a4b4c0'; 
        c.beginPath(); c.arc(270, 440, 8, 0, math.pi*2); c.arc(330, 440, 8, 0, math.pi*2); c.fill();
    
      }
    ),
    Difference(
      'rocketFlameSize',
      const Rect.fromLTWH(80.0, 260.0, 40, 40),
      const Offset(100, 280),
      (HtmlCanvas c) {
        
        // لا نمسح هنا حتى لا نحذف النجوم في الخلفية! فقط نرسم ناراً أطول فوق القديمة
        c.fillStyle = '#d4af37'; c.beginPath(); c.moveTo(85, 250); c.lineTo(115, 250); c.lineTo(100, 310); c.fill();
    
      }
    ),
    Difference(
      'craterMissing',
      const Rect.fromLTWH(730.0, 440.0, 40, 40),
      const Offset(750, 460),
      (HtmlCanvas c) {
        
        c.fillStyle = '#c0c8c3'; c.beginPath(); c.ellipse(750, 460, 31, 11, 0, 0, math.pi*2); c.fill();
    
      }
    )
  ];
}
