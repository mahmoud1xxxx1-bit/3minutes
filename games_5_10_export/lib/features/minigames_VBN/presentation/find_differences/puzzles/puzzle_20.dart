
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../html_canvas.dart';
import '../puzzle_model.dart';

class Puzzle20 extends PuzzleDefinition {
  @override
  int get id => 20;



  @override
  void drawBaseScene(HtmlCanvas c) {
    
    c.fillStyle = '#eef6ff'; c.fillRect(0,0,800,300);
    c.strokeStyle = '#c7d6d1'; c.lineWidth = 2;
    for(double i=-300; i<=1100; i+=40) {
        c.beginPath(); c.moveTo(i, 0); c.lineTo(i+300, 300); c.stroke();
        c.beginPath(); c.moveTo(i, 300); c.lineTo(i+300, 0); c.stroke();
    }
    c.fillStyle = '#3a251a'; c.fillRect(550, 40, 200, 150);
    c.fillStyle = '#111'; c.fillRect(560, 50, 180, 130);
    c.fillStyle = '#fff'; c.font = '16px monospace';
    c.fillText('MENU', 630, 70);
    c.font = '12px monospace';
    c.fillText('Croissant....\$3', 570, 100);
    c.fillText('Cake.........\$5', 570, 120);
    c.fillText('Baguette.....\$2', 570, 140);
    c.fillStyle = '#4a2f20'; c.fillRect(0, 300, 800, 300); 
    c.fillStyle = '#2a1a12'; c.fillRect(0, 280, 800, 20); 
    c.fillStyle = '#111'; c.fillRect(50, 320, 600, 250); 
    c.fillStyle = 'rgba(255,255,255,0.2)'; c.fillRect(50, 320, 600, 250); 
    void drawShelf(double y) {
        c.fillStyle = '#e2e2e2'; c.fillRect(50, y, 600, 10);
        c.fillStyle = 'rgba(255,255,255,0.8)'; c.fillRect(50, y, 600, 2);
    }
    drawShelf(380); drawShelf(460); drawShelf(550);
    for(double i=0.0; i<8; i++) {
        double cx = 100 + i*65, cy = 360;
        c.fillStyle = '#d4af37'; 
        c.beginPath(); c.arc(cx, cy, 18, math.pi, 0); c.fill();
        c.fillStyle = '#111'; c.beginPath(); c.arc(cx, cy, 12, math.pi, 0); c.fill(); 
        c.fillStyle = '#d4af37'; c.beginPath(); c.ellipse(cx, cy-5, 20, 10, 0, math.pi, 0); c.fill();
    }
    for(double i=0.0; i<6; i++) {
        double cx = 120 + i*90, cy = 440;
        c.fillStyle = '#4a2f20'; c.fillRect(cx-25, cy-30, 50, 30); 
        c.fillStyle = '#8a2b3b'; c.fillRect(cx-25, cy-15, 50, 5); 
        c.fillStyle = '#fff'; c.beginPath(); c.ellipse(cx, cy-30, 25, 10, 0, 0, math.pi*2); c.fill(); 
        c.fillStyle = '#d14949'; c.beginPath(); c.arc(cx, cy-35, 6, 0, math.pi*2); c.fill(); 
    }
    for(double i=0.0; i<5; i++) {
        double cx = 130 + i*110, cy = 520;
        c.fillStyle = '#a67c52'; c.fillRect(cx-40, cy-10, 80, 20);
        c.strokeStyle = '#4a2f20'; c.lineWidth = 2; c.strokeRect(cx-40, cy-10, 80, 20);
        c.fillStyle = '#d4af37'; c.beginPath(); c.roundRect(cx-30, cy-50, 20, 50, 10); c.fill();
        c.beginPath(); c.roundRect(cx, cy-60, 20, 60, 10); c.fill();
        c.strokeStyle = '#8a2b3b'; c.lineWidth = 2;
        c.beginPath(); c.moveTo(cx-25, cy-40); c.lineTo(cx-15, cy-35); c.stroke();
        c.beginPath(); c.moveTo(cx+5, cy-45); c.lineTo(cx+15, cy-40); c.stroke();
    }
    c.fillStyle = '#a4b4c0'; c.fillRect(680, 220, 80, 60);
    c.fillStyle = '#111'; c.fillRect(690, 230, 60, 20);
    c.fillStyle = '#55ffae'; c.font = '14px monospace'; c.fillText('\$12.50', 695, 233);
    c.fillStyle = '#e2e2e2'; c.fillRect(690, 260, 15, 10); c.fillRect(710, 260, 15, 10); c.fillRect(730, 260, 15, 10);
    c.strokeStyle = '#e2e2e2'; c.lineWidth = 4; c.strokeRect(50, 320, 600, 250);

  }

  @override
  List<Difference> get differences => [
    
    Difference(
      'cakeCherryMissing',
      const Rect.fromLTWH(280.0, 385.0, 40, 40),
      const Offset(300, 405),
      (HtmlCanvas c) {
        
        c.fillStyle = '#fff'; c.beginPath(); c.ellipse(300, 440-30, 25, 10, 0, 0, math.pi*2); c.fill(); 
        c.fillStyle = 'rgba(255,255,255,0.2)'; c.fillRect(50, 320, 600, 250);
    
      }
    ),
    Difference(
      'menuPrice',
      const Rect.fromLTWH(670.0, 95.0, 40, 40),
      const Offset(690, 115),
      (HtmlCanvas c) {
        
        c.fillStyle = '#111'; c.fillRect(680, 110, 20, 15);
        c.fillStyle = '#fff'; c.font = '12px monospace'; c.fillText('9', 683, 120);
    
      }
    ),
    Difference(
      'burntCroissant',
      const Rect.fromLTWH(405.0, 335.0, 40, 40),
      const Offset(425, 355),
      (HtmlCanvas c) {
        
        double cx = 425, cy = 360;
        c.fillStyle = '#4a2f20'; 
        c.beginPath(); c.arc(cx, cy, 18, math.pi, 0); c.fill();
        c.fillStyle = '#111'; c.beginPath(); c.arc(cx, cy, 12, math.pi, 0); c.fill(); 
        c.fillStyle = '#4a2f20'; c.beginPath(); c.ellipse(cx, cy-5, 20, 10, 0, math.pi, 0); c.fill();
        c.fillStyle = 'rgba(255,255,255,0.2)'; c.fillRect(50, 320, 600, 250);
    
      }
    ),
    Difference(
      'extraBaguette',
      const Rect.fromLTWH(135.0, 460.0, 40, 40),
      const Offset(155, 480),
      (HtmlCanvas c) {
        
        double cx = 150, cy = 520; 
        c.fillStyle = '#d4af37'; c.beginPath(); c.roundRect(cx, cy-55, 15, 55, 10); c.fill();
        c.strokeStyle = '#8a2b3b'; c.lineWidth = 2; c.beginPath(); c.moveTo(cx+2, cy-40); c.lineTo(cx+12, cy-35); c.stroke();
        c.fillStyle = 'rgba(255,255,255,0.2)'; c.fillRect(50, 320, 600, 250);
    
      }
    ),
    Difference(
      'registerColor',
      const Rect.fromLTWH(700.0, 220.0, 40, 40),
      const Offset(720, 240),
      (HtmlCanvas c) {
        
        c.fillStyle = '#111'; c.fillRect(690, 230, 60, 20); 
        c.fillStyle = '#ff5555'; c.font = '14px monospace'; c.fillText('\$12.50', 695, 245);
    
      }
    )
  ];
}
