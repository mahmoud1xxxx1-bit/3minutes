
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../html_canvas.dart';
import '../puzzle_model.dart';

class Puzzle25 extends PuzzleDefinition {
  @override
  int get id => 25;



  @override
  void drawBaseScene(HtmlCanvas c) {
    
    c.fillStyle = '#2a1a12'; c.fillRect(0,0,800,600);
    c.strokeStyle = '#1e1108'; c.lineWidth = 4;
    for(double y=0; y<600; y+=80) {
        c.beginPath(); c.moveTo(0, y); c.lineTo(800, y+ (math.sin(y)*20)); c.stroke();
    }
    c.fillStyle = '#4a2f20'; c.beginPath(); c.roundRect(180, 380, 440, 160, 10); c.fill(); 
    c.fillStyle = '#f4d03f'; c.fillRect(395, 370, 10, 180); 
    c.fillStyle = '#eef6ff'; c.beginPath(); c.roundRect(200, 390, 195, 140, 5); c.fill(); 
    c.beginPath(); c.roundRect(405, 390, 195, 140, 5); c.fill(); 
    c.shadowBlur = 10; c.shadowColor = '#55ffae'; c.strokeStyle = '#2b4f60'; c.lineWidth = 3;
    for(double i=0.0; i<8; i++) {
        double x = 220 + (i%4)*40; double y = 420 + (i/4)*50;
        c.beginPath(); c.moveTo(x, y); c.lineTo(x+15, y+20); c.lineTo(x+30, y); c.stroke();
        c.beginPath(); c.moveTo(x+15, y+5); c.lineTo(x+15, y+25); c.stroke();
    }
    c.shadowColor = '#ff55a3'; c.strokeStyle = '#8a2b3b';
    for(double i=0.0; i<8; i++) {
        double x = 420 + (i%4)*40; double y = 420 + (i/4)*50;
        c.beginPath(); c.arc(x+15, y+10, 10, 0, math.pi); c.stroke();
        c.beginPath(); c.moveTo(x+5, y+10); c.lineTo(x+25, y+10); c.stroke();
    }
    c.shadowBlur = 0;
    c.fillStyle = '#d4af37'; c.beginPath(); c.ellipse(400, 200, 80, 30, 0, 0, math.pi*2); c.fill(); 
    c.fillStyle = 'rgba(20,20,40,0.9)'; c.beginPath(); c.arc(400, 150, 100, 0, math.pi*2); c.fill(); 
    c.strokeStyle = '#ff00ff'; c.lineWidth = 4; c.shadowBlur = 15; c.shadowColor = '#00ffff';
    c.beginPath();
    for(double i=0.0; i<30; i++) {
        double a = i*0.5; double r = i*3;
        if(i==0) c.moveTo(400, 150);
        else c.lineTo(400+math.cos(a)*r, 150+math.sin(a)*r);
    }
    c.stroke();
    c.fillStyle = '#fff';
    for(double i=0.0; i<20; i++) {
        double a = i*2.1; double r = (i*13)%90;
        c.beginPath(); c.arc(400+math.cos(a)*r, 150+math.sin(a)*r, 2, 0, math.pi*2); c.fill();
    }
    c.shadowBlur = 0;
    void drawCard(cx, cy, rot) {
        c.save(); c.translate(cx, cy); c.rotate(rot);
        c.fillStyle = '#e2e2e2'; c.beginPath(); c.roundRect(-30, -50, 60, 100, 5); c.fill();
        c.strokeStyle = '#d4af37'; c.lineWidth = 2; c.strokeRect(-25, -45, 50, 90);
        c.fillStyle = '#8a2b3b'; c.beginPath(); c.arc(0, -10, 15, 0, math.pi*2); c.fill(); 
        c.restore();
    }
    drawCard(100, 200, -0.2); drawCard(140, 220, 0.1); drawCard(110, 270, -0.5);
    void drawPotion(cx, cy, color) {
        c.fillStyle = 'rgba(255,255,255,0.3)'; c.beginPath(); c.moveTo(cx-15, cy-40); c.lineTo(cx+15, cy-40); c.lineTo(cx+30, cy+20); c.lineTo(cx-30, cy+20); c.fill(); 
        c.fillStyle = color; c.shadowBlur = 20; c.shadowColor=color;
        c.beginPath(); c.moveTo(cx-20, cy-10); c.lineTo(cx+20, cy-10); c.lineTo(cx+28, cy+18); c.lineTo(cx-28, cy+18); c.fill(); 
        c.shadowBlur = 0;
        c.fillStyle = '#a67c52'; c.fillRect(cx-12, cy-50, 24, 15); 
    }
    drawPotion(700, 150, '#55ffae'); drawPotion(630, 220, '#ffaa00'); drawPotion(730, 280, '#ff55a3');

  }

