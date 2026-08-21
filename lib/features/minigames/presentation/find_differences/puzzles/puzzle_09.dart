
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../html_canvas.dart';
import '../puzzle_model.dart';

class Puzzle09 extends PuzzleDefinition {
  @override
  int get id => 9;

  @override
  void drawBaseScene(HtmlCanvas c) {
    
    final skyG = c.createLinearGradient(0,0,0,400);
    skyG..addColorStop(0, '#2b4f60'); skyG..addColorStop(0.5, '#c15886'); skyG..addColorStop(1, '#d4af37');
    c.fillStyle = skyG; c.fillRect(0,0,800,400);
    c.fillStyle = 'rgba(255,255,255,0.4)'; c.beginPath(); c.arc(400, 250, 100, 0, math.pi*2); c.fill();
    c.fillStyle = '#fff'; c.beginPath(); c.arc(400, 250, 80, 0, math.pi*2); c.fill();
    c.fillStyle = '#fff'; c.beginPath(); c.arc(100, 100, 2, 0, math.pi*2); c.arc(200, 80, 2, 0, math.pi*2); c.arc(600, 120, 2, 0, math.pi*2); c.fill();
    c.fillStyle = '#b38b60'; 
    c.beginPath(); c.moveTo(600, 150); c.lineTo(450, 350); c.lineTo(600, 350); c.fill();
    c.fillStyle = '#d4b48c'; 
    c.beginPath(); c.moveTo(600, 150); c.lineTo(750, 350); c.lineTo(600, 350); c.fill();
    c.fillStyle = '#a67c52'; c.beginPath(); c.moveTo(250, 220); c.lineTo(150, 350); c.lineTo(250, 350); c.fill();
    c.fillStyle = '#c49c71'; c.beginPath(); c.moveTo(250, 220); c.lineTo(350, 350); c.lineTo(250, 350); c.fill();
    c.fillStyle = '#c49c71'; c.beginPath(); c.ellipse(200, 420, 400, 150, 0, 0, math.pi*2); c.fill();
    c.fillStyle = '#d4b48c'; c.beginPath(); c.ellipse(600, 480, 500, 180, 0, 0, math.pi*2); c.fill();
    c.fillStyle = '#e4c49d'; c.beginPath(); c.ellipse(300, 600, 600, 200, 0, 0, math.pi*2); c.fill();
    c.strokeStyle = 'rgba(200, 150, 100, 0.4)'; c.lineWidth = 3;
    for(double i=250.0; i<=750; i+=100) { c.beginPath(); c.moveTo(i, 520); c.quadraticCurveTo(i+50, 540, i+100, 520); c.stroke(); }
    c.fillStyle = '#222'; c.beginPath(); c.moveTo(650, 350); c.lineTo(550, 500); c.lineTo(750, 500); c.fill(); 
    c.fillStyle = '#3a251a'; c.fillRect(590, 360, 5, 140); c.fillRect(705, 360, 5, 140); 
    c.fillStyle = '#c15886'; c.beginPath(); c.moveTo(650, 350); c.lineTo(500, 500); c.lineTo(590, 500); c.fill();
    c.beginPath(); c.moveTo(650, 350); c.lineTo(800, 500); c.lineTo(710, 500); c.fill();
    c.strokeStyle = '#d4af37'; c.lineWidth = 4;
    c.beginPath(); c.moveTo(560, 440); c.lineTo(580, 470); c.moveTo(740, 440); c.lineTo(720, 470); c.stroke();
    c.strokeStyle = '#fff'; c.lineWidth = 2; c.beginPath(); c.moveTo(650, 350); c.lineTo(460, 520); c.moveTo(650, 350); c.lineTo(820, 520); c.stroke();
    c.fillStyle = '#5a3d2b'; c.fillRect(450, 515, 10, 15); c.fillRect(820, 515, 10, 15);
    c.fillStyle = '#2d5c3a'; c.beginPath(); c.roundRect(100, 350, 40, 180, 20); c.fill(); 
    c.beginPath(); c.roundRect(40, 400, 70, 25, 12); c.roundRect(40, 360, 25, 50, 12); c.fill(); 
    c.beginPath(); c.roundRect(130, 430, 80, 25, 12); c.roundRect(185, 380, 25, 60, 12); c.fill(); 
    c.fillStyle = '#fff';
    for(double y=360; y<520; y+=20) { c.fillRect(100, y, 5, 2); c.fillRect(135, y+10, 5, 2); }
    c.fillStyle = '#d14949'; c.beginPath(); c.arc(52, 355, 8, 0, math.pi*2); c.arc(197, 375, 8, 0, math.pi*2); c.fill();
    c.fillStyle = '#3a251a'; c.beginPath(); c.roundRect(380, 530, 40, 10, 5); c.fill();
    c.beginPath(); c.roundRect(390, 525, 40, 10, 5); c.fill();
    c.fillStyle = '#d4af37'; c.beginPath(); c.moveTo(390, 530); c.lineTo(400, 490); c.lineTo(410, 530); c.fill();
    c.fillStyle = '#d14949'; c.beginPath(); c.moveTo(400, 530); c.lineTo(410, 500); c.lineTo(420, 530); c.fill();
  }

  @override
  List<Difference> get differences => [
    
    Difference(
      'starMissing',
      const Rect.fromLTWH(195.0, 75.0, 10.0, 10.0),
      const Offset(200, 80),
      (HtmlCanvas c) {
        
        final skyG = c.createLinearGradient(0,0,0,400);
        skyG..addColorStop(0, '#2b4f60'); skyG..addColorStop(0.5, '#c15886'); skyG..addColorStop(1, '#d4af37');
        c.fillStyle = skyG; c.beginPath(); c.arc(200, 80, 5, 0, math.pi*2); c.fill();
    
      }
    ),
    Difference(
      'cactusFlowerColor',
      const Rect.fromLTWH(44.0, 347.0, 16.0, 16.0),
      const Offset(52, 355),
      (HtmlCanvas c) {
        
        c.fillStyle = '#d4af37'; c.beginPath(); c.arc(52, 355, 8, 0, math.pi*2); c.fill();
    
      }
    ),
    Difference(
      'tentPatternMissing',
      const Rect.fromLTWH(550.0, 435.0, 40, 40),
      const Offset(570, 455),
      (HtmlCanvas c) {
        
        c.fillStyle = '#c15886'; c.fillRect(550, 430, 40, 50); // Erase pattern
    
      }
    ),
    Difference(
      'tentPegMissing',
      const Rect.fromLTWH(435.0, 502.0, 40, 40),
      const Offset(455, 522),
      (HtmlCanvas c) {
        
        c.fillStyle = '#e4c49d'; c.fillRect(445, 510, 20, 25); 
        c.strokeStyle = '#fff'; c.lineWidth = 2; c.beginPath(); c.moveTo(460, 508); c.lineTo(440, 532); c.stroke(); 
    
      }
    ),
    Difference(
      'extraCampfireLog',
      const Rect.fromLTWH(370.0, 505.0, 40, 40),
      const Offset(390, 525),
      (HtmlCanvas c) {
        
        c.fillStyle = '#2a1a12'; c.beginPath(); c.roundRect(375, 520, 40, 10, 5); c.fill();
    
      }
    )
  ];
}
