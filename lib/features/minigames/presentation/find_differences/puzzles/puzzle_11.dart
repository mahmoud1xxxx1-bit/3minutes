
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../html_canvas.dart';
import '../puzzle_model.dart';

class Puzzle11 extends PuzzleDefinition {
  @override
  int get id => 11;



  @override
  void drawBaseScene(HtmlCanvas c) {
    
    final ceilG = c.createLinearGradient(0,0,0,100);
    ceilG..addColorStop(0, '#f0f0f0'); ceilG..addColorStop(1, '#d0d0d0');
    c.fillStyle = ceilG; c.fillRect(0,0,800,100);
    c.fillStyle = '#fff'; c.shadowColor = '#fff'; c.shadowBlur = 20;
    c.fillRect(100, 30, 200, 20); c.fillRect(500, 30, 200, 20);
    c.shadowBlur = 0; 
    c.fillStyle = '#e8efe9'; c.fillRect(0, 100, 800, 400);
    c.strokeStyle = '#c7d6d1'; c.lineWidth = 2;
    for(double y=100; y<=500; y+=40) {
        c.beginPath(); c.moveTo(0, y); c.lineTo(800, y); c.stroke();
        for(double x=0; x<=800; x+=80) {
            c.beginPath(); c.moveTo(x + (y%80==0?40:0), y); c.lineTo(x + (y%80==0?40:0), y+40); c.stroke();
        }
    }
    final floorG = c.createLinearGradient(0,500,0,600);
    floorG..addColorStop(0, '#a4b4c0'); floorG..addColorStop(1, '#5b7898');
    c.fillStyle = floorG; c.fillRect(0,500,800,100);
    c.strokeStyle = '#fff'; c.lineWidth = 1;
    for(double i=-200; i<=1000; i+=80) {
        c.beginPath(); c.moveTo(i, 500); c.lineTo(i-(400-i)*0.4, 600); c.stroke();
    }
    c.fillStyle = '#2b4f60'; 
    c.fillRect(50, 150, 700, 350); 
    c.fillStyle = '#1b2c49';
    for(double x=60; x<750; x+=20) { c.fillRect(x, 150, 2, 350); } 
    void drawShelf(double y) {
        c.fillStyle = '#a5b2bc'; c.fillRect(40, y, 720, 20);
        c.fillStyle = '#e2e2e2'; c.fillRect(40, y, 720, 5); 
        c.fillStyle = '#f4d03f';
        for(double x=80; x<700; x+=120) { c.fillRect(x, y+5, 40, 12); }
        c.fillStyle = '#111'; c.font = 'bold 11px monospace';
        for(double x=80; x<700; x+=120) { c.fillText('\$3.99', x+4, y+15); }
    }
    // Top Shelf (250)
    drawShelf(250);
    for(double i=0.0; i<8; i++) {
        double x = 80 + i*80, y = 140; 
        c.fillStyle = (i%2==0) ? '#c15886' : '#d4af37'; 
        c.fillRect(x, y, 60, 110);
        c.fillStyle = '#fff'; c.beginPath(); c.arc(x+30, y+40, 20, 0, math.pi*2); c.fill(); 
        c.fillStyle = '#111'; c.fillRect(x+10, y+80, 40, 10); 
    }
    // Middle Shelf (380)
    drawShelf(380);
    for(double i=0.0; i<10; i++) {
        double x = 70 + i*65, y = 280; 
        c.fillStyle = (i%3==0) ? 'rgba(76,143,94,0.8)' : (i%3==1 ? 'rgba(209,73,73,0.8)' : 'rgba(91,170,212,0.8)');
        c.beginPath(); c.roundRect(x, y+30, 40, 70, 5); c.fill();
        c.beginPath(); c.moveTo(x+10, y+30); c.lineTo(x+15, y); c.lineTo(x+25, y); c.lineTo(x+30, y+30); c.fill(); 
        c.fillStyle = '#e2e2e2'; c.fillRect(x+12, y-5, 16, 8);
        c.fillStyle = '#fff'; c.fillRect(x, y+50, 40, 20);
        c.fillStyle = '#111'; c.fillRect(x+10, y+55, 20, 5);
        c.fillStyle = 'rgba(255,255,255,0.4)'; c.fillRect(x+5, y+35, 5, 60);
    }
    // Bottom Shelf (500)
    drawShelf(500);
    for(double i=0.0; i<12; i++) {
        double x = 70 + i*55, y = 430; 
        c.fillStyle = '#a4b4c0'; c.fillRect(x, y, 40, 70);
        c.fillStyle = '#d14949'; c.fillRect(x, y, 40, 35); 
        c.fillStyle = '#fff'; c.fillRect(x, y+35, 40, 35); 
        c.fillStyle = '#c0c8c3'; c.beginPath(); c.ellipse(x+20, y, 20, 5, 0, 0, math.pi*2); c.fill();
        c.fillStyle = '#111'; c.fillRect(x+10, y+50, 20, 5);
        c.fillStyle = '#d4af37'; c.beginPath(); c.arc(x+20, y+20, 10, 0, math.pi*2); c.fill(); 
    }
    c.fillStyle = '#3a251a'; c.fillRect(380, 0, 40, 50); 
    c.fillStyle = '#2b4f60'; c.beginPath(); c.roundRect(300, 50, 200, 60, 10); c.fill();
    c.textAlign = 'center';
    c.fillStyle = '#fff'; c.font = 'bold 36px sans-serif'; c.fillText('AISLE 4', 400, 65);
    c.textAlign = 'left';
  }

