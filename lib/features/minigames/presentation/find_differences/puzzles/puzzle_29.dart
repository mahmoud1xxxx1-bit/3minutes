
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../html_canvas.dart';
import '../puzzle_model.dart';

class Puzzle29 extends PuzzleDefinition {
  @override
  int get id => 29;


  void drawPlate(HtmlCanvas c, double cx, double cy, String color, dynamic rimColor) {

    c.fillStyle = color; c.strokeStyle = rimColor; c.lineWidth = 6;
    c.beginPath(); c.ellipse(cx, cy, 60, 30, 0, 0, math.pi*2); c.fill(); c.stroke();
    c.beginPath(); c.ellipse(cx, cy+5, 45, 20, 0, 0, math.pi*2); c.stroke();

  }

  void drawNigiri(HtmlCanvas c, double cx, double cy, dynamic toppingColor) {

    c.fillStyle = '#f4f4f4'; 
    c.beginPath(); c.ellipse(cx, cy, 25, 12, 0, 0, math.pi*2); c.fill();
    c.fillStyle = toppingColor; 
    c.beginPath(); c.ellipse(cx+2, cy-5, 28, 14, 0, 0, math.pi*2); c.fill();
    c.strokeStyle = 'rgba(255,255,255,0.4)'; c.lineWidth = 2;
    c.beginPath(); c.moveTo(cx-15, cy-10); c.lineTo(cx+10, cy); c.stroke();
    c.beginPath(); c.moveTo(cx-5, cy-12); c.lineTo(cx+20, cy-2); c.stroke();

  }

  void drawMaki(HtmlCanvas c, double cx, double cy) {

    c.fillStyle = '#111'; 
    c.beginPath(); c.ellipse(cx, cy, 18, 18, 0, 0, math.pi*2); c.fill();
    c.fillStyle = '#f4f4f4'; 
    c.beginPath(); c.ellipse(cx, cy, 14, 14, 0, 0, math.pi*2); c.fill();
    c.fillStyle = '#ffaa00'; c.beginPath(); c.arc(cx-2, cy-2, 4, 0, math.pi*2); c.fill(); 
    c.fillStyle = '#55ffae'; c.beginPath(); c.arc(cx+3, cy+3, 3, 0, math.pi*2); c.fill();

  }


  @override
  void drawBaseScene(HtmlCanvas c) {
    
    c.fillStyle = '#e6dbc3'; c.fillRect(0,0,800,600); 
    c.fillStyle = '#2a1a12'; c.fillRect(0, 200, 800, 200); 
    c.fillStyle = '#111';
    for(double x=0; x<800; x+=40) {
        c.fillRect(x, 210, 35, 180); 
    }
    drawPlate(c, 150, 300, '#fff', '#2b4f60');
    drawNigiri(c, 135, 295, '#ff7b55'); drawNigiri(c, 165, 305, '#ff7b55');
    drawPlate(c, 400, 300, '#fff', '#e62244');
    drawMaki(c, 380, 295); drawMaki(c, 420, 295); drawMaki(c, 400, 310);
    drawPlate(c, 650, 300, '#fff', '#d4af37');
    drawNigiri(c, 635, 295, '#cc2233'); drawNigiri(c, 665, 305, '#cc2233');
    c.fillStyle = '#a62233'; c.beginPath(); c.roundRect(100, 480, 40, 80, 5); c.fill();
    c.fillStyle = '#222'; c.fillRect(110, 450, 20, 30);
    c.fillRect(100, 460, 10, 5); 
    c.fillStyle = '#fff'; c.beginPath(); c.ellipse(250, 530, 40, 20, 0, 0, math.pi*2); c.fill();
    c.fillStyle = '#111'; c.beginPath(); c.ellipse(250, 532, 30, 15, 0, 0, math.pi*2); c.fill(); 
    c.fillStyle = '#e62244'; c.beginPath(); c.roundRect(420, 550, 30, 15, 5); c.fill(); 
    c.fillStyle = '#d4af37'; 
    c.save(); c.translate(450, 545); c.rotate(-0.05);
    c.fillRect(-150, 0, 300, 6); c.fillRect(-150, 10, 300, 6);
    c.restore();
    c.fillStyle = '#4c8f5e'; c.beginPath(); c.ellipse(650, 500, 30, 15, 0.2, 0, math.pi*2); c.fill();
    c.fillStyle = '#aadd55'; c.beginPath(); c.ellipse(650, 500, 15, 10, 0, 0, math.pi*2); c.fill();

  }

  @override
  List<Difference> get differences => [
    
    Difference(
      'extraMaki',
      const Rect.fromLTWH(380.0, 260.0, 40, 40),
      const Offset(400, 280),
      (HtmlCanvas c) {
        
        drawMaki(c, 400, 280);
    
      }
    ),
    Difference(
      'wasabiDollop',
      const Rect.fromLTWH(122.0, 317.0, 16.0, 16.0),
      const Offset(130, 325),
      (HtmlCanvas c) {
        
        c.fillStyle = '#aadd55'; c.beginPath(); c.arc(130, 325, 8, 0, math.pi*2); c.fill();
    
      }
    ),
    Difference(
      'extraSushi',
      const Rect.fromLTWH(630.0, 255.0, 40, 40),
      const Offset(650, 275),
      (HtmlCanvas c) {
        
        c.fillStyle = '#ffaa00'; 
        c.beginPath(); c.ellipse(650, 275, 15, 8, 0, 0, math.pi*2); c.fill();
        c.fillStyle = '#111'; c.fillRect(645, 267, 10, 16); // nori band
    
      }
    ),
    Difference(
      'sauceDish',
      const Rect.fromLTWH(330.0, 510.0, 40, 40),
      const Offset(350, 530),
      (HtmlCanvas c) {
        
        c.fillStyle = '#fff'; c.beginPath(); c.ellipse(350, 530, 40, 20, 0, 0, math.pi*2); c.fill();
    
      }
    ),
    Difference(
      'chopstickDetail',
      const Rect.fromLTWH(565.0, 515.0, 40, 40),
      const Offset(585, 535),
      (HtmlCanvas c) {
        
        c.save(); c.translate(450, 545); c.rotate(-0.05);
        c.fillStyle = '#222'; c.fillRect(120, 0, 20, 6); c.fillRect(120, 10, 20, 6);
        c.restore();
    
      }
    )
  ];
}
