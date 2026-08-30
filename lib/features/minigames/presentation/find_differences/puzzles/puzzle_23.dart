
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../html_canvas.dart';
import '../puzzle_model.dart';

class Puzzle23 extends PuzzleDefinition {
  @override
  int get id => 23;


  void drawTubeCoral(HtmlCanvas c, double cx, double cy, String color, double w, double h) {

    c.strokeStyle = color; c.lineWidth = w; c.lineCap = 'round';
    c.beginPath(); c.moveTo(cx, cy); c.quadraticCurveTo(cx+w, cy-h/2, cx, cy-h); c.stroke();
    c.fillStyle = '#111'; c.beginPath(); c.ellipse(cx, cy-h, w/3, w/6, 0, 0, math.pi*2); c.fill(); 

  }


  @override
  void drawBaseScene(HtmlCanvas c) {
    
    final bg = c.createRadialGradient(400, 0, 100, 400, 600, 800);
    bg..addColorStop(0, '#5baad4'); bg..addColorStop(1, '#081322');
    c.fillStyle = bg; c.fillRect(0,0,800,600);
    c.fillStyle = 'rgba(255,255,255,0.05)';
    for(double a=math.pi/4; a<math.pi*3/4; a+=math.pi/12) {
        c.beginPath(); c.moveTo(400, 0); c.lineTo(400+math.cos(a-0.1)*1000, math.sin(a-0.1)*1000); c.lineTo(400+math.cos(a+0.1)*1000, math.sin(a+0.1)*1000); c.fill();
    }
    c.fillStyle = '#c9a15a'; c.beginPath(); c.moveTo(0, 500); c.quadraticCurveTo(200, 450, 400, 520); c.quadraticCurveTo(600, 580, 800, 480); c.lineTo(800, 600); c.lineTo(0, 600); c.fill();
    c.fillStyle = '#2b4f60';
    c.beginPath(); c.arc(100, 550, 80, 0, math.pi*2); c.fill();
    c.beginPath(); c.arc(700, 520, 120, 0, math.pi*2); c.fill();
    for(double i=0.0; i<5; i++) drawTubeCoral(c, 50+i*20, 500+i*10, '#c15886', 15, 80+i*20);
    for(double i=0.0; i<8; i++) drawTubeCoral(c, 600+i*20, 450-i*5, '#ffaa00', 12, 100-i*10);
    c.fillStyle = '#8a2b3b'; c.beginPath(); c.arc(200, 500, 50, 0, math.pi*2); c.fill();
    c.strokeStyle = '#ff55a3'; c.lineWidth = 4;
    for(double i=0.0; i<20; i++) {
        double a = i*2.4; double r = i*2;
        c.beginPath(); c.arc(200, 500, r, a, a+math.pi); c.stroke();
    }
    c.strokeStyle = '#4c8f5e'; c.lineWidth = 8;
    for(double i=0.0; i<15; i++) {
        double sx = 300 + i*15;
        c.beginPath(); c.moveTo(sx, 550);
        c.quadraticCurveTo(sx-20, 450, sx+10, 350 + (i%3)*30); c.stroke();
    }
    c.fillStyle = 'rgba(85,255,174,0.6)'; c.shadowBlur = 20; c.shadowColor = '#55ffae';
    c.beginPath(); c.arc(500, 200, 40, math.pi, 0); c.fill();
    c.strokeStyle = 'rgba(85,255,174,0.6)'; c.lineWidth = 3;
    for(double i=-30; i<=30; i+=15) {
        c.beginPath(); c.moveTo(500+i, 200);
        c.quadraticCurveTo(500+i*2, 250, 500+i, 300); c.stroke();
    }
    c.shadowBlur = 0;
    c.fillStyle = '#f4d03f';
    for(double i=0.0; i<40; i++) {
        double fx = 100 + (i*37)%300; double fy = 150 + (i*41)%200;
        c.beginPath(); c.ellipse(fx, fy, 8, 4, 0, 0, math.pi*2); c.fill();
        c.beginPath(); c.moveTo(fx-8, fy); c.lineTo(fx-15, fy-5); c.lineTo(fx-15, fy+5); c.fill();
    }
    c.strokeStyle = 'rgba(255,255,255,0.4)'; c.lineWidth = 2;
    for(double i=0.0; i<30; i++) {
        double bx = 50 + (i*97)%700; double by = 50 + (i*131)%500; double br = 3 + (i%5)*2;
        c.beginPath(); c.arc(bx, by, br, 0, math.pi*2); c.stroke();
        c.fillStyle = 'rgba(255,255,255,0.8)'; c.beginPath(); c.arc(bx-br/3, by-br/3, br/4, 0, math.pi*2); c.fill();
    }

  }

  @override
  List<Difference> get differences => [
    
    Difference(
      'extraJellyfish',
      const Rect.fromLTWH(625.0, 125.0, 50.0, 50.0),
      const Offset(650, 160),
      (HtmlCanvas c) {
        
        c.fillStyle = 'rgba(255,0,255,0.6)'; c.shadowBlur = 20; c.shadowColor = '#ff00ff';
        c.beginPath(); c.arc(650, 150, 25, math.pi, 0); c.fill();
        c.strokeStyle = 'rgba(255,0,255,0.6)'; c.lineWidth = 2;
        for(double i=-15; i<=15; i+=10) {
            c.beginPath(); c.moveTo(650+i, 150);
            c.quadraticCurveTo(650+i*2, 180, 650+i, 210); c.stroke();
        }
        c.shadowBlur = 0;
    
      }
    ),
    Difference(
      'extraFish',
      const Rect.fromLTWH(380.0, 80.0, 40, 40),
      const Offset(400, 100),
      (HtmlCanvas c) {
        
        c.fillStyle = '#ff5555';
        c.beginPath(); c.ellipse(400, 100, 16, 8, 0, 0, math.pi*2); c.fill();
        c.beginPath(); c.moveTo(384, 100); c.lineTo(370, 90); c.lineTo(370, 110); c.fill();
    
      }
    ),
    Difference(
      'extraPearl',
      const Rect.fromLTWH(188.0, 488.0, 24.0, 24.0),
      const Offset(200, 500),
      (HtmlCanvas c) {
        
        c.fillStyle = '#fff'; c.shadowBlur = 10; c.shadowColor = '#fff';
        c.beginPath(); c.arc(200, 500, 12, 0, math.pi*2); c.fill();
        c.shadowBlur = 0;
    
      }
    ),
    Difference(
      'extraSeaweed',
      const Rect.fromLTWH(410.0, 430.0, 40, 40),
      const Offset(430, 450),
      (HtmlCanvas c) {
        
        c.strokeStyle = '#4c8f5e'; c.lineWidth = 8;
        c.beginPath(); c.moveTo(430, 550);
        c.quadraticCurveTo(410, 450, 440, 350); c.stroke();
    
      }
    ),
    Difference(
      'starfish',
      const Rect.fromLTWH(70.0, 525.0, 40, 40),
      const Offset(90, 545),
      (HtmlCanvas c) {
        
        c.fillStyle = '#ffaa00';
        c.beginPath(); c.moveTo(90, 530); 
        for(double i=0.0; i<5; i++) {
            c.lineTo(90+math.cos(i*math.pi*2/5-math.pi/2)*15, 545+math.sin(i*math.pi*2/5-math.pi/2)*15);
            c.lineTo(90+math.cos((i+0.5)*math.pi*2/5-math.pi/2)*6, 545+math.sin((i+0.5)*math.pi*2/5-math.pi/2)*6);
        }
        c.fill();
    
      }
    )
  ];
}
