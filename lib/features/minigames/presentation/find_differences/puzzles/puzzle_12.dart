
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../html_canvas.dart';
import '../puzzle_model.dart';

class Puzzle12 extends PuzzleDefinition {
  @override
  int get id => 12;



  @override
  void drawBaseScene(HtmlCanvas c) {
    
    for(double y=0; y<600; y+=40) {
        for(double x=0; x<800; x+=100) {
            c.fillStyle = ((x+y)%80 == 0) ? '#4a2f20' : '#3a251a';
            c.fillRect(x, y, 100, 40);
            c.strokeStyle = '#2a1a12'; c.lineWidth = 2; c.strokeRect(x, y, 100, 40);
            c.strokeStyle = '#2a1a12'; c.lineWidth = 1;
            c.beginPath(); c.moveTo(x+10, y+10); c.lineTo(x+90, y+10); c.stroke();
            c.beginPath(); c.moveTo(x+20, y+30); c.lineTo(x+80, y+30); c.stroke();
        }
    }
    void drawChair(cx, cy, angle) {
        c.save(); c.translate(cx, cy); c.rotate(angle);
        c.fillStyle = '#8a2b3b'; c.beginPath(); c.roundRect(-40, -60, 80, 50, 15); c.fill(); 
        c.fillStyle = '#631d28'; c.beginPath(); c.roundRect(-40, -60, 80, 40, 10); c.fill(); 
        c.fillStyle = '#4a1525';
        c.beginPath(); c.arc(-20, -40, 4, 0, math.pi*2); c.arc(0, -40, 4, 0, math.pi*2); c.arc(20, -40, 4, 0, math.pi*2); c.fill();
        c.restore();
    }
    drawChair(400, 80, 0); drawChair(400, 520, math.pi); drawChair(150, 300, -math.pi/2); drawChair(650, 300, math.pi/2);
    c.fillStyle = '#fff'; c.shadowColor = 'rgba(0,0,0,0.5)'; c.shadowBlur = 30;
    c.beginPath(); c.arc(400, 300, 220, 0, math.pi*2); c.fill();
    c.shadowBlur = 0; 
    c.strokeStyle = '#e2e2e2'; c.lineWidth = 3; c.setLineDash([10, 5]);
    c.beginPath(); c.arc(400, 300, 210, 0, math.pi*2); c.stroke(); c.setLineDash([]);
    c.fillStyle = '#d4af37'; c.beginPath(); c.arc(400, 300, 40, 0, math.pi*2); c.fill(); 
    c.fillStyle = '#4c8f5e'; 
    for(double i=0.0; i<8; i++) {
        double a = i * math.pi/4;
        c.beginPath(); c.ellipse(400 + math.cos(a)*40, 300 + math.sin(a)*40, 20, 8, a, 0, math.pi*2); c.fill();
    }
    c.fillStyle = '#d14949'; 
    for(double i=0.0; i<5; i++) {
        double a = i * math.pi*2/5;
        c.beginPath(); c.arc(400 + math.cos(a)*25, 300 + math.sin(a)*25, 12, 0, math.pi*2); c.fill();
        c.fillStyle = '#a8203a'; c.beginPath(); c.arc(400 + math.cos(a)*25, 300 + math.sin(a)*25, 6, 0, math.pi*2); c.fill(); c.fillStyle = '#d14949';
    }
    c.fillStyle = '#fff'; c.beginPath(); c.arc(400, 300, 8, 0, math.pi*2); c.fill(); 
    c.fillStyle = '#f4d03f'; c.beginPath(); c.arc(400, 300, 4, 0, math.pi*2); c.fill(); 
    void drawSetting(cx, cy, angle, foodType) {
        c.save(); c.translate(cx, cy); c.rotate(angle);
        c.fillStyle = '#d4af37'; c.beginPath(); c.arc(0, 0, 50, 0, math.pi*2); c.fill(); 
        c.fillStyle = '#fff'; c.beginPath(); c.arc(0, 0, 40, 0, math.pi*2); c.fill(); 
        c.strokeStyle = '#e2e2e2'; c.lineWidth = 2; c.beginPath(); c.arc(0, 0, 30, 0, math.pi*2); c.stroke(); 
        c.fillStyle = '#c0c8c3'; 
        c.fillRect(-70, -25, 8, 50); 
        c.fillRect(-70, -35, 2, 10); c.fillRect(-67, -35, 2, 10); c.fillRect(-64, -35, 2, 10); 
        c.fillRect(60, -25, 10, 50); 
        c.fillStyle = '#e2e2e2'; c.fillRect(60, -40, 8, 20); 
        c.fillStyle = '#c0c8c3'; c.fillRect(80, -25, 6, 40); c.beginPath(); c.ellipse(83, -30, 6, 10, 0, 0, math.pi*2); c.fill(); 
        double gX = 60, gY = -60;
        final wineGrad = c.createRadialGradient(gX, gY, 2, gX, gY, 15);
        wineGrad.addColorStop(0, '#a8203a'); wineGrad.addColorStop(0.8, '#d14949'); wineGrad.addColorStop(1, 'rgba(255,255,255,0.6)');
        c.fillStyle = wineGrad; c.beginPath(); c.arc(gX, gY, 15, 0, math.pi*2); c.fill(); 
        final waterGrad = c.createRadialGradient(gX+30, gY+20, 2, gX+30, gY+20, 12);
        waterGrad.addColorStop(0, '#5baad4'); waterGrad.addColorStop(1, 'rgba(255,255,255,0.6)');
        c.fillStyle = waterGrad; c.beginPath(); c.arc(gX+30, gY+20, 12, 0, math.pi*2); c.fill(); 
        if(foodType == 0) {
            c.fillStyle = '#eef6ff'; c.beginPath(); c.moveTo(-20, 20); c.lineTo(0, -20); c.lineTo(20, 20); c.fill();
        } else if (foodType == 1) { 
            c.fillStyle = '#4a2f20'; c.beginPath(); c.roundRect(-20, -15, 40, 25, 5); c.fill();
            c.fillStyle = '#2a1a12'; c.fillRect(-15, -10, 30, 2); c.fillRect(-15, -5, 30, 2); c.fillRect(-15, 0, 30, 2);
            c.fillStyle = '#4c8f5e'; c.fillRect(-20, 15, 40, 5); c.fillRect(-20, 22, 40, 5); 
        } else if (foodType == 2) { 
            c.strokeStyle = '#f4d03f'; c.lineWidth = 3; 
            for(double j=0; j<8; j++) { c.beginPath(); c.ellipse(0, 0, 15+j, 10+j, j, 0, math.pi); c.stroke(); }
            c.fillStyle = '#d14949'; c.beginPath(); c.arc(0, 0, 15, 0, math.pi*2); c.fill(); 
            c.fillStyle = '#4c8f5e'; c.beginPath(); c.ellipse(5, 5, 8, 4, math.pi/4, 0, math.pi*2); c.fill(); 
        } else if (foodType == 3) { 
            c.fillStyle = '#111'; c.fillRect(-25, -10, 15, 20); c.fillRect(10, -10, 15, 20); 
            c.fillStyle = '#fff'; c.beginPath(); c.arc(-17.5, 0, 5, 0, math.pi*2); c.arc(17.5, 0, 5, 0, math.pi*2); c.fill();
            c.fillStyle = '#d14949'; c.beginPath(); c.arc(-17.5, 0, 2, 0, math.pi*2); c.arc(17.5, 0, 2, 0, math.pi*2); c.fill();
        }
        c.restore();
    }
    drawSetting(400, 170, 0, 1);       
    drawSetting(400, 430, math.pi, 2); 
    drawSetting(270, 300, -math.pi/2, 3); 
    drawSetting(530, 300, math.pi/2, 0);  

  }

