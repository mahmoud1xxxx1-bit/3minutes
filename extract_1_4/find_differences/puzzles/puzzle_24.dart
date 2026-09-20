
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../html_canvas.dart';
import '../puzzle_model.dart';

class Puzzle24 extends PuzzleDefinition {
  @override
  int get id => 24;



  @override
  void drawBaseScene(HtmlCanvas c) {
    
    c.fillStyle = '#0a0505'; c.fillRect(0,0,800,600); 
    c.fillStyle = '#4a0515'; c.fillRect(0,0,800,600);
    c.fillStyle = '#3a251a'; c.beginPath(); c.moveTo(100, 500); c.lineTo(700, 500); c.lineTo(800, 600); c.lineTo(0, 600); c.fill();
    c.strokeStyle = '#1e1108'; c.lineWidth = 2;
    for(double x=100; x<=700; x+=40) { c.beginPath(); c.moveTo(x, 500); c.lineTo((x-400)*1.5 + 400, 600); c.stroke(); }
    c.fillStyle = '#8a0a25';
    c.beginPath(); c.moveTo(0,0); c.lineTo(250, 0); c.quadraticCurveTo(150, 300, 50, 600); c.lineTo(0, 600); c.fill();
    c.beginPath(); c.moveTo(800,0); c.lineTo(550, 0); c.quadraticCurveTo(650, 300, 750, 600); c.lineTo(800, 600); c.fill();
    c.strokeStyle = '#4a0515'; c.lineWidth = 10; c.lineCap = 'round';
    for(double i=0.0; i<5; i++) {
        c.beginPath(); c.moveTo(50+i*40, 0); c.quadraticCurveTo(40+i*20, 300, 10+i*8, 600); c.stroke();
        c.beginPath(); c.moveTo(750-i*40, 0); c.quadraticCurveTo(760-i*20, 300, 790-i*8, 600); c.stroke();
    }
    c.fillStyle = '#1e1108';
    c.fillRect(0, 200, 150, 60); c.fillRect(650, 200, 150, 60);
    c.fillRect(0, 350, 100, 60); c.fillRect(700, 350, 100, 60);
    c.fillStyle = '#d4af37';
    c.fillRect(0, 260, 150, 15); c.fillRect(650, 260, 150, 15);
    c.fillRect(0, 410, 100, 15); c.fillRect(700, 410, 100, 15);
    c.fillStyle = '#8a0a25';
    for(double x=20; x<150; x+=40) { c.beginPath(); c.roundRect(x, 170, 30, 30, 10); c.fill(); c.beginPath(); c.roundRect(x+650, 170, 30, 30, 10); c.fill(); }
    c.fillStyle = '#d4af37';
    c.beginPath(); c.moveTo(400, 0); c.lineTo(405, 100); c.lineTo(395, 100); c.fill(); 
    c.beginPath(); c.ellipse(400, 120, 150, 20, 0, 0, math.pi*2); c.fill(); 
    c.beginPath(); c.ellipse(400, 180, 250, 30, 0, 0, math.pi*2); c.fill(); 
    c.strokeStyle = '#d4af37'; c.lineWidth = 2;
    for(double i=0.0; i<20; i++) {
        double topX = 400 + math.cos(i*math.pi*2/20)*150; double topY = 120 + math.sin(i*math.pi*2/20)*20;
        double botX = 400 + math.cos(i*math.pi*2/20)*250; double botY = 180 + math.sin(i*math.pi*2/20)*30;
        c.beginPath(); c.moveTo(topX, topY); c.lineTo(botX, botY); c.stroke(); 
    }
    c.shadowBlur = 15; c.shadowColor = '#ffaa00';
    for(double i=0.0; i<24; i++) {
        double x = 400 + math.cos(i*math.pi*2/24)*250; double y = 180 + math.sin(i*math.pi*2/24)*30;
        if(y > 175) { 
            c.fillStyle = '#fff'; c.beginPath(); c.arc(x, y-10, 6, 0, math.pi*2); c.fill();
            c.fillStyle = '#ffaa00'; c.beginPath(); c.arc(x, y-18, 4, 0, math.pi*2); c.fill(); 
        }
    }
    c.shadowBlur = 0;
    c.fillStyle = 'rgba(255,255,255,0.1)';
    c.beginPath(); c.moveTo(400, -50); c.lineTo(200, 550); c.lineTo(600, 550); c.fill();
    c.fillStyle = 'rgba(255,255,255,0.4)';
    c.beginPath(); c.ellipse(400, 550, 200, 30, 0, 0, math.pi*2); c.fill();

  }

  @override
  List<Difference> get differences => [
    
    Difference(
      'chandelierFlame',
      const Rect.fromLTWH(521.0, 157.0, 8.0, 8.0),
      const Offset(525, 161),
      (HtmlCanvas c) {
        
        c.shadowBlur = 15; c.shadowColor = '#00ffff';
        c.fillStyle = '#00ffff'; c.beginPath(); c.arc(525, 161, 4, 0, math.pi*2); c.fill(); 
        c.shadowBlur = 0;
    
      }
    ),
    Difference(
      'extraSeat',
      const Rect.fromLTWH(25.0, 315.0, 40, 40),
      const Offset(45, 335),
      (HtmlCanvas c) {
        
        c.fillStyle = '#8a0a25'; c.beginPath(); c.roundRect(30, 320, 30, 30, 10); c.fill();
    
      }
    ),
    Difference(
      'curtainTrim',
      const Rect.fromLTWH(70.0, 270.0, 20.0, 20.0),
      const Offset(80, 285),
      (HtmlCanvas c) {
        
        c.fillStyle = '#d4af37'; 
        c.beginPath(); c.arc(80, 280, 10, 0, math.pi*2); c.fill();
        c.beginPath(); c.moveTo(80, 290); c.lineTo(70, 310); c.lineTo(90, 310); c.fill();
    
      }
    ),
    Difference(
      'redPillow',
      const Rect.fromLTWH(216.0, 406.0, 8.0, 8.0),
      const Offset(240, 410),
      (HtmlCanvas c) {
        
        c.fillStyle = '#e62244';
        c.beginPath(); c.roundRect(220, 400, 40, 20, 10); c.fill();
        c.fillStyle = '#d4af37'; 
        c.beginPath(); c.arc(220, 410, 4, 0, math.pi*2); c.fill();
        c.beginPath(); c.arc(260, 410, 4, 0, math.pi*2); c.fill();
    
      }
    ),
    Difference(
      'musicNote',
      const Rect.fromLTWH(434.0, 454.0, 12.0, 12.0),
      const Offset(450, 445),
      (HtmlCanvas c) {
        
        c.fillStyle = '#55ffae'; c.shadowBlur = 10; c.shadowColor = '#55ffae';
        c.beginPath(); c.arc(440, 460, 6, 0, math.pi*2); c.fill();
        c.fillRect(444, 430, 4, 30);
        c.beginPath(); c.moveTo(444, 430); c.lineTo(460, 440); c.lineTo(460, 445); c.lineTo(448, 435); c.fill();
        c.shadowBlur = 0;
    
      }
    )
  ];
}
