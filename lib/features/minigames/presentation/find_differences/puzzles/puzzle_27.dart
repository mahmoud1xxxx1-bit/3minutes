
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../html_canvas.dart';
import '../puzzle_model.dart';

class Puzzle27 extends PuzzleDefinition {
  @override
  int get id => 27;


  void drawCrystal(HtmlCanvas c, double cx, double cy, String color, double h) {

    c.fillStyle = color; c.shadowBlur = 15; c.shadowColor = color;
    c.beginPath(); c.moveTo(cx, cy); c.lineTo(cx-15, cy-h/2); c.lineTo(cx, cy-h); c.lineTo(cx+15, cy-h/2); c.fill();
    c.fillStyle = '#fff'; c.globalAlpha = 0.4;
    c.beginPath(); c.moveTo(cx, cy); c.lineTo(cx, cy-h); c.lineTo(cx+15, cy-h/2); c.fill();
    c.globalAlpha = 1.0; c.shadowBlur = 0;

  }


  @override
  void drawBaseScene(HtmlCanvas c) {
    
    final sky = c.createLinearGradient(0,0,0,400);
    sky.addColorStop(0, '#10051a'); sky.addColorStop(1, '#2b0a3d');
    c.fillStyle = sky; c.fillRect(0,0,800,600);
    c.fillStyle = '#fff';
    for(double i=0.0; i<40; i++) {
        double sx = (i*73)%800; double sy = (i*51)%400;
        c.beginPath(); c.arc(sx, sy, 1.5, 0, math.pi*2); c.fill();
    }
    c.fillStyle = '#ffaa00'; c.beginPath(); c.arc(650, 150, 60, 0, math.pi*2); c.fill();
    c.fillStyle = '#55ffae'; c.beginPath(); c.arc(200, 100, 25, 0, math.pi*2); c.fill();
    c.fillStyle = '#1e1124';
    c.beginPath(); c.moveTo(0, 400); c.lineTo(150, 350); c.lineTo(300, 420); c.lineTo(500, 380); c.lineTo(700, 450); c.lineTo(800, 380); c.lineTo(800, 600); c.lineTo(0, 600); c.fill();
    c.fillStyle = '#0a0510';
    c.beginPath(); c.moveTo(0, 500); c.quadraticCurveTo(200, 450, 400, 600); c.lineTo(0, 600); c.fill();
    c.beginPath(); c.moveTo(800, 480); c.quadraticCurveTo(600, 520, 500, 600); c.lineTo(800, 600); c.fill();
    c.strokeStyle = '#2b0a3d'; c.lineWidth = 4;
    c.beginPath(); c.ellipse(200, 450, 40, 15, 0, 0, math.pi*2); c.stroke();
    c.beginPath(); c.ellipse(650, 550, 60, 20, 0, 0, math.pi*2); c.stroke();
    drawCrystal(c, 100, 550, '#00ffff', 120);
    drawCrystal(c, 130, 570, '#ff00ff', 80);
    drawCrystal(c, 700, 420, '#55ffae', 100);
    drawCrystal(c, 400, 450, '#ffaa00', 70);
    c.strokeStyle = '#ff55a3'; c.lineWidth = 8; c.lineCap = 'round';
    for(double i=0.0; i<3; i++) {
        c.beginPath(); c.moveTo(500, 550);
        c.quadraticCurveTo(450+i*30, 450, 550-i*20, 350-i*20); c.stroke();
    }
    c.fillStyle = '#00ffff'; 
    c.beginPath(); c.arc(550, 350, 15, 0, math.pi*2); c.fill();
    c.beginPath(); c.arc(530, 330, 12, 0, math.pi*2); c.fill();
    c.beginPath(); c.arc(510, 310, 10, 0, math.pi*2); c.fill();

  }

  @override
  List<Difference> get differences => [
    
    Difference(
      'extraCrystal',
      const Rect.fromLTWH(420.0, 420.0, 40, 40),
      const Offset(440, 440),
      (HtmlCanvas c) {
        
        drawCrystal(c, 440, 460, '#00ffff', 60);
    
      }
    ),
    Difference(
      'moonRing',
      const Rect.fromLTWH(180.0, 80.0, 40, 40),
      const Offset(200, 100),
      (HtmlCanvas c) {
        
        c.strokeStyle = 'rgba(85,255,174,0.6)'; c.lineWidth = 4; c.shadowBlur = 10; c.shadowColor = '#55ffae';
        c.beginPath(); c.ellipse(200, 100, 50, 15, -0.2, 0, math.pi*2); c.stroke();
        c.shadowBlur = 0;
    
      }
    ),
    Difference(
      'extraCrater',
      const Rect.fromLTWH(280.0, 530.0, 40, 40),
      const Offset(300, 550),
      (HtmlCanvas c) {
        
        c.strokeStyle = '#2b0a3d'; c.lineWidth = 4;
        c.beginPath(); c.ellipse(300, 550, 30, 10, 0, 0, math.pi*2); c.stroke();
    
      }
    ),
    Difference(
      'tentacleBulb',
      const Rect.fromLTWH(472.0, 272.0, 16.0, 16.0),
      const Offset(480, 280),
      (HtmlCanvas c) {
        
        c.fillStyle = '#00ffff'; 
        c.beginPath(); c.arc(480, 280, 8, 0, math.pi*2); c.fill();
    
      }
    ),
    Difference(
      'meteor',
      const Rect.fromLTWH(477.0, 177.0, 6.0, 6.0),
      const Offset(450, 175),
      (HtmlCanvas c) {
        
        final grad = c.createLinearGradient(380, 160, 480, 180);
        grad.addColorStop(0, 'transparent'); grad.addColorStop(1, '#fff');
        c.strokeStyle = grad; c.lineWidth = 3; c.lineCap = 'round';
        c.beginPath(); c.moveTo(380, 160); c.lineTo(480, 180); c.stroke();
        c.fillStyle = '#fff'; c.beginPath(); c.arc(480, 180, 3, 0, math.pi*2); c.fill();
    
      }
    )
  ];
}
