
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../html_canvas.dart';
import '../puzzle_model.dart';

class Puzzle21 extends PuzzleDefinition {
  @override
  int get id => 21;



  @override
  void drawBaseScene(HtmlCanvas c) {
    
    c.fillStyle = '#4a4e59'; c.fillRect(0,0,800,450);
    c.strokeStyle = '#2d3038'; c.lineWidth = 3;
    for(double y=0; y<=450; y+=50) {
        c.beginPath(); c.moveTo(0, y); c.lineTo(800, y); c.stroke();
        double offset = (y%100 == 0) ? 0 : 40;
        for(double x=offset; x<=800; x+=80) {
            c.beginPath(); c.moveTo(x, y); c.lineTo(x, y+50); c.stroke();
        }
    }
    c.fillStyle = '#302d2b'; c.fillRect(0, 450, 800, 150);
    c.strokeStyle = '#1a1817';
    for(double y=450; y<=600; y+=25) {
        c.beginPath(); c.moveTo(0, y); c.lineTo(800, y); c.stroke();
        for(double x=(y%50==0?0:30); x<=800; x+=60) {
            c.beginPath(); c.moveTo(x, y); c.lineTo(x, y+25); c.stroke();
        }
    }
    c.fillStyle = '#6b4c42'; c.fillRect(20, 150, 260, 300); 
    c.fillRect(60, 0, 180, 150); 
    c.strokeStyle = '#3d2b25'; c.lineWidth = 2;
    for(double y=0; y<=450; y+=30) {
        c.beginPath(); c.moveTo(20, y); c.lineTo(280, y); c.stroke();
        for(double x=20+(y%60==0?0:20); x<=280; x+=40) {
            c.beginPath(); c.moveTo(x, y); c.lineTo(x, y+30); c.stroke();
        }
    }
    c.fillStyle = '#111'; c.beginPath(); c.arc(150, 350, 80, math.pi, 0); c.lineTo(230, 450); c.lineTo(70, 450); c.fill();
    final fireGrad = c.createRadialGradient(150, 400, 10, 150, 400, 70);
    fireGrad.addColorStop(0, '#fff6b0'); fireGrad.addColorStop(0.3, '#ffaa00'); fireGrad.addColorStop(1, '#ff0000');
    c.fillStyle = fireGrad; c.beginPath(); c.arc(150, 420, 60, math.pi, 0); c.fill();
    c.fillStyle = '#111'; 
    for(double i=0.0; i<15; i++) {
        c.beginPath(); c.arc(100+(i*17)%100, 430+(i*7)%20, 8, 0, math.pi*2); c.fill();
        c.fillStyle = '#ff3300'; c.beginPath(); c.arc(100+(i*17)%100, 430+(i*7)%20, 3, 0, math.pi*2); c.fill(); c.fillStyle='#111';
    }
    c.fillStyle = '#3a251a'; c.fillRect(550, 80, 200, 20); c.fillRect(550, 250, 200, 20); 
    c.fillRect(580, 60, 15, 230); c.fillRect(700, 60, 15, 230); 
    void drawSword(cx, cy) {
        c.fillStyle = '#a4b4c0'; 
        c.beginPath(); c.moveTo(cx-5, cy); c.lineTo(cx+5, cy); c.lineTo(cx+5, cy+100); c.lineTo(cx, cy+120); c.lineTo(cx-5, cy+100); c.fill();
        c.fillStyle = '#e2e2e2'; c.beginPath(); c.moveTo(cx, cy); c.lineTo(cx+5, cy); c.lineTo(cx+5, cy+100); c.lineTo(cx, cy+120); c.fill(); 
        c.fillStyle = '#d4af37'; c.fillRect(cx-15, cy-10, 30, 8); 
        c.fillStyle = '#222'; c.fillRect(cx-4, cy-40, 8, 30); 
        c.fillStyle = '#d4af37'; c.beginPath(); c.arc(cx, cy-45, 8, 0, math.pi*2); c.fill(); 
    }
    drawSword(580, 120);
    drawSword(645, 120);
    drawSword(710, 120);
    c.fillStyle = '#4a2f20'; c.beginPath(); c.ellipse(350, 460, 70, 20, 0, 0, math.pi*2); c.fill();
    c.fillRect(280, 460, 140, 60);
    c.fillStyle = '#2a1a12'; c.beginPath(); c.ellipse(350, 520, 70, 20, 0, 0, math.pi*2); c.fill();
    c.fillStyle = '#7b8b9a';
    c.beginPath(); c.moveTo(280, 440); c.lineTo(420, 440); c.lineTo(410, 390); c.lineTo(290, 390); c.fill(); 
    c.fillRect(320, 330, 60, 60); 
    c.beginPath(); c.moveTo(260, 330); c.lineTo(450, 330); c.lineTo(450, 300); c.lineTo(260, 300); c.fill(); 
    c.beginPath(); c.moveTo(260, 330); c.lineTo(260, 300); c.quadraticCurveTo(180, 300, 180, 320); c.fill();
    c.fillStyle = '#a4b4c0'; c.fillRect(260, 300, 190, 5);
    c.fillStyle = '#ff5500'; c.shadowBlur = 15; c.shadowColor = '#ff0000';
    c.beginPath(); c.moveTo(220, 315); c.lineTo(400, 315); c.lineTo(420, 320); c.lineTo(400, 325); c.lineTo(220, 325); c.fill();
    c.shadowBlur = 0;
    c.fillStyle = '#111'; c.fillRect(400, 310, 8, 30); 
    c.fillStyle = '#4a2f20'; c.save(); c.translate(450, 520); c.rotate(0.5);
    c.fillRect(0, 0, 80, 8); 
    c.fillStyle = '#7b8b9a'; c.fillRect(60, -10, 30, 28);
    c.restore();
    c.fillStyle = '#5c3a21'; c.beginPath(); c.ellipse(650, 460, 50, 15, 0, 0, math.pi*2); c.fill();
    c.fillRect(600, 460, 100, 80);
    c.fillStyle = '#3a251a'; c.beginPath(); c.ellipse(650, 540, 50, 15, 0, 0, math.pi*2); c.fill();
    c.strokeStyle = '#111'; c.lineWidth = 4;
    c.beginPath(); c.ellipse(650, 490, 50, 15, 0, 0, math.pi*2); c.stroke(); 
    c.beginPath(); c.ellipse(650, 520, 50, 15, 0, 0, math.pi*2); c.stroke();
    c.fillStyle = '#2b4f60'; c.beginPath(); c.ellipse(650, 460, 40, 10, 0, 0, math.pi*2); c.fill();
    c.fillStyle = '#5baad4'; c.beginPath(); c.ellipse(650, 460, 35, 8, 0, 0, math.pi*2); c.fill();

  }