  @override
  List<Difference> get differences => [
    
    Difference(
      'signTextOff',
      const Rect.fromLTWH(380.0, 60.0, 40, 40),
      const Offset(400, 80),
      (HtmlCanvas c) {
        
        c.fillStyle = '#2b4f60'; c.beginPath(); c.roundRect(300, 50, 200, 60, 10); c.fill();
        c.textAlign = 'center';
        c.fillStyle = '#fff'; c.font = 'bold 36px sans-serif'; c.fillText('AISLE 5', 400, 65);
        c.textAlign = 'left';
    
      }
    ),
    Difference(
      'cerealBoxColor',
      const Rect.fromLTWH(330.0, 170.0, 40, 40),
      const Offset(350, 190),
      (HtmlCanvas c) {
        
        double x = 320, y = 140;
        c.fillStyle = '#4c8f5e'; c.fillRect(x, y, 60, 110);
        c.fillStyle = '#fff'; c.beginPath(); c.arc(x+30, y+40, 20, 0, math.pi*2); c.fill();
        c.fillStyle = '#111'; c.fillRect(x+10, y+80, 40, 10);
    
      }
    ),
    Difference(
      'sodaBottleCapColor',
      const Rect.fromLTWH(383.0, 255.0, 40, 40),
      const Offset(403, 275),
      (HtmlCanvas c) {
        
        double x = 395, y = 280;
        c.fillStyle = '#d14949'; c.fillRect(x+12, y-5, 16, 8); 
    
      }
    ),
    Difference(
      'soupCanLogoMissing',
      const Rect.fromLTWH(510.0, 430.0, 40, 40),
      const Offset(530, 450),
      (HtmlCanvas c) {
        
        double x = 510, y = 430;
        c.fillStyle = '#d14949'; c.beginPath(); c.arc(x+20, y+20, 11, 0, math.pi*2); c.fill(); 
    
      }
    ),
    Difference(
      'priceTagMissing',
      const Rect.fromLTWH(440.0, 370.0, 40, 40),
      const Offset(460, 390),
      (HtmlCanvas c) {
        
        double x = 440, y = 380; 
        c.fillStyle = '#a5b2bc'; c.fillRect(x, y+5, 40, 15); 
        c.fillStyle = '#e2e2e2'; c.fillRect(x, y, 40, 5); 
    
      }
    )
  ];
}
