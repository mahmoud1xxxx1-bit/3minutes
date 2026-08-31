
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../html_canvas.dart';
import '../puzzle_model.dart';

class Puzzle14 extends PuzzleDefinition {
  @override
  int get id => 14;



  @override
  void drawBaseScene(HtmlCanvas c) {
    
    final sky = c.createLinearGradient(0,0,0,400); sky.addColorStop(0, '#5baad4'); sky.addColorStop(1, '#eef6ff');
    c.fillStyle = sky; c.fillRect(0,0,800,400);
    c.fillStyle = '#1b2c49'; c.fillRect(0,350,800,250);
    c.fillStyle = '#2b4f60'; c.beginPath(); c.ellipse(400, 400, 500, 50, 0, 0, math.pi*2); c.fill();
    c.fillStyle = '#4a2f20'; c.fillRect(100, 400, 600, 200); 
    c.strokeStyle = '#2a1a12'; c.lineWidth = 4;
    for(double x=100; x<700; x+=60) { c.beginPath(); c.moveTo(x, 400); c.lineTo(x, 600); c.stroke(); }
    c.fillStyle = '#3a251a'; c.fillRect(0, 400, 100, 200); c.fillRect(700, 400, 100, 200); 
    c.fillStyle = '#2a1a12'; c.fillRect(380, 50, 40, 350); 
    c.fillRect(200, 150, 400, 20); 
    c.fillStyle = '#eef6ff'; c.beginPath(); c.moveTo(200, 170); c.quadraticCurveTo(400, 300, 600, 170); c.lineTo(500, 350); c.lineTo(300, 350); c.fill(); 
    c.strokeStyle = '#a4b4c0'; c.lineWidth = 4; c.stroke(); 
    c.fillStyle = '#111'; c.beginPath(); c.arc(400, 230, 20, 0, math.pi*2); c.fill();
    c.fillRect(380, 260, 40, 10); 
    c.save(); c.translate(400, 450);
    c.strokeStyle = '#a67c52'; c.lineWidth = 15; c.beginPath(); c.arc(0, 0, 60, 0, math.pi*2); c.stroke();
    for(double i=0.0; i<8; i++) {
        c.rotate(math.pi/4);
        c.fillStyle = '#a67c52'; c.fillRect(-10, -90, 20, 180); 
    }
    c.fillStyle = '#d4af37'; c.beginPath(); c.arc(0, 0, 20, 0, math.pi*2); c.fill();
    c.restore();
    c.fillStyle = '#222'; c.beginPath(); c.roundRect(550, 480, 120, 80, 10); c.fill(); 
    c.fillStyle = '#8a2b3b'; c.fillRect(560, 500, 100, 50); 
    c.fillStyle = '#d4af37'; c.fillRect(550, 490, 120, 15); c.fillRect(600, 500, 20, 30); 
    c.fillStyle = '#f4d03f';
    for(double i=0.0; i<15; i++) { c.beginPath(); c.arc(580+(i*21)%70, 485+(i*13)%15, 8, 0, math.pi*2); c.fill(); }
    c.fillStyle = '#222'; c.fillRect(120, 470, 80, 40); 
    c.fillStyle = '#111'; c.beginPath(); c.roundRect(140, 450, 100, 30, 15); c.fill(); 
    c.fillStyle = '#d14949'; c.beginPath(); c.arc(150, 490, 15, 0, math.pi*2); c.fill(); 

  }

  @override
  List<Difference> get differences => [
    
    Difference(
      'skyCloudMissing',
      const Rect.fromLTWH(120.0, 70.0, 60.0, 60.0),
      const Offset(150, 100),
      (HtmlCanvas c) {
        
        c.fillStyle = '#fff'; c.beginPath(); c.arc(150, 100, 30, 0, math.pi*2); c.arc(180, 110, 20, 0, math.pi*2); c.arc(120, 110, 20, 0, math.pi*2); c.fill(); 
    
      }
    ),
    Difference(
      'sailLogoColor',
      const Rect.fromLTWH(380.0, 210.0, 40.0, 40.0),
      const Offset(400, 230),
      (HtmlCanvas c) {
        
        c.fillStyle = '#d14949'; c.beginPath(); c.arc(400, 230, 20, 0, math.pi*2); c.fill();
    
      }
    ),
    Difference(
      'chestGoldMissing',
      const Rect.fromLTWH(625.0, 470.0, 40, 40),
      const Offset(645, 490),
      (HtmlCanvas c) {
        
        // Erase one specific coin cleanly by redrawing the wood box
        c.fillStyle = '#8a2b3b'; c.fillRect(640, 485, 12, 12); 
    
      }
    ),
    Difference(
      'helmCenterColor',
      const Rect.fromLTWH(380.0, 430.0, 40.0, 40.0),
      const Offset(400, 450),
      (HtmlCanvas c) {
        
        c.fillStyle = '#a4b4c0'; c.beginPath(); c.arc(400, 450, 20, 0, math.pi*2); c.fill();
    
      }
    ),
    Difference(
      'cannonWheelColor',
      const Rect.fromLTWH(135.0, 475.0, 30.0, 30.0),
      const Offset(150, 490),
      (HtmlCanvas c) {
        
        c.fillStyle = '#4c8f5e'; c.beginPath(); c.arc(150, 490, 15, 0, math.pi*2); c.fill();
    
      }
    )
  ];
}
