
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../html_canvas.dart';
import '../puzzle_model.dart';

class Puzzle13 extends PuzzleDefinition {
  @override
  int get id => 13;



  @override
  void drawBaseScene(HtmlCanvas c) {
    
    c.fillStyle = '#1b2c49'; c.fillRect(0,0,800,600); 
    c.fillStyle = '#222'; c.beginPath(); c.roundRect(100, 40, 600, 200, 10); c.fill(); 
    c.strokeStyle = '#5a3d2b'; c.lineWidth = 15; c.strokeRect(100, 40, 600, 200); 
    c.fillStyle = 'rgba(255,255,255,0.7)'; c.font = '24px monospace';
    c.fillText('E = mc^2', 150, 100); c.fillText('H2O + CO2 -> H2CO3', 150, 150);
    c.beginPath(); c.arc(500, 120, 40, 0, math.pi*2); c.stroke(); 
    c.beginPath(); c.moveTo(500, 80); c.lineTo(530, 60); c.stroke();
    c.fillStyle = '#3a251a'; c.fillRect(0, 350, 800, 250);
    c.fillStyle = '#111'; c.fillRect(0, 350, 800, 20); 
    c.fillStyle = '#a4b4c0'; c.fillRect(0, 330, 800, 20); 
    c.fillStyle = '#666'; c.fillRect(600, 310, 40, 20); 
    c.fillRect(610, 250, 20, 60); 
    c.fillStyle = '#d14949'; c.beginPath(); c.ellipse(620, 220, 15, 30, 0, 0, math.pi*2); c.fill(); 
    c.fillStyle = '#f4d03f'; c.beginPath(); c.ellipse(620, 230, 8, 20, 0, 0, math.pi*2); c.fill(); 
    c.fillStyle = 'rgba(255,255,255,0.3)';
    c.beginPath(); c.moveTo(250, 180); c.lineTo(250, 230); c.lineTo(150, 330); c.lineTo(350, 330); c.lineTo(250, 230); c.fill();
    final l1G = c.createLinearGradient(0,250,0,330); l1G.addColorStop(0, 'rgba(209,73,73,0.8)'); l1G.addColorStop(1, 'rgba(168,32,58,0.8)');
    c.fillStyle = l1G; c.beginPath(); c.moveTo(250, 270); c.lineTo(180, 320); c.lineTo(320, 320); c.lineTo(250, 270); c.fill(); 
    c.strokeStyle = '#fff'; c.lineWidth = 4;
    c.beginPath(); c.moveTo(230, 180); c.lineTo(230, 230); c.lineTo(160, 330); c.lineTo(340, 330); c.lineTo(270, 230); c.lineTo(270, 180); c.stroke();
    c.fillStyle = 'rgba(255,255,255,0.6)';
    c.beginPath(); c.arc(250, 310, 8, 0, math.pi*2); c.arc(230, 290, 5, 0, math.pi*2); c.arc(270, 300, 6, 0, math.pi*2); c.fill();
    c.fillStyle = 'rgba(255,255,255,0.3)'; c.beginPath(); c.arc(450, 280, 50, 0, math.pi*2); c.fillRect(430, 170, 40, 70); c.fill();
    c.fillStyle = 'rgba(91,170,212,0.8)'; c.beginPath(); c.arc(450, 280, 45, 0, math.pi); c.fill(); 
    c.strokeStyle = '#fff'; c.lineWidth = 4; c.beginPath(); c.arc(450, 280, 50, 0, math.pi*2); c.stroke();
    c.fillStyle = '#d4af37'; c.fillRect(425, 160, 50, 15);
    c.fillStyle = '#222'; c.beginPath(); c.arc(100, 320, 30, math.pi, 0); c.fill(); 
    c.fillRect(90, 200, 20, 100); 
    c.fillStyle = '#a4b4c0'; c.fillRect(50, 240, 50, 15); 
    c.fillStyle = '#d4af37'; c.fillRect(80, 190, 40, 15); c.fillRect(85, 205, 10, 30); 

  }

  @override
  List<Difference> get differences => [
    
    Difference(
      'liquidColor',
      const Rect.fromLTWH(405.0, 235.0, 90.0, 90.0),
      const Offset(450, 290),
      (HtmlCanvas c) {
        
        c.fillStyle = 'rgba(76,143,94,0.9)'; c.beginPath(); c.arc(450, 280, 45, 0, math.pi); c.fill();
    
      }
    ),
    Difference(
      'extraBubble',
      const Rect.fromLTWH(203.0, 298.0, 14.0, 14.0),
      const Offset(210, 305),
      (HtmlCanvas c) {
        
        c.fillStyle = 'rgba(255,255,255,0.8)'; c.beginPath(); c.arc(210, 305, 7, 0, math.pi*2); c.fill();
    
      }
    ),
    Difference(
      'chalkEquation',
      const Rect.fromLTWH(250.0, 90.0, 40, 40),
      const Offset(270, 110),
      (HtmlCanvas c) {
        c.fillStyle = '#222'; c.fillRect(145, 95, 200, 35); 
        c.fillStyle = 'rgba(255,255,255,0.7)'; c.font = '24px monospace'; c.fillText('E = mc^9', 150, 100);
      }
    ),
    Difference(
      'burnerFlame',
      const Rect.fromLTWH(600.0, 210.0, 40, 40),
      const Offset(620, 230),
      (HtmlCanvas c) {
        
        c.fillStyle = '#55ffae'; c.beginPath(); c.ellipse(620, 220, 15, 30, 0, 0, math.pi*2); c.fill(); 
        c.fillStyle = '#2b4f60'; c.beginPath(); c.ellipse(620, 230, 8, 20, 0, 0, math.pi*2); c.fill(); 
    
      }
    ),
    Difference(
      'microscopeLensColor',
      const Rect.fromLTWH(80.0, 190.0, 40, 40),
      const Offset(100, 210),
      (HtmlCanvas c) {
        
        c.fillStyle = '#d14949'; c.fillRect(80, 190, 40, 15); c.fillRect(85, 205, 10, 30);
    
      }
    )
  ];
}
