
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../html_canvas.dart';
import '../puzzle_model.dart';

class Puzzle10 extends PuzzleDefinition {
  @override
  int get id => 10;

  @override
  void drawBaseScene(HtmlCanvas c) {
    
    final grad = c.createLinearGradient(0,0,0,450);
    grad.addColorStop(0, '#0a1120'); grad.addColorStop(1, '#2b4f60');
    c.fillStyle = grad; c.fillRect(0,0,800,450);
    c.fillStyle = '#fff';
    for(double i=0.0; i<80; i++) { c.beginPath(); c.arc((i*41)%800, (i*71)%450, (i%3)+1, 0, math.pi*2); c.fill(); }
    c.fillStyle = '#eef6ff'; c.beginPath(); c.arc(100, 100, 40, 0, math.pi*2); c.fill();
    c.fillStyle = 'rgba(0,0,0,0.1)'; c.beginPath(); c.arc(90, 90, 8, 0, math.pi*2); c.arc(110, 110, 12, 0, math.pi*2); c.arc(85, 115, 6, 0, math.pi*2); c.fill(); 
    c.fillStyle = '#e2e2e2'; c.beginPath(); c.ellipse(400, 400, 500, 80, 0, 0, math.pi*2); c.fill();
    c.fillStyle = '#fff'; c.fillRect(0,420,800,180);
    c.beginPath(); c.ellipse(400, 420, 450, 60, 0, 0, math.pi*2); c.fill();
    c.fillStyle = '#4a2f20'; c.fillRect(450, 250, 220, 170);
    c.strokeStyle = '#2a1a12'; c.lineWidth = 3;
    for(double y=260; y<420; y+=15) { c.beginPath(); c.moveTo(450, y); c.lineTo(670, y); c.stroke(); }
    c.fillStyle = '#fff'; c.beginPath(); c.moveTo(420, 260); c.lineTo(560, 150); c.lineTo(700, 260); c.fill();
    c.fillStyle = '#e2e2e2'; c.beginPath(); c.moveTo(420, 260); c.lineTo(560, 150); c.lineTo(560, 160); c.lineTo(430, 265); c.fill(); 
    c.fillStyle = '#666'; c.fillRect(600, 120, 30, 80);
    c.fillStyle = '#fff'; c.fillRect(595, 120, 40, 15); 
    c.fillStyle = 'rgba(226,226,226,0.8)'; c.beginPath(); c.arc(620, 90, 20, 0, math.pi*2); c.arc(640, 60, 30, 0, math.pi*2); c.fill();
    c.fillStyle = '#3a251a'; c.fillRect(480, 300, 50, 50); c.fillRect(590, 300, 50, 50);
    c.fillStyle = '#d4af37'; c.fillRect(485, 305, 18, 18); c.fillRect(507, 305, 18, 18); c.fillRect(485, 327, 18, 18); c.fillRect(507, 327, 18, 18);
    c.fillRect(595, 305, 18, 18); c.fillRect(617, 305, 18, 18); c.fillRect(595, 327, 18, 18); c.fillRect(617, 327, 18, 18);
    c.fillStyle = '#fff'; c.fillRect(475, 350, 60, 10); c.fillRect(585, 350, 60, 10); 
    c.fillStyle = '#eef6ff'; c.beginPath(); c.moveTo(430, 260); c.lineTo(435, 290); c.lineTo(440, 260); c.fill();
    c.beginPath(); c.moveTo(680, 260); c.lineTo(685, 280); c.lineTo(690, 260); c.fill();
    void drawTree(tx, ty) {
        c.fillStyle = '#5a3d2b'; c.fillRect(tx-10, ty, 20, 40); 
        c.fillStyle = '#2d5c3a'; c.beginPath(); c.moveTo(tx-60, ty+10); c.lineTo(tx, ty-60); c.lineTo(tx+60, ty+10); c.fill();
        c.beginPath(); c.moveTo(tx-50, ty-30); c.lineTo(tx, ty-90); c.lineTo(tx+50, ty-30); c.fill();
        c.beginPath(); c.moveTo(tx-40, ty-70); c.lineTo(tx, ty-120); c.lineTo(tx+40, ty-70); c.fill();
        c.fillStyle = '#fff'; c.beginPath(); c.moveTo(tx-40, ty-70); c.lineTo(tx, ty-120); c.lineTo(tx-10, ty-80); c.fill(); 
    }
    drawTree(150, 350); drawTree(280, 380); drawTree(100, 450);
    c.fillStyle = '#e2e2e2'; c.beginPath(); c.arc(350, 520, 50, 0, math.pi*2); c.arc(350, 440, 40, 0, math.pi*2); c.arc(350, 370, 30, 0, math.pi*2); c.fill();
    c.fillStyle = '#fff'; c.beginPath(); c.arc(345, 515, 45, 0, math.pi*2); c.arc(345, 435, 35, 0, math.pi*2); c.arc(345, 365, 25, 0, math.pi*2); c.fill();
    c.fillStyle = '#222'; c.fillRect(325, 310, 50, 35); c.fillRect(310, 345, 80, 8); 
    c.fillStyle = '#d14949'; c.fillRect(325, 335, 50, 10); 
    c.fillStyle = '#c15886'; c.fillRect(325, 390, 50, 20); c.fillRect(360, 390, 20, 50); 
    c.fillStyle = '#e49032'; c.beginPath(); c.moveTo(350, 370); c.lineTo(390, 380); c.lineTo(350, 380); c.fill(); 
    c.fillStyle = '#222'; c.beginPath(); c.arc(340, 360, 3, 0, math.pi*2); c.arc(360, 360, 3, 0, math.pi*2); c.fill(); 
    c.beginPath(); c.arc(350, 430, 5, 0, math.pi*2); c.arc(350, 460, 5, 0, math.pi*2); c.fill(); 
    c.strokeStyle = '#5a3d2b'; c.lineWidth = 4; c.beginPath(); c.moveTo(310, 440); c.lineTo(260, 420); c.moveTo(390, 440); c.lineTo(440, 410); c.stroke(); 
    c.fillStyle = '#e2e2e2';
    for(double i=0.0; i<5; i++) { c.beginPath(); c.ellipse(600 + i*40, 550 - i*20, 15, 8, -math.pi/4, 0, math.pi*2); c.fill(); }
  }

