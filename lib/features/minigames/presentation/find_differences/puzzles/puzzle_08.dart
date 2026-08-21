
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../html_canvas.dart';
import '../puzzle_model.dart';

class Puzzle08 extends PuzzleDefinition {
  @override
  int get id => 8;

  @override
  void drawBaseScene(HtmlCanvas c) {
    
    final grad = c.createLinearGradient(0,0,0,450);
    grad..addColorStop(0, '#c7d6d1'); grad..addColorStop(1, '#e8efe9');
    c.fillStyle = grad; c.fillRect(0,0,800,450);
    c.fillStyle = '#a5b2bc'; c.fillRect(0,450,800,150);
    c.strokeStyle = '#94a2ac'; c.lineWidth = 2;
    for(double i=-200; i<=1000; i+=60) {
        c.beginPath(); c.moveTo(i, 450); c.lineTo(i - (400 - i)*0.5, 600); c.stroke();
    }
    for(double y=450; y<=600; y+=30) {
        c.beginPath(); c.moveTo(0, y); c.lineTo(800, y); c.stroke();
    }
    c.fillStyle = '#1b2c49'; c.fillRect(40, 40, 220, 200); 
    c.fillStyle = '#fff'; c.beginPath(); c.arc(200,70,3,0,math.pi*2); c.arc(100,100,2,0,math.pi*2); c.fill(); 
    c.fillStyle = '#0a1120'; c.fillRect(50, 160, 40, 80); c.fillRect(100, 140, 50, 100); c.fillRect(160, 180, 60, 60); 
    c.fillStyle = '#d4af37'; c.fillRect(60, 170, 5,5); c.fillRect(110, 160, 10,10); c.fillRect(180, 200, 5,5); 
    c.strokeStyle = '#e2e2e2'; c.lineWidth = 15; c.strokeRect(40, 40, 220, 200); 
    c.lineWidth = 8; c.beginPath(); c.moveTo(40, 140); c.lineTo(260, 140); c.moveTo(150, 40); c.lineTo(150, 240); c.stroke();
    final oxG = c.createLinearGradient(700, 0, 750, 0);
    oxG..addColorStop(0, '#4c8f5e'); oxG..addColorStop(1, '#2b4f60');
    c.fillStyle = oxG; c.beginPath(); c.roundRect(700, 250, 50, 200, 20); c.fill();
    c.fillStyle = '#a4b4c0'; c.fillRect(715, 220, 20, 30); 
    c.fillStyle = '#fff'; c.beginPath(); c.arc(725, 230, 12, 0, math.pi*2); c.fill(); 
    c.fillStyle = '#d14949'; c.beginPath(); c.arc(725, 230, 8, 0, math.pi); c.fill(); 
    c.strokeStyle = '#222'; c.lineWidth = 2; c.beginPath(); c.moveTo(725,230); c.lineTo(718,225); c.stroke();
    c.fillStyle = '#fff'; c.beginPath(); c.roundRect(500, 80, 160, 220, 5); c.fill();
    c.fillStyle = '#111'; c.fillRect(510, 90, 65, 120); c.fillRect(585, 90, 65, 120); 
    c.fillStyle = '#e2e2e2'; c.fillRect(510, 140, 65, 5); c.fillRect(585, 140, 65, 5); 
    c.fillStyle = '#d14949'; c.fillRect(520, 110, 15, 30); c.fillStyle = '#fff'; c.fillRect(520, 120, 15, 10);
    c.fillStyle = '#5baad4'; c.fillRect(545, 100, 20, 40); c.fillStyle = '#fff'; c.fillRect(545, 115, 20, 10);
    c.fillStyle = '#d4af37'; c.fillRect(600, 120, 15, 20); c.fillRect(630, 110, 10, 30);
    c.fillStyle = '#e2e2e2'; c.fillRect(510, 220, 140, 30); c.fillRect(510, 260, 140, 30);
    c.fillStyle = '#a4b4c0'; c.fillRect(560, 230, 40, 5); c.fillRect(560, 270, 40, 5);
    c.fillStyle = 'rgba(255,255,255,0.3)'; c.beginPath(); c.moveTo(510, 90); c.lineTo(550, 90); c.lineTo(510, 160); c.fill();
    c.fillStyle = '#222'; c.beginPath(); c.roundRect(300, 100, 160, 110, 10); c.fill();
    c.fillStyle = '#0a1120'; c.fillRect(310, 110, 140, 80); 
    c.strokeStyle = '#2b4f60'; c.lineWidth = 1; 
    for(double i=310.0; i<=450; i+=20) { c.beginPath(); c.moveTo(i, 110); c.lineTo(i, 190); c.stroke(); }
    for(double i=110.0; i<=190; i+=20) { c.beginPath(); c.moveTo(310, i); c.lineTo(450, i); c.stroke(); }
    c.strokeStyle = '#55ffae'; c.lineWidth = 2; c.lineJoin = 'round';
    c.beginPath(); c.moveTo(310, 150); c.lineTo(340, 150); c.lineTo(350, 130); c.lineTo(360, 180); c.lineTo(370, 150); c.lineTo(400, 150); c.lineTo(410, 140); c.lineTo(420, 160); c.lineTo(430, 150); c.lineTo(450, 150); c.stroke();
    c.fillStyle = '#55ffae'; c.font = '16px monospace'; c.fillText('85', 420, 130);
    c.fillStyle = '#5baad4'; c.font = '12px monospace'; c.fillText('120', 415, 185);
    c.strokeStyle = '#a4b4c0'; c.lineWidth = 6; c.beginPath(); c.moveTo(150, 120); c.lineTo(150, 450); c.stroke();
    c.beginPath(); c.moveTo(120, 450); c.lineTo(180, 450); c.stroke(); 
    c.fillStyle = '#222'; c.beginPath(); c.arc(120, 460, 6, 0, math.pi*2); c.arc(180, 460, 6, 0, math.pi*2); c.fill(); 
    c.fillStyle = 'rgba(226,226,226,0.8)'; c.beginPath(); c.roundRect(130, 150, 40, 60, 10); c.fill(); 
    c.fillStyle = 'rgba(91,170,212,0.6)'; c.beginPath(); c.roundRect(132, 170, 36, 38, 8); c.fill(); 
    c.strokeStyle = 'rgba(255,255,255,0.7)'; c.lineWidth = 3;
    c.beginPath(); c.moveTo(150, 210); c.quadraticCurveTo(200, 300, 250, 350); c.stroke();
    c.fillStyle = '#7a8b99'; c.beginPath(); c.roundRect(220, 260, 30, 140, 10); c.fill(); 
    c.fillStyle = '#eef6ff'; c.fillRect(250, 340, 350, 50); 
    c.fillStyle = '#a4b4c0'; c.fillRect(300, 390, 15, 60); c.fillRect(550, 390, 15, 60); 
    c.fillStyle = '#222'; c.beginPath(); c.arc(307, 455, 8, 0, math.pi*2); c.arc(557, 455, 8, 0, math.pi*2); c.fill(); 
    c.fillStyle = '#fff'; c.beginPath(); c.roundRect(255, 310, 80, 40, 15); c.fill(); 
    c.fillStyle = '#f0f0f0'; c.beginPath(); c.roundRect(265, 320, 70, 30, 15); c.fill(); 
    final blG = c.createLinearGradient(350, 0, 600, 0);
    blG..addColorStop(0, '#5baad4'); blG..addColorStop(1, '#3b8ab4');
    c.fillStyle = blG; c.beginPath(); c.roundRect(350, 330, 250, 65, 10); c.fill(); 
    c.strokeStyle = '#c0c8c3'; c.lineWidth = 6;
    c.beginPath(); c.moveTo(370, 310); c.lineTo(530, 310); c.stroke();
    for(double i=380.0; i<=520; i+=30) { c.beginPath(); c.moveTo(i, 310); c.lineTo(i, 340); c.stroke(); }
  }

