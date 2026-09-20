
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../html_canvas.dart';
import '../puzzle_model.dart';

class Puzzle03 extends PuzzleDefinition {
  @override
  int get id => 3;



  @override
  void drawBaseScene(HtmlCanvas c) {
    
    // Walls & Floor
    c.fillStyle = '#e8efe9'; c.fillRect(0,0,800,600);
    c.fillStyle = '#a5b2bc'; c.fillRect(0,450,800,150); // Carpet
    // Window
    c.fillStyle = '#87ceeb'; c.fillRect(500,80,220,160);
    c.fillStyle = '#5baad4'; c.fillRect(520,180,30,60); c.fillRect(560,150,40,90); c.fillRect(620,120,40,120); // City
    c.strokeStyle = '#5a3d2b'; c.lineWidth = 8; c.strokeRect(500,80,220,160); c.beginPath(); c.moveTo(610,80); c.lineTo(610,240); c.stroke();
    // Bookshelf
    c.fillStyle = '#5a3d2b'; c.fillRect(80, 80, 160, 240);
    c.fillStyle = '#3a251a'; c.fillRect(90, 90, 140, 220);
    c.fillStyle = '#5a3d2b'; c.fillRect(80, 150, 160, 10); c.fillRect(80, 230, 160, 10);
    // Books
    c.fillStyle = '#d14949'; c.fillRect(100, 110, 15, 40); c.fillRect(200, 190, 15, 40);
    c.fillStyle = '#4c8f5e'; c.fillRect(120, 100, 20, 50); c.fillRect(170, 190, 15, 40);
    c.fillStyle = '#2b4f60'; c.fillRect(145, 115, 15, 35); c.fillRect(100, 180, 20, 50);
    // Desk
    c.fillStyle = '#b8915e'; c.fillRect(250, 350, 350, 20); // Table top
    c.fillRect(270, 370, 20, 130); c.fillRect(560, 370, 20, 130); // Legs
    // Computer
    c.fillStyle = '#222'; c.fillRect(360, 240, 140, 90); // Monitor
    c.fillStyle = '#fff'; c.fillRect(365, 245, 130, 80); // Screen
    c.fillStyle = '#444'; c.fillRect(410, 330, 40, 20); // Stand
    c.fillStyle = '#e2e2e2'; c.fillRect(340, 360, 120, 15); // Keyboard
    c.fillRect(480, 360, 20, 15); // Mouse
    // Pen Holder & Coffee
    c.fillStyle = '#c15886'; c.fillRect(280, 320, 20, 30); // Holder
    c.strokeStyle = '#d4af37'; c.lineWidth = 3; c.beginPath(); c.moveTo(285,320); c.lineTo(280,300); c.stroke(); // Pen
    c.fillStyle = '#e2e2e2'; c.fillRect(550, 320, 25, 30); // Mug
    // Office Chair
    c.fillStyle = '#2b4f60'; c.beginPath(); c.roundRect(380, 380, 80, 15, 5); c.fill(); // Seat
    c.beginPath(); c.roundRect(400, 270, 40, 100, 10); c.fill(); // Back
    c.fillRect(415, 395, 10, 50); // Cylinder
    c.fillStyle = '#222'; c.beginPath(); c.arc(390, 450, 10, 0, math.pi*2); c.arc(450, 450, 10, 0, math.pi*2); c.fill(); // Wheels
    // Trash Can
    c.fillStyle = '#6a7c8c'; c.fillRect(650, 400, 40, 60);
    // Clock
    c.fillStyle = '#fff'; c.beginPath(); c.arc(380, 120, 30, 0, math.pi*2); c.fill();
    c.strokeStyle = '#222'; c.lineWidth = 4; c.stroke();
    c.beginPath(); c.moveTo(380, 120); c.lineTo(380, 100); c.lineTo(395, 120); c.stroke();

  }

  @override
  List<Difference> get differences => [
    
    Difference(
      'extraBook',
      const Rect.fromLTWH(170.0, 110.0, 40, 40),
      const Offset(190, 130),
      (HtmlCanvas c) {
         c.fillStyle = '#d4af37'; c.fillRect(185, 110, 15, 40); 
      }
    ),
    Difference(
      'mouseColor',
      const Rect.fromLTWH(470.0, 347.0, 40, 40),
      const Offset(490, 367),
      (HtmlCanvas c) {
         c.fillStyle = '#444'; c.fillRect(480, 360, 20, 15); 
      }
    ),
    Difference(
      'clockTime',
      const Rect.fromLTWH(350.0, 90.0, 60.0, 60.0),
      const Offset(380, 120),
      (HtmlCanvas c) {
        
        c.fillStyle='#fff'; c.beginPath(); c.arc(380,120,30,0,math.pi*2); c.fill();
        c.strokeStyle='#222'; c.lineWidth = 4; c.stroke();
        c.beginPath(); c.moveTo(380,120); c.lineTo(380,100); c.moveTo(380,120); c.lineTo(365,120); c.stroke();
    
      }
    ),
    Difference(
      'trashCanStripe',
      const Rect.fromLTWH(650.0, 395.0, 40, 40),
      const Offset(670, 415),
      (HtmlCanvas c) {
        
        c.fillStyle = '#2b4f60'; c.fillRect(650, 410, 40, 10); // إضافة خط (شريط) داكن لسلة المهملات
    
      }
    ),
    Difference(
      'windowBuildingMissing',
      const Rect.fromLTWH(515.0, 190.0, 40, 40),
      const Offset(535, 210),
      (HtmlCanvas c) {
        
        c.fillStyle = '#87ceeb'; c.fillRect(520,180,30,60); // draw sky over building
        // إعادة رسم إطار الدريشة حتى لا يظهر مقطوعاً (Glitch fix)
        c.strokeStyle = '#5a3d2b'; c.lineWidth = 8; c.strokeRect(500,80,220,160);
    
      }
    )
  ];
}