  @override
  List<Difference> get differences => [
    
    Difference(
      'windowLightOff',
      const Rect.fromLTWH(474.0, 294.0, 40, 40),
      const Offset(494, 314),
      (HtmlCanvas c) {
        
        c.fillStyle = '#3a251a'; c.fillRect(485, 305, 18, 18);
    
      }
    ),
    Difference(
      'hatRibbonColor',
      const Rect.fromLTWH(330.0, 320.0, 40, 40),
      const Offset(350, 340),
      (HtmlCanvas c) {
        
        c.fillStyle = '#5baad4'; c.fillRect(325, 335, 50, 10);
    
      }
    ),
    Difference(
      'footprintMissing',
      const Rect.fromLTWH(660.0, 490.0, 40, 40),
      const Offset(680, 510),
      (HtmlCanvas c) {
        
        c.fillStyle = '#fff'; c.beginPath(); c.ellipse(680, 510, 20, 12, -math.pi/4, 0, math.pi*2); c.fill();
    
      }
    ),
    Difference(
      'snowmanScarfColor',
      const Rect.fromLTWH(330.0, 380.0, 40, 40),
      const Offset(350, 400),
      (HtmlCanvas c) {
        
        c.fillStyle = '#4c8f5e'; c.fillRect(325, 390, 50, 20); c.fillRect(360, 390, 20, 50); 
    
      }
    ),
    Difference(
      'extraMoonCrater',
      const Rect.fromLTWH(108.0, 88.0, 14.0, 14.0),
      const Offset(115, 95),
      (HtmlCanvas c) {
        
        c.fillStyle = 'rgba(0,0,0,0.1)'; c.beginPath(); c.arc(115, 95, 7, 0, math.pi*2); c.fill();
    
      }
    )
  ];
}
