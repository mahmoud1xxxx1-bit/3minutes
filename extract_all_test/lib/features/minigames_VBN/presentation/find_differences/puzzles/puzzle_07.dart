
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../html_canvas.dart';
import '../puzzle_model.dart';

class Puzzle07 extends PuzzleDefinition {
  @override
  int get id => 7;

  @override
  void drawBaseScene(HtmlCanvas c) {
    
    // Walls & Tiles
    c.fillStyle = '#e8efe9'; c.fillRect(0,0,800,600);
    c.strokeStyle = '#c0c8c3'; c.lineWidth = 2;
    for(double i=0.0; i<800; i+=80) { c.beginPath(); c.moveTo(i, 0); c.lineTo(i, 600); c.stroke(); }
    for(double i=0.0; i<600; i+=80) { c.beginPath(); c.moveTo(0, i); c.lineTo(800, i); c.stroke(); }
    // Floor
    c.fillStyle = '#a5b2bc'; c.fillRect(0,480,800,120);
    // Bathtub
    c.fillStyle = '#fff'; c.beginPath(); c.roundRect(50, 350, 350, 130, 20); c.fill();
    c.fillStyle = '#5baad4'; c.fillRect(70, 370, 310, 20); // Water
    // Showerhead
    c.strokeStyle = '#a4b4c0'; c.lineWidth = 10; c.beginPath(); c.moveTo(100, 350); c.lineTo(100, 150); c.lineTo(150, 150); c.lineTo(150, 170); c.stroke();
    c.fillStyle = '#a4b4c0'; c.fillRect(130, 170, 40, 10);
    // Sink Cabinet
    c.fillStyle = '#2b4f60'; c.fillRect(500, 350, 200, 130);
    c.fillStyle = '#fff'; c.fillRect(490, 330, 220, 20); // Counter
    c.fillStyle = '#e2e2e2'; c.beginPath(); c.ellipse(600, 340, 60, 20, 0, 0, math.pi*2); c.fill(); // Sink basin
    // Mirror
    c.fillStyle = '#87ceeb'; c.fillRect(530, 100, 140, 180);
    c.strokeStyle = '#5a3d2b'; c.lineWidth = 8; c.strokeRect(530, 100, 140, 180);
    // Rubber Duck
    c.fillStyle = '#d4af37'; c.beginPath(); c.arc(300, 360, 15, 0, math.pi*2); c.fill();
    // Towel on Rack
    c.strokeStyle = '#a4b4c0'; c.lineWidth = 6; c.beginPath(); c.moveTo(380, 200); c.lineTo(460, 200); c.stroke();
    c.fillStyle = '#d14949'; c.fillRect(390, 200, 50, 80);
  }

  @override
  List<Difference> get differences => [
    
    Difference(
      'duckMissing',
      const Rect.fromLTWH(280.0, 340.0, 40, 40),
      const Offset(300, 360),
      (HtmlCanvas c) {
        
        c.fillStyle = '#e8efe9'; c.fillRect(280, 340, 40, 10); // wall redraw
        c.fillStyle = '#fff'; c.fillRect(280, 350, 40, 20); // tub redraw
        c.fillStyle = '#5baad4'; c.fillRect(280, 370, 40, 10); // water redraw
    
      }
    ),
    Difference(
      'mirrorFrameColor',
      const Rect.fromLTWH(510.0, 80.0, 40, 40),
      const Offset(530, 100),
      (HtmlCanvas c) {
        
        c.strokeStyle = '#a4b4c0'; c.lineWidth = 8; c.strokeRect(530, 100, 140, 180);
    
      }
    ),
    Difference(
      'towelColor',
      const Rect.fromLTWH(395.0, 220.0, 40, 40),
      const Offset(415, 240),
      (HtmlCanvas c) {
        
        c.fillStyle = '#4c8f5e'; c.fillRect(390, 200, 50, 80);
    
      }
    ),
    Difference(
      'showerWater',
      const Rect.fromLTWH(130.0, 240.0, 40, 40),
      const Offset(150, 260),
      (HtmlCanvas c) {
        
        c.strokeStyle = '#5baad4'; c.lineWidth = 2; 
        c.beginPath(); c.moveTo(140, 180); c.lineTo(140, 350); c.stroke();
        c.beginPath(); c.moveTo(160, 180); c.lineTo(160, 350); c.stroke();
    
      }
    ),
    Difference(
      'tileLineMissing',
      const Rect.fromLTWH(220.0, 180.0, 40, 40),
      const Offset(240, 200),
      (HtmlCanvas c) {
        
        c.fillStyle = '#e8efe9'; c.fillRect(238, 162, 4, 76);
    
      }
    )
  ];
}