  @override
  List<Difference> get differences => [
    
    Difference(
      'swordPommel',
      const Rect.fromLTWH(637.0, 67.0, 16.0, 16.0),
      const Offset(645, 75),
      (HtmlCanvas c) {
        
        c.fillStyle = '#ff3300'; c.beginPath(); c.arc(645, 75, 8, 0, math.pi*2); c.fill();
    
      }
    ),
    Difference(
      'magicalFire',
      const Rect.fromLTWH(90.0, 360.0, 120.0, 120.0),
      const Offset(150, 400),
      (HtmlCanvas c) {
        
        final fireGrad = c.createRadialGradient(150, 400, 10, 150, 400, 70);
        fireGrad.addColorStop(0, '#eef6ff'); fireGrad.addColorStop(0.3, '#55ffae'); fireGrad.addColorStop(1, '#00aa55');
        c.fillStyle = fireGrad; c.beginPath(); c.arc(150, 420, 60, math.pi, 0); c.fill();
        c.fillStyle = '#111'; 
        for(double i=0.0; i<15; i++) {
            c.beginPath(); c.arc(100+(i*17)%100, 430+(i*7)%20, 8, 0, math.pi*2); c.fill();
            c.fillStyle = '#55ffae'; c.beginPath(); c.arc(100+(i*17)%100, 430+(i*7)%20, 3, 0, math.pi*2); c.fill(); c.fillStyle='#111';
        }
    
      }
    ),
    Difference(
      'waterColor',
      const Rect.fromLTWH(630.0, 440.0, 40, 40),
      const Offset(650, 460),
      (HtmlCanvas c) {
        
        c.fillStyle = '#8a2b3b'; c.beginPath(); c.ellipse(650, 460, 40, 10, 0, 0, math.pi*2); c.fill();
        c.fillStyle = '#ff55a3'; c.beginPath(); c.ellipse(650, 460, 35, 8, 0, 0, math.pi*2); c.fill();
    
      }
    ),
    Difference(
      'horseshoe',
      const Rect.fromLTWH(298.0, 408.0, 24.0, 24.0),
      const Offset(310, 415),
      (HtmlCanvas c) {
        
        c.strokeStyle = '#d4af37'; c.lineWidth = 6; c.lineCap = 'round';
        c.beginPath(); c.arc(310, 420, 12, 0, math.pi); c.stroke();
        c.beginPath(); c.moveTo(298, 420); c.lineTo(298, 410); c.stroke();
        c.beginPath(); c.moveTo(322, 420); c.lineTo(322, 410); c.stroke();
    
      }
    ),
    Difference(
      'coolSword',
      const Rect.fromLTWH(280.0, 300.0, 40, 40),
      const Offset(300, 320),
      (HtmlCanvas c) {
        
        c.fillStyle = '#a4b4c0'; c.shadowBlur = 0; 
        c.beginPath(); c.moveTo(220, 315); c.lineTo(400, 315); c.lineTo(420, 320); c.lineTo(400, 325); c.lineTo(220, 325); c.fill();
        c.fillStyle = '#e2e2e2'; c.beginPath(); c.moveTo(220, 315); c.lineTo(400, 315); c.lineTo(420, 320); c.lineTo(220, 320); c.fill(); 
        c.fillStyle = '#111'; c.fillRect(400, 310, 8, 30); 
    
      }
    )
  ];
}
