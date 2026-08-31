
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../html_canvas.dart';
import '../puzzle_model.dart';

class Puzzle26 extends PuzzleDefinition {
  @override
  int get id => 26;



  @override
  void drawBaseScene(HtmlCanvas c) {
    
    final sky = c.createLinearGradient(0,0,0,600);
    sky.addColorStop(0, '#5baad4'); sky.addColorStop(1, '#a4b4c0');
    c.fillStyle = sky; c.fillRect(0,0,800,600);
    c.fillStyle = '#fff';
    for(double i=0.0; i<8; i++) {
        double cx = (i*140)%800; double cy = 50 + (i*30)%150;
        c.beginPath(); c.arc(cx, cy, 30, 0, math.pi*2);
        c.arc(cx+30, cy-10, 40, 0, math.pi*2);
        c.arc(cx+60, cy+10, 25, 0, math.pi*2);
        c.fill();
    }
    c.fillStyle = '#4a2f20';
    c.beginPath(); c.moveTo(0, 400); c.lineTo(800, 400); c.lineTo(800, 600); c.lineTo(0, 600); c.fill();
    c.strokeStyle = '#2a1a12'; c.lineWidth = 3;
    for(double x=20; x<800; x+=60) {
        c.beginPath(); c.moveTo(x-20, 600); c.lineTo(x+20, 400); c.stroke();
    }
    c.fillStyle = '#b87333';
    c.fillRect(0, 380, 800, 15);
    for(double x=50; x<800; x+=100) {
        c.fillRect(x, 395, 10, 30);
    }
    c.fillStyle = '#3a251a'; c.fillRect(360, 300, 80, 200); 
    c.strokeStyle = '#d4af37'; c.lineWidth = 15;
    for(double i=0.0; i<8; i++) { 
        double a = i*math.pi/4;
        c.beginPath(); c.moveTo(400, 280); c.lineTo(400+math.cos(a)*120, 280+math.sin(a)*120); c.stroke();
        c.fillStyle = '#8a2b3b'; c.beginPath(); c.arc(400+math.cos(a)*140, 280+math.sin(a)*140, 10, 0, math.pi*2); c.fill();
    }
    c.beginPath(); c.arc(400, 280, 100, 0, math.pi*2); c.stroke(); 
    c.fillStyle = '#b87333'; c.beginPath(); c.arc(400, 280, 30, 0, math.pi*2); c.fill(); 
    c.fillStyle = '#2b4f60'; c.beginPath(); c.roundRect(100, 450, 150, 120, 10); c.fill();
    c.strokeStyle = '#d4af37'; c.lineWidth = 4; c.strokeRect(105, 455, 140, 110);
    c.fillStyle = '#fff'; c.beginPath(); c.arc(140, 500, 25, 0, math.pi*2); c.fill(); c.stroke(); 
    c.beginPath(); c.arc(210, 500, 25, 0, math.pi*2); c.fill(); c.stroke(); 
    c.fillStyle = '#111';
    c.beginPath(); c.moveTo(140, 500); c.lineTo(155, 490); c.stroke();
    c.beginPath(); c.moveTo(210, 500); c.lineTo(200, 485); c.stroke();
    c.strokeStyle = '#7b8b9a'; c.lineWidth = 20; c.lineCap = 'round';
    c.beginPath(); c.moveTo(700, 600); c.lineTo(700, 450); c.lineTo(750, 450); c.lineTo(750, 300); c.stroke();
    c.fillStyle = '#b87333'; c.fillRect(685, 440, 30, 20); c.fillRect(735, 440, 30, 20); 
    c.fillStyle = 'rgba(255,255,255,0.4)'; c.beginPath(); c.arc(750, 270, 30, 0, math.pi*2); c.fill(); 
    c.beginPath(); c.arc(730, 240, 40, 0, math.pi*2); c.fill();

  }

  @override
  List<Difference> get differences => [
    
    Difference(
      'extraDial',
      const Rect.fromLTWH(160.0, 535.0, 30.0, 30.0),
      const Offset(175, 550),
      (HtmlCanvas c) {
        
        c.fillStyle = '#fff'; c.strokeStyle = '#d4af37'; c.lineWidth = 4;
        c.beginPath(); c.arc(175, 550, 15, 0, math.pi*2); c.fill(); c.stroke();
        c.fillStyle = '#111';
        c.beginPath(); c.moveTo(175, 550); c.lineTo(175, 540); c.stroke();
    
      }
    ),
    Difference(
      'pipeJointColor',
      const Rect.fromLTWH(730.0, 430.0, 40, 40),
      const Offset(750, 450),
      (HtmlCanvas c) {
        
        c.fillStyle = '#e2e2e2'; c.fillRect(735, 440, 30, 20); 
    
      }
    ),
    Difference(
      'extraCloud',
      const Rect.fromLTWH(600.0, 80.0, 40, 40),
      const Offset(620, 100),
      (HtmlCanvas c) {
        
        c.fillStyle = '#fff';
        double cx = 600; double cy = 100;
        c.beginPath(); c.arc(cx, cy, 30, 0, math.pi*2);
        c.arc(cx+30, cy-10, 40, 0, math.pi*2);
        c.arc(cx+60, cy+10, 25, 0, math.pi*2);
        c.fill();
    
      }
    ),
    Difference(
      'wheelRuby',
      const Rect.fromLTWH(392.0, 272.0, 16.0, 16.0),
      const Offset(400, 280),
      (HtmlCanvas c) {
        
        c.fillStyle = '#ff2222'; c.beginPath(); c.arc(400, 280, 8, 0, math.pi*2); c.fill();
    
      }
    ),
    Difference(
      'extraSteam',
      const Rect.fromLTWH(750.0, 190.0, 40.0, 40.0),
      const Offset(770, 210),
      (HtmlCanvas c) {
        
        c.fillStyle = 'rgba(255,255,255,0.4)'; c.beginPath(); c.arc(770, 210, 20, 0, math.pi*2); c.fill(); 
    
      }
    )
  ];
}
