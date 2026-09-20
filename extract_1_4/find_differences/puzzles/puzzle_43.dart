import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../html_canvas.dart';
import '../puzzle_model.dart';

class Puzzle43 extends PuzzleDefinition {
  @override
  int get id => 43;

  void drawHex(HtmlCanvas c, double x, double y, double r, String c1, String c2, String c3) {
    c.fillStyle = c1;
    c.beginPath(); c.moveTo(x, y); c.lineTo(x-r*0.866, y-r*0.5); c.lineTo(x, y-r); c.lineTo(x+r*0.866, y-r*0.5); c.fill();
    c.fillStyle = c2;
    c.beginPath(); c.moveTo(x, y); c.lineTo(x-r*0.866, y-r*0.5); c.lineTo(x-r*0.866, y+r*0.5); c.lineTo(x, y+r); c.fill();
    c.fillStyle = c3;
    c.beginPath(); c.moveTo(x, y); c.lineTo(x+r*0.866, y-r*0.5); c.lineTo(x+r*0.866, y+r*0.5); c.lineTo(x, y+r); c.fill();
    
    c.strokeStyle = '#000000'; c.lineWidth = 2;
    c.beginPath(); 
    for(int i=0; i<=6; i++) {
      double a = i * math.pi/3 - math.pi/6;
      if (i==0) c.moveTo(x + math.cos(a)*r, y + math.sin(a)*r);
      else c.lineTo(x + math.cos(a)*r, y + math.sin(a)*r);
    }
    c.stroke();
    c.beginPath(); c.moveTo(x, y); c.lineTo(x, y+r); c.stroke();
    c.beginPath(); c.moveTo(x, y); c.lineTo(x-r*0.866, y-r*0.5); c.stroke();
    c.beginPath(); c.moveTo(x, y); c.lineTo(x+r*0.866, y-r*0.5); c.stroke();
  }

  @override
  void drawBaseScene(HtmlCanvas c) {
    c.fillStyle = '#fafafa';
    c.fillRect(0, 0, 800, 600);

    // Background Grid
    c.strokeStyle = '#eeeeee';
    c.lineWidth = 1;
    for(int i=0; i<80; i++) {
      c.beginPath(); c.moveTo(i*10, 0); c.lineTo(i*10, 600); c.stroke();
      c.beginPath(); c.moveTo(0, i*10); c.lineTo(800, i*10); c.stroke();
    }
    // Specific grid line to interrupt: x=400, y=100-200
    c.beginPath(); c.moveTo(400, 0); c.lineTo(400, 600); c.stroke(); 

    // Impossible Triangles
    c.fillStyle = '#00bcd4';
    c.beginPath(); c.moveTo(200, 150); c.lineTo(300, 150); c.lineTo(250, 50); c.fill();
    c.fillStyle = '#0097a7';
    c.beginPath(); c.moveTo(250, 50); c.lineTo(280, 50); c.lineTo(330, 150); c.lineTo(300, 150); c.fill(); // Extra

    // Lots of Hexagons
    for(int i=0; i<5; i++) {
      for(int j=0; j<4; j++) {
        double px = 100 + i*130 + (j%2)*65;
        double py = 200 + j*110;
        drawHex(c, px, py, 60, '#ffc107', '#ffa000', '#ff8f00');
      }
    }

    // Specific Hexagon to modify: i=2, j=2 -> px=360, py=420
    drawHex(c, 360, 420, 60, '#ffc107', '#ffa000', '#ff8f00');

    // Connecting lines
    c.strokeStyle = '#212121';
    c.lineWidth = 4;
    for(int i=0; i<4; i++) {
      c.beginPath(); c.moveTo(100 + i*130, 200); c.lineTo(230 + i*130, 200); c.stroke();
      c.beginPath(); c.moveTo(100 + i*130, 420); c.lineTo(230 + i*130, 420); c.stroke();
    }
    // Specific line missing: from (360, 420) to (490, 420)
    c.beginPath(); c.moveTo(360, 420); c.lineTo(490, 420); c.stroke();

    // Nodes
    c.fillStyle = '#e91e63';
    for(int i=0; i<5; i++) {
      c.beginPath(); c.arc(100 + i*130, 200, 8, 0, math.pi*2); c.fill();
      c.beginPath(); c.arc(165 + i*130, 310, 8, 0, math.pi*2); c.fill();
      c.beginPath(); c.arc(100 + i*130, 420, 8, 0, math.pi*2); c.fill();
    }
    // Specific Node to remove: i=3 -> 490, 200
    c.beginPath(); c.arc(490, 200, 8, 0, math.pi*2); c.fill();

    // Random Triangle
    c.fillStyle = '#8bc34a';
    c.beginPath(); c.moveTo(600, 100); c.lineTo(700, 100); c.lineTo(650, 180); c.fill();
  }

