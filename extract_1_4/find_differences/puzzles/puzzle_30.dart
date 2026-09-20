
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../html_canvas.dart';
import '../puzzle_model.dart';

class Puzzle30 extends PuzzleDefinition {
  @override
  int get id => 30;



  @override
  void drawBaseScene(HtmlCanvas c) {
    
    c.fillStyle = '#2a1a22'; c.fillRect(0,0,800,600);
    c.strokeStyle = '#1a0a12'; c.lineWidth = 3;
    for(double y=0; y<=600; y+=40) {
        c.beginPath(); c.moveTo(0, y); c.lineTo(800, y); c.stroke();
        double offset = (y%80 == 0) ? 0 : 30;
        for(double x=offset; x<=800; x+=60) {
            c.beginPath(); c.moveTo(x, y); c.lineTo(x, y+40); c.stroke();
        }
    }
    c.fillStyle = '#3a251a'; c.fillRect(50, 200, 700, 20); c.fillRect(50, 450, 700, 20);
    c.fillStyle = '#1a0a12'; c.beginPath(); c.moveTo(100, 220); c.lineTo(120, 220); c.lineTo(100, 260); c.fill(); c.beginPath(); c.moveTo(700, 220); c.lineTo(680, 220); c.lineTo(700, 260); c.fill();
    c.beginPath(); c.moveTo(100, 470); c.lineTo(120, 470); c.lineTo(100, 510); c.fill(); c.beginPath(); c.moveTo(700, 470); c.lineTo(680, 470); c.lineTo(700, 510); c.fill();
    c.fillStyle = '#00ffff'; c.shadowBlur = 15; c.shadowColor='#00ffff';
    c.beginPath(); c.arc(150, 160, 40, 0, math.pi*2); c.fill();
    c.fillRect(135, 80, 30, 50); c.shadowBlur = 0;
    c.fillStyle = 'rgba(255,255,255,0.2)'; c.beginPath(); c.arc(150, 160, 40, 0, math.pi*2); c.fill(); c.fillRect(135, 80, 30, 50);
    c.fillStyle = '#5c3a21'; c.fillRect(135, 70, 30, 10); 
    c.fillStyle = 'rgba(200,255,200,0.2)'; c.fillRect(300, 80, 60, 120); c.strokeStyle='#fff'; c.strokeRect(300, 80, 60, 120);
    c.fillStyle = '#a4b4c0'; c.fillRect(295, 70, 70, 10); 
    c.fillStyle = '#fff'; c.beginPath(); c.arc(330, 150, 15, 0, math.pi*2); c.fill();
    c.fillStyle = '#ff2222'; c.beginPath(); c.arc(330, 150, 6, 0, math.pi*2); c.fill(); 
    c.fillStyle = '#e2e2c2'; c.beginPath(); c.arc(500, 150, 30, 0, math.pi*2); c.fill(); c.fillRect(485, 170, 30, 30);
    c.fillStyle = '#111'; c.beginPath(); c.arc(490, 150, 8, 0, math.pi*2); c.fill(); c.beginPath(); c.arc(510, 150, 8, 0, math.pi*2); c.fill();
    c.beginPath(); c.moveTo(500, 165); c.lineTo(495, 175); c.lineTo(505, 175); c.fill();
    c.strokeStyle = '#111'; c.lineWidth = 2; for(double i=0.0; i<4; i++){ c.beginPath(); c.moveTo(485+i*8, 185); c.lineTo(485+i*8, 200); c.stroke(); }
    c.fillStyle = '#e2e2e2'; c.fillRect(650, 130, 20, 70);
    c.fillStyle = '#ffaa00'; c.shadowBlur = 20; c.shadowColor='#ffaa00'; c.beginPath(); c.arc(660, 115, 10, 0, math.pi*2); c.fill(); c.shadowBlur = 0;
    c.fillStyle = '#1a1a24'; c.beginPath(); c.ellipse(200, 380, 80, 70, 0, 0, math.pi*2); c.fill();
    c.fillStyle = '#55ffae'; c.shadowBlur = 20; c.shadowColor='#55ffae'; c.beginPath(); c.ellipse(200, 330, 60, 15, 0, 0, math.pi*2); c.fill(); c.shadowBlur = 0;
    c.fillStyle = '#55ffae'; c.beginPath(); c.arc(170, 300, 10, 0, math.pi*2); c.fill(); c.beginPath(); c.arc(220, 280, 15, 0, math.pi*2); c.fill(); 
    c.fillStyle = '#8a2b3b'; c.fillRect(450, 420, 120, 30); c.fillStyle='#fff'; c.fillRect(450, 430, 110, 10);
    c.fillStyle = '#2b4f60'; c.fillRect(460, 390, 100, 30); c.fillStyle='#fff'; c.fillRect(460, 400, 90, 10);
    c.fillStyle = '#4c8f5e'; c.fillRect(470, 360, 80, 30); c.fillStyle='#fff'; c.fillRect(470, 370, 70, 10);
    c.fillStyle = '#ff00ff'; c.shadowBlur = 20; c.shadowColor='#ff00ff';
    c.beginPath(); c.moveTo(650, 450); c.lineTo(620, 350); c.lineTo(650, 330); c.lineTo(680, 350); c.fill(); c.shadowBlur = 0;
    c.fillStyle = 'rgba(255,255,255,0.4)'; c.beginPath(); c.moveTo(650, 450); c.lineTo(620, 350); c.lineTo(650, 330); c.fill();

  }

