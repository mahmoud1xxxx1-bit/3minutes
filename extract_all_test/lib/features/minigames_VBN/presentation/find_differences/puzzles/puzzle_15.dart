
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../html_canvas.dart';
import '../puzzle_model.dart';

class Puzzle15 extends PuzzleDefinition {
  @override
  int get id => 15;



  @override
  void drawBaseScene(HtmlCanvas c) {
    
    final sky = c.createLinearGradient(0,0,0,600); sky..addColorStop(0, '#0a1120'); sky..addColorStop(1, '#2b4f60');
    c.fillStyle = sky; c.fillRect(0,0,800,600);
    c.fillStyle = '#fff'; for(double i=0.0; i<50; i++) { c.beginPath(); c.arc((i*31)%800, (i*47)%400, 2, 0, math.pi*2); c.fill(); }
    c.save(); c.translate(250, 250);
    c.strokeStyle = '#e2e2e2'; c.lineWidth = 6; c.beginPath(); c.arc(0, 0, 180, 0, math.pi*2); c.stroke();
    for(double i=0.0; i<12; i++) {
        c.rotate(math.pi/6);
        c.strokeStyle = '#a4b4c0'; c.lineWidth = 3; c.beginPath(); c.moveTo(0, 0); c.lineTo(0, -180); c.stroke(); 
        c.fillStyle = (i%2==0)?'#d14949':'#f4d03f';
        c.beginPath(); c.roundRect(-20, -200, 40, 40, 5); c.fill();
        c.fillStyle = '#eef6ff'; c.fillRect(-10, -190, 20, 15); 
    }
    c.restore();
    c.strokeStyle = '#d4af37'; c.lineWidth = 15; c.beginPath(); c.moveTo(250, 250); c.lineTo(150, 600); c.moveTo(250, 250); c.lineTo(350, 600); c.stroke();
    c.fillStyle = '#e2e2e2'; c.beginPath(); c.arc(250, 250, 20, 0, math.pi*2); c.fill();
    c.fillStyle = '#8a2b3b'; c.beginPath(); c.moveTo(600, 250); c.lineTo(450, 400); c.lineTo(750, 400); c.fill(); 
    c.fillStyle = '#e2e2e2'; c.beginPath(); c.moveTo(600, 250); c.lineTo(500, 400); c.lineTo(550, 400); c.fill(); 
    c.beginPath(); c.moveTo(600, 250); c.lineTo(650, 400); c.lineTo(700, 400); c.fill();
    c.fillStyle = '#d4af37'; c.beginPath(); c.arc(600, 250, 15, 0, math.pi*2); c.fill(); 
    c.fillStyle = '#2b4f60'; c.fillRect(480, 400, 240, 200); 
    c.fillStyle = '#d14949'; c.fillRect(480, 400, 20, 200); c.fillRect(520, 400, 20, 200); c.fillRect(560, 400, 20, 200); c.fillRect(600, 400, 20, 200); c.fillRect(640, 400, 20, 200); c.fillRect(680, 400, 20, 200);
    c.fillStyle = '#111'; c.beginPath(); c.arc(600, 600, 50, math.pi, 0); c.fill(); 
    void drawFirework(cx, cy, color) {
        c.fillStyle = color;
        for(double i=0.0; i<8; i++) {
            double a = i*math.pi/4;
            c.beginPath(); c.arc(cx+math.cos(a)*40, cy+math.sin(a)*40, 4, 0, math.pi*2); c.fill();
            c.beginPath(); c.arc(cx+math.cos(a)*20, cy+math.sin(a)*20, 2, 0, math.pi*2); c.fill();
        }
    }
    drawFirework(600, 150, '#55ffae'); drawFirework(700, 100, '#f4d03f');

  }

  @override
  List<Difference> get differences => [
    
    Difference(
      'wheelCabinColor',
      const Rect.fromLTWH(230.0, 50.0, 40, 40),
      const Offset(250, 70),
      (HtmlCanvas c) {
        
        c.fillStyle = '#4c8f5e'; c.beginPath(); c.roundRect(230, 50, 40, 40, 5); c.fill();
        c.fillStyle = '#eef6ff'; c.fillRect(240, 60, 20, 15); 
    
      }
    ),
    Difference(
      'tentTopBall',
      const Rect.fromLTWH(585.0, 235.0, 30.0, 30.0),
      const Offset(600, 250),
      (HtmlCanvas c) {
        
        c.fillStyle = '#a4b4c0'; c.beginPath(); c.arc(600, 250, 15, 0, math.pi*2); c.fill(); 
    
      }
    ),
    Difference(
      'tentStripeColor',
      const Rect.fromLTWH(585.0, 450.0, 30.0, 100.0),
      const Offset(600, 500),
      (HtmlCanvas c) {
        c.fillStyle = '#f4d03f'; c.fillRect(600, 400, 20, 200);
      }
    ),
    Difference(
      'extraFirework',
      const Rect.fromLTWH(480.0, 100.0, 40, 40),
      const Offset(500, 120),
      (HtmlCanvas c) {
        
        double cx = 500, cy = 120;
        c.fillStyle = '#c15886';
        for(double i=0.0; i<8; i++) {
            double a = i*math.pi/4;
            c.beginPath(); c.arc(cx+math.cos(a)*40, cy+math.sin(a)*40, 4, 0, math.pi*2); c.fill();
            c.beginPath(); c.arc(cx+math.cos(a)*20, cy+math.sin(a)*20, 2, 0, math.pi*2); c.fill();
        }
    
      }
    ),
    Difference(
      'wheelCenterColor',
      const Rect.fromLTWH(230.0, 230.0, 40.0, 40.0),
      const Offset(250, 250),
      (HtmlCanvas c) {
        
        c.fillStyle = '#d4af37'; c.beginPath(); c.arc(250, 250, 20, 0, math.pi*2); c.fill();
    
      }
    )
  ];
}