  @override
  List<Difference> get differences => [
    Difference(
      'hexagonShadeInverted',
      const Rect.fromLTWH(300, 360, 120, 120),
      const Offset(360, 420),
      (HtmlCanvas c) {
        // Redraw hex with inverted shading
        drawHex(c, 360, 420, 60, '#ff8f00', '#ffc107', '#ffa000');
        // Redraw nodes over it
        c.fillStyle = '#e91e63';
        c.beginPath(); c.arc(360, 420, 8, 0, math.pi*2); c.fill();
      }
    ),
        Difference(
      'extraNode',
      const Rect.fromLTWH(380, 400, 40, 40),
      const Offset(400, 420),
      (HtmlCanvas c) {
        c.fillStyle = '#e91e63';
        c.beginPath(); c.arc(400, 420, 8, 0, 3.14159265*2); c.fill();
      }
    ),
    Difference(
      'triangleColorShift',
      const Rect.fromLTWH(590, 90, 120, 100),
      const Offset(650, 130),
      (HtmlCanvas c) {
        c.fillStyle = '#9ccc65'; // Lighter green
        c.beginPath(); c.moveTo(600, 100); c.lineTo(700, 100); c.lineTo(650, 180); c.fill();
      }
    ),
    Difference(
      'gridLineInterrupted',
      const Rect.fromLTWH(390, 80, 20, 60),
      const Offset(400, 110),
      (HtmlCanvas c) {
        c.fillStyle = '#fafafa';
        c.fillRect(395, 80, 10, 60); // Break the vertical line at x=400
        // Horizontal grid lines crossing
        c.strokeStyle = '#eeeeee'; c.lineWidth = 1;
        for(int i=8; i<=14; i++) {
          c.beginPath(); c.moveTo(395, i*10); c.lineTo(405, i*10); c.stroke();
        }
      }
    ),
    Difference(
      'missingIntersectionNode',
      const Rect.fromLTWH(480, 190, 20, 20),
      const Offset(490, 200),
      (HtmlCanvas c) {
        // Redraw hex top to erase node
        c.fillStyle = '#ffc107';
        c.beginPath(); c.moveTo(490, 200); c.lineTo(490-60*0.866, 200-60*0.5); c.lineTo(490, 200-60); c.lineTo(490+60*0.866, 200-60*0.5); c.fill();
        c.strokeStyle = '#000000'; c.lineWidth = 2;
        c.beginPath(); c.moveTo(490, 200); c.lineTo(490-60*0.866, 200-60*0.5); c.stroke();
        c.beginPath(); c.moveTo(490, 200); c.lineTo(490+60*0.866, 200-60*0.5); c.stroke();
        c.beginPath(); c.moveTo(490, 200); c.lineTo(490, 200+60); c.stroke();
        // Redraw connecting line
        c.strokeStyle = '#212121'; c.lineWidth = 4;
        c.beginPath(); c.moveTo(490, 200); c.lineTo(620, 200); c.stroke();
        c.beginPath(); c.moveTo(360, 200); c.lineTo(490, 200); c.stroke();
      }
    )
  ];
}
