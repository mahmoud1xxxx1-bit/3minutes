
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../html_canvas.dart';
import '../puzzle_model.dart';

class Puzzle16 extends PuzzleDefinition {
  @override
  int get id => 16;



  @override
  void drawBaseScene(HtmlCanvas c) {
    
    c.fillStyle = '#2a1a12'; c.fillRect(0,0,800,600);
    c.fillStyle = '#4a2f20'; 
    for(double y=50; y<=550; y+=150) { c.fillRect(0, y, 800, 20); } 
    for(double x=250; x<=550; x+=300) { c.fillRect(x, 0, 20, 600); } 
    final colors = ['#8a2b3b', '#2b4f60', '#4c8f5e', '#d4af37', '#a67c52'];
    for(double shelf=0; shelf<3; shelf++) {
        for(double sec=0; sec<3; sec++) {
            double startX = (sec==0)?20:(sec==1?290:590);
            for(double i=0.0; i<10; i++) {
                double bx = startX + i*22;
                double h = 70 + ((shelf*7 + sec*3 + i)*13)%40;
                double by = 50 + shelf*150 - h;
                c.fillStyle = colors[((shelf+sec+i)%5).toInt()];
                c.fillRect(bx, by, 18, h);
                c.fillStyle = '#e2e2e2'; c.fillRect(bx+2, by+10, 14, 5); 
            }
        }
    }
    c.fillStyle = '#3a251a'; c.fillRect(0, 500, 800, 100);
    c.fillStyle = '#a67c52'; c.fillRect(200, 450, 400, 20); 
    c.fillStyle = '#2a1a12'; c.fillRect(250, 470, 20, 130); c.fillRect(530, 470, 20, 130); 
    c.fillStyle = '#d4af37'; c.beginPath(); c.ellipse(300, 450, 30, 10, 0, 0, math.pi*2); c.fill(); 
    c.fillRect(295, 370, 10, 80); 
    c.fillStyle = '#4c8f5e'; c.beginPath(); c.roundRect(260, 350, 80, 30, 15); c.fill(); 
    c.fillStyle = '#eef6ff'; c.beginPath(); c.ellipse(300, 380, 35, 8, 0, 0, math.pi*2); c.fill();
    c.fillStyle = '#e2e2e2'; c.beginPath(); c.moveTo(450, 440); c.lineTo(400, 430); c.lineTo(450, 400); c.lineTo(500, 410); c.fill(); 
    c.beginPath(); c.moveTo(450, 440); c.lineTo(500, 430); c.lineTo(550, 400); c.lineTo(500, 410); c.fill(); 
    c.strokeStyle = '#222'; c.lineWidth = 2; c.beginPath(); c.moveTo(420, 430); c.lineTo(440, 415); c.stroke(); 

  }

  @override
  List<Difference> get differences => [
    
    Difference(
      'bookColor',
      const Rect.fromLTWH(367.0, 130.0, 40, 40),
      const Offset(387, 150),
      (HtmlCanvas c) {
        
        double bx = 378, by = 108, h = 92;
        c.fillStyle = '#c15886'; c.fillRect(bx, by, 18, h);
        c.fillStyle = '#e2e2e2'; c.fillRect(bx+2, by+10, 14, 5);
    
      }
    ),
    Difference(
      'lampShadeColor',
      const Rect.fromLTWH(260.0, 350.0, 80.0, 30.0),
      const Offset(300, 365),
      (HtmlCanvas c) {
        c.fillStyle = '#8a2b3b'; c.beginPath(); c.roundRect(260, 350, 80, 30, 15); c.fill();
      }
    ),
    Difference(
      'extraBookOnDesk',
      const Rect.fromLTWH(340.0, 422.0, 40, 40),
      const Offset(360, 442),
      (HtmlCanvas c) {
        
        c.fillStyle = '#2b4f60'; c.fillRect(340, 435, 40, 15);
        c.fillStyle = '#d4af37'; c.fillRect(340, 440, 40, 5); 
    
      }
    ),
    Difference(
      'deskDrawer',
      const Rect.fromLTWH(396.0, 476.0, 8.0, 8.0),
      const Offset(400, 480),
      (HtmlCanvas c) {
        
        c.fillStyle = '#2a1a12'; c.fillRect(360, 470, 80, 20);
        c.fillStyle = '#d4af37'; c.beginPath(); c.arc(400, 480, 4, 0, math.pi*2); c.fill();
    
      }
    ),
    Difference(
      'coffeeCup',
      const Rect.fromLTWH(200.0, 420.0, 30.0, 30.0),
      const Offset(215, 435),
      (HtmlCanvas c) {
        c.fillStyle = '#eef6ff'; c.fillRect(205, 425, 20, 25);
        c.strokeStyle = '#eef6ff'; c.lineWidth = 3; c.beginPath(); c.arc(225, 435, 8, -math.pi/2, math.pi/2); c.stroke();
      }
    )
  ];
}
