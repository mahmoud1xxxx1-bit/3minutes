
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../html_canvas.dart';
import '../puzzle_model.dart';

class Puzzle18 extends PuzzleDefinition {
  @override
  int get id => 18;



  @override
  void drawBaseScene(HtmlCanvas c) {
    
    c.fillStyle = '#1b2c49'; c.fillRect(0,0,800,600); 
    c.strokeStyle = '#2b4f60'; c.lineWidth = 10;
    c.beginPath(); c.arc(400, 300, 380, math.pi, 0); c.stroke(); 
    for(double r=100; r<=300; r+=100) { c.beginPath(); c.arc(400, 300, r, math.pi, 0); c.stroke(); }
    for(double a=math.pi; a<=math.pi*2; a+=math.pi/6) { c.beginPath(); c.moveTo(400,300); c.lineTo(400+math.cos(a)*380, 300+math.sin(a)*380); c.stroke(); }
    c.fillStyle = '#3a251a'; c.fillRect(0, 450, 800, 150);
    c.fillStyle = '#4a2f20'; c.fillRect(0, 450, 800, 20); 
    c.strokeStyle = '#2a1a12'; c.lineWidth = 2;
    for(double x=0; x<800; x+=60) { c.beginPath(); c.moveTo(x, 470); c.lineTo(x-40, 600); c.stroke(); }
    for(double y=470; y<=600; y+=30) { c.beginPath(); c.moveTo(0, y); c.lineTo(800, y); c.stroke(); }
    c.fillStyle = '#111'; c.fillRect(0, 420, 800, 30); 
    c.fillStyle = '#a4b4c0'; c.fillRect(0, 430, 800, 5); c.fillRect(0, 440, 800, 5); 
    c.fillStyle = '#111'; c.fillRect(100, 200, 500, 220); 
    c.fillStyle = '#8a2b3b'; c.fillRect(100, 250, 500, 100); 
    c.fillStyle = '#d4af37'; c.fillRect(100, 250, 500, 10); c.fillRect(100, 340, 500, 10); 
    c.fillRect(300, 200, 20, 220); c.fillRect(450, 200, 20, 220); 
    c.fillStyle = '#8a2b3b'; c.fillRect(0, 150, 150, 270);
    c.fillStyle = '#eef6ff'; c.fillRect(20, 180, 50, 60); c.fillRect(80, 180, 50, 60); 
    c.fillStyle = '#111'; c.beginPath(); c.moveTo(550, 200); c.lineTo(530, 100); c.lineTo(610, 100); c.lineTo(590, 200); c.fill();
    c.fillStyle = 'rgba(255,255,255,0.4)';
    c.beginPath(); c.arc(570, 70, 30, 0, math.pi*2); c.arc(610, 40, 40, 0, math.pi*2); c.arc(670, 20, 50, 0, math.pi*2); c.fill();
    void drawWheel(cx, cy, r) {
        c.fillStyle = '#d4af37'; c.beginPath(); c.arc(cx, cy, r, 0, math.pi*2); c.fill();
        c.fillStyle = '#111'; c.beginPath(); c.arc(cx, cy, r-10, 0, math.pi*2); c.fill();
        c.strokeStyle = '#d4af37'; c.lineWidth = 6;
        for(double a=0; a<math.pi*2; a+=math.pi/4) { c.beginPath(); c.moveTo(cx,cy); c.lineTo(cx+math.cos(a)*(r-10), cy+math.sin(a)*(r-10)); c.stroke(); }
        c.fillStyle = '#e2e2e2'; c.beginPath(); c.arc(cx, cy, 15, 0, math.pi*2); c.fill();
    }
    drawWheel(250, 420, 60); drawWheel(400, 420, 60); drawWheel(550, 420, 60);
    c.fillStyle = '#a4b4c0'; c.fillRect(250, 410, 300, 20);
    c.fillStyle = '#111'; c.beginPath(); c.arc(250, 420, 8, 0, math.pi*2); c.arc(400, 420, 8, 0, math.pi*2); c.arc(550, 420, 8, 0, math.pi*2); c.fill();
    c.fillStyle = '#222'; c.beginPath(); c.arc(700, 150, 60, 0, math.pi*2); c.fill(); 
    c.fillStyle = '#fff'; c.beginPath(); c.arc(700, 150, 50, 0, math.pi*2); c.fill(); 
    c.fillStyle = '#111';
    for(double a=0; a<math.pi*2; a+=math.pi/6) { c.beginPath(); c.arc(700+math.cos(a)*40, 150+math.sin(a)*40, 3, 0, math.pi*2); c.fill(); }
    c.lineWidth = 4; c.lineCap = 'round';
    c.beginPath(); c.moveTo(700, 150); c.lineTo(700, 120); c.stroke(); 
    c.beginPath(); c.moveTo(700, 150); c.lineTo(730, 150); c.stroke(); 

  }

  @override
  List<Difference> get differences => [
    
    Difference(
      'clockTime',
      const Rect.fromLTWH(650.0, 100.0, 100.0, 100.0),
      const Offset(700, 165),
      (HtmlCanvas c) {
        
        c.fillStyle = '#fff'; c.beginPath(); c.arc(700, 150, 50, 0, math.pi*2); c.fill(); 
        c.fillStyle = '#111';
        for(double a=0; a<math.pi*2; a+=math.pi/6) { c.beginPath(); c.arc(700+math.cos(a)*40, 150+math.sin(a)*40, 3, 0, math.pi*2); c.fill(); }
        c.lineWidth = 4; c.lineCap = 'round';
        c.beginPath(); c.moveTo(700, 150); c.lineTo(700, 120); c.stroke(); 
        c.beginPath(); c.moveTo(700, 150); c.lineTo(700, 180); c.stroke(); 
    
      }
    ),
    Difference(
      'trainWindowColor',
      const Rect.fromLTWH(25.0, 190.0, 40, 40),
      const Offset(45, 210),
      (HtmlCanvas c) {
        
        c.fillStyle = '#1b2c49'; c.fillRect(20, 180, 50, 60); 
    
      }
    ),
    Difference(
      'extraSmoke',
      const Rect.fromLTWH(485.0, 5.0, 70.0, 70.0),
      const Offset(520, 40),
      (HtmlCanvas c) {
        
        c.fillStyle = 'rgba(255,255,255,0.4)'; c.beginPath(); c.arc(520, 40, 35, 0, math.pi*2); c.fill();
    
      }
    ),
    Difference(
      'wheelCenterColor',
      const Rect.fromLTWH(385.0, 405.0, 30.0, 30.0),
      const Offset(400, 420),
      (HtmlCanvas c) {
        
        c.fillStyle = '#d14949'; c.beginPath(); c.arc(400, 420, 15, 0, math.pi*2); c.fill();
        c.fillStyle = '#111'; c.beginPath(); c.arc(400, 420, 8, 0, math.pi*2); c.fill();
    
      }
    ),
    Difference(
      'platformLuggage',
      const Rect.fromLTWH(120.0, 520.0, 40, 40),
      const Offset(140, 540),
      (HtmlCanvas c) {
        
        c.fillStyle = '#4a2f20'; c.beginPath(); c.roundRect(110, 520, 60, 40, 5); c.fill();
        c.fillStyle = '#222'; c.fillRect(110, 535, 60, 5);
    
      }
    )
  ];
}
