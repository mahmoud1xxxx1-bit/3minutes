
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../html_canvas.dart';
import '../puzzle_model.dart';

class Puzzle17 extends PuzzleDefinition {
  @override
  int get id => 17;



  @override
  void drawBaseScene(HtmlCanvas c) {
    
    c.fillStyle = '#8a949b'; c.fillRect(0,0,800,600);
    c.strokeStyle = '#758087'; c.lineWidth = 2;
    for(double y=0; y<600; y+=40) {
        for(double x=0; x<800; x+=40) {
            c.strokeRect(x, y, 40, 40);
            if((x+y)%80 == 0) { c.fillStyle = '#929ca3'; c.fillRect(x+2,y+2,36,36); }
        }
    }
    void drawHedgeBlock(cx, cy, w, h) {
        c.fillStyle = '#1e3f28'; c.beginPath(); c.roundRect(cx-w/2, cy-h/2, w, h, 20); c.fill();
        c.fillStyle = '#2d5c3a'; c.beginPath(); c.roundRect(cx-w/2+5, cy-h/2+5, w-10, h-10, 15); c.fill();
        c.fillStyle = '#4c8f5e'; 
        double idx = 0;
        for(double y=cy-h/2+15; y<=cy+h/2-15; y+=15) {
            for(double x=cx-w/2+15; x<=cx+w/2-15; x+=15) {
                idx++;
                if(idx%3 != 0) { c.beginPath(); c.arc(x, y, 6, 0, math.pi*2); c.fill(); }
            }
        }
    }
    drawHedgeBlock(150, 150, 200, 200); 
    drawHedgeBlock(650, 150, 200, 200); 
    drawHedgeBlock(150, 450, 200, 200); 
    drawHedgeBlock(650, 450, 200, 200); 
    void drawFlowers(cx, cy, color1, color2) {
        c.fillStyle = '#3a251a'; c.beginPath(); c.arc(cx, cy, 35, 0, math.pi*2); c.fill(); 
        for(double a=0; a<math.pi*2; a+=math.pi/4) {
            c.fillStyle = color1; c.beginPath(); c.arc(cx+math.cos(a)*20, cy+math.sin(a)*20, 8, 0, math.pi*2); c.fill();
            c.fillStyle = color2; c.beginPath(); c.arc(cx+math.cos(a+math.pi/8)*12, cy+math.sin(a+math.pi/8)*12, 6, 0, math.pi*2); c.fill();
        }
    }
    drawFlowers(300, 150, '#d14949', '#f4d03f');
    drawFlowers(500, 150, '#8a2b3b', '#eef6ff');
    drawFlowers(300, 450, '#5baad4', '#f4d03f');
    drawFlowers(500, 450, '#d4af37', '#d14949');
    c.fillStyle = '#e2e2e2'; c.beginPath(); c.arc(400, 300, 120, 0, math.pi*2); c.fill(); 
    c.fillStyle = '#a4b4c0'; c.beginPath(); c.arc(400, 300, 110, 0, math.pi*2); c.fill(); 
    final waterGrad = c.createRadialGradient(400, 300, 0, 400, 300, 100);
    waterGrad..addColorStop(0, '#5baad4'); waterGrad..addColorStop(1, '#2b4f60');
    c.fillStyle = waterGrad; c.beginPath(); c.arc(400, 300, 100, 0, math.pi*2); c.fill(); 
    c.strokeStyle = 'rgba(255,255,255,0.4)'; c.lineWidth = 2;
    for(double r=20; r<=90; r+=20) { c.beginPath(); c.arc(400, 300, r, 0, math.pi*2); c.stroke(); }
    c.fillStyle = '#e2e2e2'; c.beginPath(); c.arc(400, 300, 40, 0, math.pi*2); c.fill(); 
    c.fillStyle = '#5baad4'; c.beginPath(); c.arc(400, 300, 30, 0, math.pi*2); c.fill(); 
    c.fillStyle = '#e2e2e2'; c.beginPath(); c.arc(400, 300, 15, 0, math.pi*2); c.fill(); 
    c.fillStyle = '#eef6ff';
    for(double i=0.0; i<12; i++) {
        double a = i*math.pi/6;
        c.beginPath(); c.arc(400+math.cos(a)*20, 300+math.sin(a)*20, 4, 0, math.pi*2); c.fill();
        c.beginPath(); c.arc(400+math.cos(a+0.2)*45, 300+math.sin(a+0.2)*45, 3, 0, math.pi*2); c.fill();
    }
    void drawStatue(cx, cy) {
        c.fillStyle = 'rgba(0,0,0,0.3)'; c.beginPath(); c.arc(cx+5, cy+5, 12, 0, math.pi*2); c.fill(); 
        c.fillStyle = '#a4b4c0'; c.fillRect(cx-15, cy-15, 30, 30); 
        c.fillStyle = '#d4af37'; c.beginPath(); c.arc(cx, cy, 12, 0, math.pi*2); c.fill(); 
        c.fillStyle = '#f4d03f'; c.beginPath(); c.arc(cx-3, cy-3, 4, 0, math.pi*2); c.fill(); 
    }
    drawStatue(400, 130); drawStatue(400, 470); drawStatue(230, 300); drawStatue(570, 300);

  }

  @override
  List<Difference> get differences => [
    
    Difference(
      'flowerColor',
      const Rect.fromLTWH(292.0, 162.0, 16.0, 16.0),
      const Offset(300, 170),
      (HtmlCanvas c) {
        
        c.fillStyle = '#c15886'; c.beginPath(); c.arc(300, 170, 8, 0, math.pi*2); c.fill();
    
      }
    ),
    Difference(
      'statueSilver',
      const Rect.fromLTWH(388.0, 458.0, 24.0, 24.0),
      const Offset(400, 470),
      (HtmlCanvas c) {
        
        c.fillStyle = '#a4b4c0'; c.beginPath(); c.arc(400, 470, 12, 0, math.pi*2); c.fill(); 
        c.fillStyle = '#eef6ff'; c.beginPath(); c.arc(397, 467, 4, 0, math.pi*2); c.fill(); 
    
      }
    ),
    Difference(
      'extraWaterDrop',
      const Rect.fromLTWH(445.0, 255.0, 10.0, 10.0),
      const Offset(450, 260),
      (HtmlCanvas c) {
        
        c.fillStyle = '#eef6ff'; c.beginPath(); c.arc(450, 260, 5, 0, math.pi*2); c.fill();
    
      }
    ),
    Difference(
      'pavingStoneColor',
      const Rect.fromLTWH(400.0, 80.0, 40, 40),
      const Offset(420, 100),
      (HtmlCanvas c) {
        
        c.fillStyle = '#4a2f20'; c.fillRect(402, 82, 36, 36);
    
      }
    ),
    Difference(
      'hedgeBerry',
      const Rect.fromLTWH(652.0, 452.0, 16.0, 16.0),
      const Offset(660, 460),
      (HtmlCanvas c) {
        
        c.fillStyle = '#d14949'; c.beginPath(); c.arc(660, 460, 8, 0, math.pi*2); c.fill();
    
      }
    )
  ];
}