  @override
  List<Difference> get differences => [
    
    Difference(
      'wineColorPoison',
      const Rect.fromLTWH(570.0, 340.0, 40, 40),
      const Offset(590, 360),
      (HtmlCanvas c) {
        
        c.save(); c.translate(530, 300); c.rotate(math.pi/2);
        double gX = 60, gY = -60;
        final wineGrad = c.createRadialGradient(gX, gY, 2, gX, gY, 15);
        wineGrad.addColorStop(0, '#2d5c3a'); wineGrad.addColorStop(0.8, '#4c8f5e'); wineGrad.addColorStop(1, 'rgba(255,255,255,0.6)');
        c.fillStyle = wineGrad; c.beginPath(); c.arc(gX, gY, 15, 0, math.pi*2); c.fill();
        c.restore();
    
      }
    ),
    Difference(
      'extraSushi',
      const Rect.fromLTWH(225.0, 280.0, 40, 40),
      const Offset(245, 300),
      (HtmlCanvas c) {
        
        c.save(); c.translate(270, 300); c.rotate(-math.pi/2);
        c.fillStyle = '#111'; c.fillRect(-7.5, -35, 15, 20);
        c.fillStyle = '#fff'; c.beginPath(); c.arc(0, -25, 5, 0, math.pi*2); c.fill();
        c.fillStyle = '#d14949'; c.beginPath(); c.arc(0, -25, 2, 0, math.pi*2); c.fill();
        c.restore();
    
      }
    ),
    Difference(
      'centerpieceRoseColor',
      const Rect.fromLTWH(360.0, 266.0, 40, 40),
      const Offset(380, 286),
      (HtmlCanvas c) {
        
        double a = 3 * math.pi*2/5; 
        c.fillStyle = '#d4af37'; c.beginPath(); c.arc(400 + math.cos(a)*25, 300 + math.sin(a)*25, 12, 0, math.pi*2); c.fill();
        c.fillStyle = '#a67c52'; c.beginPath(); c.arc(400 + math.cos(a)*25, 300 + math.sin(a)*25, 6, 0, math.pi*2); c.fill();
    
      }
    ),
    Difference(
      'forkTineMissing',
      const Rect.fromLTWH(445.0, 445.0, 40, 40),
      const Offset(465, 465),
      (HtmlCanvas c) {
        
        c.save(); c.translate(400, 430); c.rotate(math.pi);
        c.fillStyle = '#fff'; c.fillRect(-65, -36, 4, 12); 
        c.restore();
    
      }
    ),
    Difference(
      'steakAsparagusColor',
      const Rect.fromLTWH(380.0, 170.0, 40, 40),
      const Offset(400, 190),
      (HtmlCanvas c) {
        
        c.save(); c.translate(400, 170); c.rotate(0);
        c.fillStyle = '#d4af37'; c.fillRect(-20, 15, 40, 5); c.fillRect(-20, 22, 40, 5);
        c.restore();
    
      }
    )
  ];
}