  @override
  List<Difference> get differences => [
    
    Difference(
      'runeColor',
      const Rect.fromLTWH(215.0, 410.0, 40, 40),
      const Offset(235, 430),
      (HtmlCanvas c) {
        
        double x = 220; double y = 420;
        c.fillStyle = '#eef6ff'; c.fillRect(x-5, y-5, 40, 40); // erase
        c.shadowBlur = 10; c.shadowColor = '#00ffff'; c.strokeStyle = '#00ffff'; c.lineWidth = 3;
        c.beginPath(); c.moveTo(x, y); c.lineTo(x+15, y+20); c.lineTo(x+30, y); c.stroke();
        c.beginPath(); c.moveTo(x+15, y+5); c.lineTo(x+15, y+25); c.stroke();
        c.shadowBlur = 0;
    
      }
    ),
    Difference(
      'extraCard',
      const Rect.fromLTWH(60.0, 330.0, 40, 40),
      const Offset(80, 350),
      (HtmlCanvas c) {
        
        double cx = 80, cy = 350, rot = 0.3;
        c.save(); c.translate(cx, cy); c.rotate(rot);
        c.fillStyle = '#e2e2e2'; c.beginPath(); c.roundRect(-30, -50, 60, 100, 5); c.fill();
        c.strokeStyle = '#d4af37'; c.lineWidth = 2; c.strokeRect(-25, -45, 50, 90);
        c.fillStyle = '#8a2b3b'; c.beginPath(); c.arc(0, -10, 15, 0, math.pi*2); c.fill(); 
        c.restore();
    
      }
    ),
    Difference(
      'extraStar',
      const Rect.fromLTWH(420.0, 80.0, 40, 40),
      const Offset(440, 100),
      (HtmlCanvas c) {
        
        c.fillStyle = '#ffaa00'; c.shadowBlur = 15; c.shadowColor = '#ffaa00';
        c.beginPath(); c.moveTo(440, 80); c.lineTo(445, 95); c.lineTo(460, 95); c.lineTo(448, 105); c.lineTo(452, 120); c.lineTo(440, 110); c.lineTo(428, 120); c.lineTo(432, 105); c.lineTo(420, 95); c.lineTo(435, 95); c.closePath(); c.fill();
        c.shadowBlur = 0;
    
      }
    ),
    Difference(
      'potionSpill',
      const Rect.fromLTWH(580.0, 220.0, 40, 40),
      const Offset(600, 240),
      (HtmlCanvas c) {
        
        c.fillStyle = '#ffaa00'; c.shadowBlur = 10; c.shadowColor = '#ffaa00';
        c.beginPath(); c.ellipse(600, 240, 20, 8, 0, 0, math.pi*2); c.fill();
        c.shadowBlur = 0;
    
      }
    ),
    Difference(
      'goldCoin',
      const Rect.fromLTWH(680.0, 480.0, 40, 40),
      const Offset(700, 500),
      (HtmlCanvas c) {
        
        c.fillStyle = '#d4af37'; c.beginPath(); c.ellipse(700, 500, 15, 8, 0, 0, math.pi*2); c.fill();
        c.fillStyle = '#f4d03f'; c.beginPath(); c.ellipse(700, 498, 12, 6, 0, 0, math.pi*2); c.fill();
    
      }
    )
  ];
}
