
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../html_canvas.dart';
import '../puzzle_model.dart';

class Puzzle28 extends PuzzleDefinition {
  @override
  int get id => 28;


  void drawChipStack(HtmlCanvas c, double cx, double cy, double count, String color) {

    for(double i=0.0; i<count; i++) {
        c.fillStyle = color; c.strokeStyle = '#fff'; c.lineWidth = 2;
        c.beginPath(); c.ellipse(cx, cy - i*6, 20, 10, 0, 0, math.pi*2); c.fill(); c.stroke();
        c.fillStyle = '#fff';
        c.fillRect(cx-4, cy - i*6 - 10, 8, 4); c.fillRect(cx-4, cy - i*6 + 6, 8, 4);
    }

  }


  @override
  void drawBaseScene(HtmlCanvas c) {
    
    c.fillStyle = '#0f4d2a'; c.fillRect(0,0,800,600);
    c.strokeStyle = '#fff'; c.lineWidth = 3;
    c.strokeRect(300, 50, 450, 200);
    for(double x=300; x<=750; x+=50) { c.beginPath(); c.moveTo(x, 50); c.lineTo(x, 250); c.stroke(); }
    for(double y=50; y<=250; y+=50) { c.beginPath(); c.moveTo(300, y); c.lineTo(750, y); c.stroke(); }
    c.fillStyle = '#fff'; c.font = '20px sans-serif'; c.textAlign = 'center'; c.textBaseline = 'middle';
    double num = 1;
    for(double y=75; y<=225; y+=50) {
        for(double x=325; x<=725; x+=50) {
            c.fillStyle = (num%2==0) ? '#ff2222' : '#222';
            c.beginPath(); c.arc(x, y, 15, 0, math.pi*2); c.fill();
            c.fillStyle = '#fff'; c.fillText(num.toInt().toString(), x, y);
            num++;
        }
    }
    double wx = 150, wy = 300;
    c.fillStyle = '#4a2f20'; c.beginPath(); c.arc(wx, wy, 130, 0, math.pi*2); c.fill(); c.stroke();
    for(double i=0.0; i<36; i++) {
        double a1 = i*math.pi*2/36; double a2 = (i+1)*math.pi*2/36;
        c.fillStyle = (i==0) ? '#00aa55' : (i%2==0 ? '#ff2222' : '#222');
        c.beginPath(); c.moveTo(wx, wy); c.arc(wx, wy, 100, a1, a2); c.fill();
    }
    c.fillStyle = '#d4af37'; c.beginPath(); c.arc(wx, wy, 70, 0, math.pi*2); c.fill();
    c.fillStyle = '#222'; c.beginPath(); c.arc(wx, wy, 30, 0, math.pi*2); c.fill();
    c.strokeStyle = '#d4af37'; c.lineWidth = 4;
    c.save();
    for(double i=0.0; i<4; i++) {
        c.beginPath(); c.moveTo(wx-30, wy); c.lineTo(wx+30, wy); c.stroke();
        c.translate(wx, wy); c.rotate(math.pi/4); c.translate(-wx, -wy);
    }
    c.restore();
    c.fillStyle = '#fff'; c.shadowBlur = 5; c.shadowColor = '#000';
    double ba = math.pi/3; c.beginPath(); c.arc(wx+math.cos(ba)*85, wy+math.sin(ba)*85, 6, 0, math.pi*2); c.fill();
    c.shadowBlur = 0;
    drawChipStack(c, 400, 400, 5, '#ff2222');
    drawChipStack(c, 450, 420, 3, '#222');
    drawChipStack(c, 350, 450, 8, '#2266ff');
    drawChipStack(c, 550, 350, 4, '#ffaa00');
    c.fillStyle = '#fff'; c.strokeStyle = '#222'; c.lineWidth = 1;
    c.save(); c.translate(650, 450); c.rotate(-0.2);
    c.beginPath(); c.roundRect(-25, -35, 50, 70, 5); c.fill(); c.stroke();
    c.fillStyle = '#ff2222'; c.font = '16px serif'; c.fillText('A♥', 0, 0);
    c.restore();

  }

  @override
  List<Difference> get differences => [
    
    Difference(
      'extraChip',
      const Rect.fromLTWH(330.0, 375.0, 40, 40),
      const Offset(350, 395),
      (HtmlCanvas c) {
        
        drawChipStack(c, 350, 450 - 8*6, 1, '#2266ff'); 
    
      }
    ),
    Difference(
      'extraCard',
      const Rect.fromLTWH(680.0, 480.0, 40, 40),
      const Offset(700, 500),
      (HtmlCanvas c) {
        
        c.fillStyle = '#fff'; c.strokeStyle = '#222'; c.lineWidth = 1;
        c.save(); c.translate(700, 500); c.rotate(0.3);
        c.beginPath(); c.roundRect(-25, -35, 50, 70, 5); c.fill(); c.stroke();
        c.fillStyle = '#222'; c.font = '16px serif'; c.textAlign = 'center'; c.textBaseline = 'middle'; c.fillText('10♠', 0, 0);
        c.restore();
    
      }
    ),
    Difference(
      'dice',
      const Rect.fromLTWH(488.0, 488.0, 4.0, 4.0),
      const Offset(495, 495),
      (HtmlCanvas c) {
        
        c.fillStyle = '#ff2222'; c.strokeStyle = '#fff'; c.lineWidth = 2;
        c.beginPath(); c.roundRect(485, 485, 20, 20, 3); c.fill(); c.stroke();
        c.fillStyle = '#fff';
        c.beginPath(); c.arc(490, 490, 2, 0, math.pi*2); c.fill();
        c.beginPath(); c.arc(500, 500, 2, 0, math.pi*2); c.fill();
        c.beginPath(); c.arc(495, 495, 2, 0, math.pi*2); c.fill();
        c.beginPath(); c.arc(490, 500, 2, 0, math.pi*2); c.fill();
        c.beginPath(); c.arc(500, 490, 2, 0, math.pi*2); c.fill();
    
      }
    ),
    Difference(
      'extraBall',
      const Rect.fromLTWH(70.0, 220.0, 40, 40),
      const Offset(90, 240),
      (HtmlCanvas c) {
        
        c.fillStyle = '#fff'; c.shadowBlur = 5; c.shadowColor = '#000';
        double ba = math.pi + math.pi/4; double wx = 150, wy = 300;
        c.beginPath(); c.arc(wx+math.cos(ba)*85, wy+math.sin(ba)*85, 6, 0, math.pi*2); c.fill();
        c.shadowBlur = 0;
    
      }
    ),
    Difference(
      'goldCoin',
      const Rect.fromLTWH(330.0, 80.0, 40, 40),
      const Offset(350, 100),
      (HtmlCanvas c) {
        
        c.fillStyle = '#d4af37'; c.beginPath(); c.ellipse(350, 100, 15, 8, 0, 0, math.pi*2); c.fill();
        c.fillStyle = '#f4d03f'; c.beginPath(); c.ellipse(350, 98, 12, 6, 0, 0, math.pi*2); c.fill();
    
      }
    )
  ];
}