  @override
  List<Difference> get differences => [
    
    Difference(
      'extraEyeball',
      const Rect.fromLTWH(315.0, 95.0, 30.0, 30.0),
      const Offset(330, 110),
      (HtmlCanvas c) {
        
        c.fillStyle = '#fff'; c.beginPath(); c.arc(330, 110, 15, 0, math.pi*2); c.fill();
        c.fillStyle = '#2222ff'; c.beginPath(); c.arc(330, 110, 6, 0, math.pi*2); c.fill(); 
        c.fillStyle = '#111'; c.beginPath(); c.arc(330, 110, 3, 0, math.pi*2); c.fill(); 
    
      }
    ),
    Difference(
      'goldTooth',
      const Rect.fromLTWH(493.0, 172.0, 40, 40),
      const Offset(513, 192),
      (HtmlCanvas c) {
        
        c.fillStyle = '#d4af37'; c.fillRect(509, 185, 8, 15);
    
      }
    ),
    Difference(
      'extraBubble',
      const Rect.fromLTWH(192.0, 242.0, 16.0, 16.0),
      const Offset(200, 250),
      (HtmlCanvas c) {
        
        c.fillStyle = '#55ffae'; c.beginPath(); c.arc(200, 250, 8, 0, math.pi*2); c.fill();
    
      }
    ),
    Difference(
      'bookRune',
      const Rect.fromLTWH(480.0, 355.0, 40, 40),
      const Offset(500, 375),
      (HtmlCanvas c) {
        
        c.strokeStyle = '#55ffae'; c.lineWidth = 2; c.shadowBlur = 10; c.shadowColor = '#55ffae';
        c.beginPath(); c.moveTo(490, 365); c.lineTo(500, 385); c.lineTo(510, 365); c.stroke();
        c.shadowBlur = 0;
    
      }
    ),
    Difference(
      'cobweb',
      const Rect.fromLTWH(30.0, 30.0, 40, 40),
      const Offset(50, 50),
      (HtmlCanvas c) {
        
        c.strokeStyle = 'rgba(255,255,255,0.4)'; c.lineWidth = 1;
        c.beginPath(); c.moveTo(0,0); c.lineTo(100, 100); c.stroke();
        c.beginPath(); c.moveTo(0, 50); c.lineTo(70, 100); c.stroke();
        c.beginPath(); c.moveTo(50, 0); c.lineTo(100, 70); c.stroke();
        c.beginPath(); c.moveTo(25, 25); c.quadraticCurveTo(50, 20, 75, 75); c.stroke();
        c.beginPath(); c.moveTo(10, 50); c.quadraticCurveTo(40, 45, 60, 90); c.stroke();
        c.beginPath(); c.moveTo(50, 10); c.quadraticCurveTo(45, 40, 90, 60); c.stroke();
    
      }
    )
  ];
}
