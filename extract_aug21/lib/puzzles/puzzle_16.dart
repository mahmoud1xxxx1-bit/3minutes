
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
    c.fillStyle = '#d4af37'; c.beginPath(); c.arc(300, 450, 15, math.pi, 0); c.fill(); 
    c.fillRect(295, 350, 10, 100); 
    c.fillStyle = '#4c8f5e'; c.beginPath(); c.arc(300, 350, 30, math.pi, 0); c.fill(); 
    c.fillStyle = '#eef6ff'; c.beginPath(); c.arc(300, 350, 15, 0, math.pi); c.fill(); 
    c.fillStyle = 'rgba(244,208,63,0.3)'; c.beginPath(); c.moveTo(280, 350); c.lineTo(150, 450); c.lineTo(450, 450); c.lineTo(320, 350); c.fill();
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
      const Rect.fromLTWH(270.0, 320.0, 60.0, 60.0),
      const Offset(300, 335),
      (HtmlCanvas c) {
        
        c.fillStyle = '#8a2b3b'; c.beginPath(); c.arc(300, 350, 30, math.pi, 0); c.fill(); 
    
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
      'lightBeamMagic',
      const Rect.fromLTWH(280.0, 390.0, 40, 40),
      const Offset(300, 410),
      (HtmlCanvas c) {
        
        c.fillStyle = 'rgba(85,255,174,0.3)'; c.beginPath(); c.moveTo(280, 350); c.lineTo(150, 450); c.lineTo(450, 450); c.lineTo(320, 350); c.fill();
    
      }
    )
  ];
}
