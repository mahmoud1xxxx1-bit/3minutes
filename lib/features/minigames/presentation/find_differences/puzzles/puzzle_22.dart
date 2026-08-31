
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../html_canvas.dart';
import '../puzzle_model.dart';

class Puzzle22 extends PuzzleDefinition {
  @override
  int get id => 22;


  void drawGear(HtmlCanvas c, double cx, double cy, double r, dynamic teeth, String color) {

    c.fillStyle = color; c.strokeStyle = '#111'; c.lineWidth = 2;
    c.beginPath();
    for(double i=0.0; i<teeth*2; i++) {
        double a = i*math.pi/teeth;
        double rad = (i%2==0) ? r : r+10;
        if(i==0) {
          c.moveTo(cx+math.cos(a)*rad, cy+math.sin(a)*rad);
        } else {
          c.lineTo(cx+math.cos(a)*rad, cy+math.sin(a)*rad);
        }
    }
    c.closePath(); c.fill(); c.stroke();
    c.fillStyle = '#1e1108'; c.beginPath(); c.arc(cx, cy, r-15, 0, math.pi*2); c.fill(); c.stroke();
    c.fillStyle = color;
    for(double i=0.0; i<5; i++) {
        double a = i*math.pi*2/5;
        c.beginPath(); c.moveTo(cx, cy);
        c.lineTo(cx+math.cos(a-0.1)*(r-15), cy+math.sin(a-0.1)*(r-15));
        c.lineTo(cx+math.cos(a+0.1)*(r-15), cy+math.sin(a+0.1)*(r-15));
        c.fill(); c.stroke();
    }
    c.fillStyle = '#a4b4c0'; c.beginPath(); c.arc(cx, cy, 8, 0, math.pi*2); c.fill(); c.stroke();

  }


  @override
  void drawBaseScene(HtmlCanvas c) {
    
    c.fillStyle = '#1e1108'; c.fillRect(0,0,800,600);
    c.strokeStyle = '#2a180d'; c.lineWidth = 2;
    for(double x=0; x<800; x+=4) {
        c.beginPath(); c.moveTo(x, 0); c.lineTo(x + math.sin(x/50)*20, 600); c.stroke();
    }
    final bronze = '#b87333', gold = '#d4af37', iron = '#7b8b9a', brass = '#c9a15a';
    drawGear(c, 100, 100, 60, 16, bronze);
    drawGear(c, 210, 130, 40, 12, iron);
    drawGear(c, 290, 80, 50, 14, gold);
    drawGear(c, 500, 150, 90, 24, brass);
    drawGear(c, 650, 200, 50, 14, iron);
    drawGear(c, 150, 450, 120, 30, bronze);
    drawGear(c, 350, 500, 80, 20, iron);
    drawGear(c, 500, 400, 60, 16, gold);
    drawGear(c, 700, 480, 100, 26, brass);
    for(double i=0.0; i<15; i++) {
        double gx = 50 + (i*83)%700; double gy = 50 + (i*113)%500;
        drawGear(c, gx, gy, 20, 8, [bronze,gold,iron,brass][(i%4).toInt()]);
    }
    c.fillStyle = '#fff'; c.beginPath(); c.arc(400, 250, 100, 0, math.pi*2); c.fill(); c.stroke();
    c.strokeStyle = '#d4af37'; c.lineWidth = 10; c.beginPath(); c.arc(400, 250, 100, 0, math.pi*2); c.stroke();
    c.fillStyle = '#111'; c.font = '24px serif'; c.textAlign = 'center'; c.textBaseline = 'middle';
    for(double i=1.0; i<=12; i++) {
        double a = i*math.pi/6 - math.pi/2;
        c.fillText(['I','II','III','IV','V','VI','VII','VIII','IX','X','XI','XII'][(i-1).toInt()], 400+math.cos(a)*80, 250+math.sin(a)*80);
    }
    c.lineWidth = 4; c.lineCap = 'round'; c.strokeStyle = '#111';
    c.beginPath(); c.moveTo(400, 250); c.lineTo(400+math.cos(-math.pi/4)*50, 250+math.sin(-math.pi/4)*50); c.stroke(); 
    c.beginPath(); c.moveTo(400, 250); c.lineTo(400+math.cos(math.pi/6)*80, 250+math.sin(math.pi/6)*80); c.stroke(); 
    c.fillStyle = '#d4af37'; c.beginPath(); c.arc(400, 250, 6, 0, math.pi*2); c.fill();
    c.lineWidth = 2; c.strokeStyle = '#a4b4c0';
    c.beginPath(); c.moveTo(400, 350); c.lineTo(400, 500); c.stroke();
    c.fillStyle = '#d4af37'; c.beginPath(); c.arc(400, 520, 30, 0, math.pi*2); c.fill(); c.stroke();

  }

  @override
  List<Difference> get differences => [
    
    Difference(
      'pendulumColor',
      const Rect.fromLTWH(370.0, 490.0, 60.0, 60.0),
      const Offset(400, 520),
      (HtmlCanvas c) {
        
        c.fillStyle = '#a4b4c0'; c.beginPath(); c.arc(400, 520, 30, 0, math.pi*2); c.fill(); c.stroke();
    
      }
    ),
    Difference(
      'extraGearBottomRight',
      const Rect.fromLTWH(660.0, 530.0, 40, 40),
      const Offset(680, 550),
      (HtmlCanvas c) {
        
        drawGear(c, 680, 550, 25, 10, '#b87333');
    
      }
    ),
    Difference(
      'extraChain',
      const Rect.fromLTWH(330.0, 400.0, 40, 40),
      const Offset(350, 420),
      (HtmlCanvas c) {
        
        c.lineWidth = 2; c.strokeStyle = '#a4b4c0';
        c.beginPath(); c.moveTo(350, 350); c.lineTo(350, 500); c.stroke();
    
      }
    ),
    Difference(
      'clockHand',
      const Rect.fromLTWH(305.0, 155.0, 190.0, 190.0),
      const Offset(400, 300),
      (HtmlCanvas c) {
        
        c.fillStyle = '#fff'; c.beginPath(); c.arc(400, 250, 95, 0, math.pi*2); c.fill(); 
        c.fillStyle = '#111'; c.font = '24px serif'; c.textAlign = 'center'; c.textBaseline = 'middle';
        for(double i=1.0; i<=12; i++) {
            double a = i*math.pi/6 - math.pi/2;
            c.fillText(['I','II','III','IV','V','VI','VII','VIII','IX','X','XI','XII'][(i-1).toInt()], 400+math.cos(a)*80, 250+math.sin(a)*80);
        }
        c.lineWidth = 4; c.lineCap = 'round'; c.strokeStyle = '#111';
        c.beginPath(); c.moveTo(400, 250); c.lineTo(400+math.cos(-math.pi/4)*50, 250+math.sin(-math.pi/4)*50); c.stroke(); 
        c.beginPath(); c.moveTo(400, 250); c.lineTo(400, 330); c.stroke(); // pointing down
        c.fillStyle = '#d4af37'; c.beginPath(); c.arc(400, 250, 6, 0, math.pi*2); c.fill();
    
      }
    ),
    Difference(
      'extraSmallGear',
      const Rect.fromLTWH(580.0, 80.0, 40, 40),
      const Offset(600, 100),
      (HtmlCanvas c) {
        
        drawGear(c, 600, 100, 20, 8, '#d4af37');
    
      }
    )
  ];
}
