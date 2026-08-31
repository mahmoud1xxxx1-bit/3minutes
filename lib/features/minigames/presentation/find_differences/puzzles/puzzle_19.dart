
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../html_canvas.dart';
import '../puzzle_model.dart';

class Puzzle19 extends PuzzleDefinition {
  @override
  int get id => 19;



  @override
  void drawBaseScene(HtmlCanvas c) {
    
    c.fillStyle = '#a4b4c0'; c.fillRect(0,0,800,450); 
    final floorGrad = c.createLinearGradient(0,450,0,600);
    floorGrad.addColorStop(0, '#8a2b3b'); floorGrad.addColorStop(1, '#4a1525'); 
    c.fillStyle = floorGrad; c.fillRect(0, 450, 800, 150);
    c.fillStyle = '#e2e2e2'; 
    for(double x=50; x<800; x+=200) {
        c.fillRect(x, 0, 60, 450);
        c.fillRect(x-10, 430, 80, 20); 
        c.fillRect(x-10, 0, 80, 20); 
        c.fillStyle = '#d0d0d0'; c.fillRect(x+10, 0, 10, 450); c.fillRect(x+40, 0, 10, 450); c.fillStyle = '#e2e2e2'; 
    }
    c.fillStyle = '#3a251a'; c.beginPath(); c.moveTo(130, 400); c.lineTo(110, 500); c.lineTo(210, 500); c.lineTo(190, 400); c.fill(); 
    c.fillStyle = 'rgba(255,255,255,0.2)'; c.fillRect(135, 300, 50, 100); 
    c.strokeStyle = '#fff'; c.lineWidth = 2; c.strokeRect(135, 300, 50, 100);
    c.fillStyle = '#55ffae'; c.beginPath(); c.moveTo(160, 380); c.lineTo(145, 360); c.lineTo(175, 360); c.fill();
    c.fillStyle = '#fff'; c.beginPath(); c.moveTo(160, 380); c.lineTo(145, 360); c.lineTo(160, 350); c.fill();
    c.fillStyle = '#3a251a'; c.beginPath(); c.moveTo(350, 380); c.lineTo(330, 500); c.lineTo(470, 500); c.lineTo(450, 380); c.fill(); 
    c.fillStyle = '#e2e2e2'; c.beginPath(); c.moveTo(450, 300); c.lineTo(350, 300); c.lineTo(300, 350); c.lineTo(380, 360); c.lineTo(450, 320); c.fill();
    c.fillStyle = '#111'; c.beginPath(); c.arc(420, 315, 8, 0, math.pi*2); c.fill(); 
    c.fillStyle = '#e2e2e2'; 
    for(double i=0.0; i<4; i++) { c.beginPath(); c.moveTo(320+i*20, 350+i*3); c.lineTo(315+i*20, 370+i*3); c.lineTo(330+i*20, 350+i*3); c.fill(); }
    c.fillStyle = '#3a251a'; c.beginPath(); c.moveTo(600, 400); c.lineTo(580, 500); c.lineTo(680, 500); c.lineTo(660, 400); c.fill(); 
    c.fillStyle = '#d4af37'; c.beginPath(); c.ellipse(630, 320, 30, 50, 0, 0, math.pi*2); c.fill();
    c.fillStyle = '#2b4f60'; c.fillRect(605, 300, 50, 10); c.fillRect(601, 330, 58, 10); 
    c.fillStyle = '#d4af37'; c.fillRect(620, 260, 20, 20); 
    c.beginPath(); c.ellipse(630, 260, 20, 5, 0, 0, math.pi*2); c.fill(); 
    c.fillStyle = '#d4af37'; c.fillRect(155, 520, 10, 60); c.fillRect(395, 520, 10, 60); c.fillRect(625, 520, 10, 60);
    c.beginPath(); c.arc(160, 520, 8, 0, math.pi*2); c.arc(400, 520, 8, 0, math.pi*2); c.arc(630, 520, 8, 0, math.pi*2); c.fill();
    c.strokeStyle = '#d14949'; c.lineWidth = 8;
    c.beginPath(); c.moveTo(0, 530); c.quadraticCurveTo(80, 560, 160, 530); c.stroke();
    c.beginPath(); c.moveTo(160, 530); c.quadraticCurveTo(280, 560, 400, 530); c.stroke();
    c.beginPath(); c.moveTo(400, 530); c.quadraticCurveTo(515, 560, 630, 530); c.stroke();
    c.beginPath(); c.moveTo(630, 530); c.quadraticCurveTo(715, 560, 800, 530); c.stroke();

  }

  @override
  List<Difference> get differences => [
    
    Difference(
      'diamondColor',
      const Rect.fromLTWH(140.0, 350.0, 40, 40),
      const Offset(160, 370),
      (HtmlCanvas c) {
        
        c.fillStyle = '#ff5555'; c.beginPath(); c.moveTo(160, 380); c.lineTo(145, 360); c.lineTo(175, 360); c.fill();
        c.fillStyle = '#fff'; c.beginPath(); c.moveTo(160, 380); c.lineTo(145, 360); c.lineTo(160, 350); c.fill();
    
      }
    ),
    Difference(
      'skullEyeColor',
      const Rect.fromLTWH(412.0, 307.0, 16.0, 16.0),
      const Offset(420, 315),
      (HtmlCanvas c) {
        
        c.fillStyle = '#ff5555'; c.beginPath(); c.arc(420, 315, 8, 0, math.pi*2); c.fill(); 
    
      }
    ),
    Difference(
      'vaseStripeMissing',
      const Rect.fromLTWH(610.0, 285.0, 40, 40),
      const Offset(630, 305),
      (HtmlCanvas c) {
        
        c.fillStyle = '#d4af37'; c.fillRect(605, 300, 50, 10); 
    
      }
    ),
    Difference(
      'extraRopePost',
      const Rect.fromLTWH(272.0, 512.0, 16.0, 16.0),
      const Offset(280, 540),
      (HtmlCanvas c) {
        
        c.fillStyle = '#d4af37'; c.fillRect(275, 520, 10, 60);
        c.beginPath(); c.arc(280, 520, 8, 0, math.pi*2); c.fill();
    
      }
    ),
    Difference(
      'pedestalPlaque',
      const Rect.fromLTWH(380.0, 420.0, 40, 40),
      const Offset(400, 440),
      (HtmlCanvas c) {
        
        c.fillStyle = '#d4af37'; c.fillRect(380, 430, 40, 20);
    
      }
    )
  ];
}
