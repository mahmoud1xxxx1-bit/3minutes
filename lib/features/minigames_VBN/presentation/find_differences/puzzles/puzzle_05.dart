
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../html_canvas.dart';
import '../puzzle_model.dart';

class Puzzle05 extends PuzzleDefinition {
  @override
  int get id => 5;



  @override
  void drawBaseScene(HtmlCanvas c) {
    
    // Walls
    c.fillStyle = '#e8efe9'; c.fillRect(0,0,800,450);
    // Floor
    c.fillStyle = '#c0c8c3'; c.fillRect(0,450,800,150);
    // Rug
    c.fillStyle = '#c15886'; c.beginPath(); c.ellipse(400, 520, 250, 60, 0, 0, math.pi*2); c.fill();
    // Bed
    c.fillStyle = '#5a3d2b'; c.fillRect(250, 280, 300, 150); // Frame
    c.fillStyle = '#e2e2e2'; c.fillRect(260, 290, 280, 130); // Mattress
    c.fillStyle = '#4c8f5e'; c.fillRect(260, 340, 280, 80); // Blanket
    c.fillStyle = '#fff'; c.beginPath(); c.roundRect(280, 300, 60, 30, 10); c.roundRect(460, 300, 60, 30, 10); c.fill(); // Pillows
    // Nightstand
    c.fillStyle = '#5a3d2b'; c.fillRect(150, 360, 80, 70);
    // Lamp
    c.fillStyle = '#d4af37'; c.beginPath(); c.moveTo(190, 300); c.lineTo(210, 330); c.lineTo(170, 330); c.fill(); // Shade
    c.fillStyle = '#222'; c.fillRect(188, 330, 4, 30); // Stand
    // Wardrobe
    c.fillStyle = '#fff'; c.fillRect(600, 150, 150, 280);
    c.strokeStyle = '#d0d0d0'; c.lineWidth = 2; c.strokeRect(600, 150, 75, 280); c.strokeRect(675, 150, 75, 280);
    c.fillStyle = '#888'; c.fillRect(665, 280, 5, 30); c.fillRect(680, 280, 5, 30); // Handles
    // Painting
    c.fillStyle = '#5a3d2b'; c.fillRect(350, 100, 100, 80);
    c.fillStyle = '#fff'; c.fillRect(355, 105, 90, 70);
    c.fillStyle = '#5baad4'; c.beginPath(); c.arc(400, 140, 20, 0, math.pi*2); c.fill();
    // Window
    c.fillStyle = '#2b4f60'; c.fillRect(50, 100, 120, 160);
    c.fillStyle = '#fff'; c.beginPath(); c.arc(100, 140, 15, 0, math.pi*2); c.fill(); // Moon

  }

  @override
  List<Difference> get differences => [
    
    Difference(
      'extraPillow',
      const Rect.fromLTWH(380.0, 295.0, 40, 40),
      const Offset(400, 315),
      (HtmlCanvas c) {
         c.fillStyle = '#fff'; c.beginPath(); c.roundRect(370, 300, 60, 30, 10); c.fill(); 
      }
    ),
    Difference(
      'lampColor',
      const Rect.fromLTWH(170.0, 300.0, 40, 40),
      const Offset(190, 320),
      (HtmlCanvas c) {
        
        c.fillStyle = '#d14949'; c.beginPath(); c.moveTo(190, 300); c.lineTo(210, 330); c.lineTo(170, 330); c.fill(); 
    
      }
    ),
    Difference(
      'wardrobeHandleMissing',
      const Rect.fromLTWH(662.0, 275.0, 40, 40),
      const Offset(682, 295),
      (HtmlCanvas c) {
        
        c.fillStyle = '#fff'; c.fillRect(678, 275, 10, 40); 
    
      }
    ),
    Difference(
      'paintingSunColor',
      const Rect.fromLTWH(380.0, 120.0, 40.0, 40.0),
      const Offset(400, 140),
      (HtmlCanvas c) {
        
        c.fillStyle = '#d14949'; c.beginPath(); c.arc(400, 140, 20, 0, math.pi*2); c.fill();
    
      }
    ),
    Difference(
      'windowStar',
      const Rect.fromLTWH(131.0, 121.0, 8.0, 8.0),
      const Offset(135, 125),
      (HtmlCanvas c) {
        
        c.fillStyle = '#fff'; c.beginPath(); c.arc(135, 125, 4, 0, math.pi*2); c.fill();
    
      }
    )
  ];
}