  @override
  List<Difference> get differences => [
    
    Difference(
      'gaugeNeedleAngle',
      const Rect.fromLTWH(713.0, 218.0, 24.0, 24.0),
      const Offset(725, 230),
      (HtmlCanvas c) {
        
        c.fillStyle = '#fff'; c.beginPath(); c.arc(725, 230, 12, 0, math.pi*2); c.fill(); 
        c.fillStyle = '#d14949'; c.beginPath(); c.arc(725, 230, 8, 0, math.pi); c.fill(); 
        c.strokeStyle = '#222'; c.lineWidth = 2; c.beginPath(); c.moveTo(725,230); c.lineTo(732,225); c.stroke();
    
      }
    ),
    Difference(
      'cabinetReflectionMissing',
      const Rect.fromLTWH(510.0, 100.0, 40, 40),
      const Offset(530, 120),
      (HtmlCanvas c) {
        
        c.fillStyle = '#111'; c.fillRect(510, 90, 65, 120); 
        c.fillStyle = '#e2e2e2'; c.fillRect(510, 140, 65, 5); 
        c.fillStyle = '#d14949'; c.fillRect(520, 110, 15, 30); c.fillStyle = '#fff'; c.fillRect(520, 120, 15, 10);
        c.fillStyle = '#5baad4'; c.fillRect(545, 100, 20, 40); c.fillStyle = '#fff'; c.fillRect(545, 115, 20, 10);
    
      }
    ),
    Difference(
      'graphSpikeMissing',
      const Rect.fromLTWH(395.0, 130.0, 40, 40),
      const Offset(415, 150),
      (HtmlCanvas c) {
        
        c.fillStyle = '#0a1120'; c.fillRect(395, 135, 40, 35);
        c.strokeStyle = '#2b4f60'; c.lineWidth = 1; 
        c.beginPath(); c.moveTo(410, 135); c.lineTo(410, 170); c.stroke();
        c.beginPath(); c.moveTo(430, 135); c.lineTo(430, 170); c.stroke();
        c.beginPath(); c.moveTo(395, 150); c.lineTo(435, 150); c.stroke();
        c.strokeStyle = '#55ffae'; c.lineWidth = 2; c.beginPath(); c.moveTo(395, 150); c.lineTo(435, 150); c.stroke();
    
      }
    ),
    Difference(
      'ivBloodBag',
      const Rect.fromLTWH(130.0, 169.0, 40, 40),
      const Offset(150, 189),
      (HtmlCanvas c) {
        
        c.fillStyle = '#a8203a'; c.beginPath(); c.roundRect(132, 170, 36, 38, 8); c.fill(); 
    
      }
    ),
    Difference(
      'bedRailMissing',
      const Rect.fromLTWH(420.0, 305.0, 40, 40),
      const Offset(440, 325),
      (HtmlCanvas c) {
        
        final blG = c.createLinearGradient(350, 0, 600, 0);
        blG..addColorStop(0, '#5baad4'); blG..addColorStop(1, '#3b8ab4');
        c.fillStyle = blG; c.fillRect(435, 315, 10, 30);
    
      }
    )
  ];
}
