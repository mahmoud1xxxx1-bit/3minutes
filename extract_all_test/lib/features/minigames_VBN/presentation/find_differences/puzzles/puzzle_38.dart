import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../html_canvas.dart';
import '../puzzle_model.dart';

class Puzzle38 extends PuzzleDefinition {
  @override
  int get id => 38;

  @override
  void drawBaseScene(HtmlCanvas c) {
    // Background Tent Interior
    c.fillStyle = '#220000'; c.fillRect(0, 0, 800, 600);
    
    // Tent Stripes
    for (double x = -200; x < 1000; x += 100) {
      c.fillStyle = '#8b0000';
      c.beginPath(); c.moveTo(400, -100); c.lineTo(x, 600); c.lineTo(x + 50, 600); c.lineTo(400, -100); c.fill();
      c.fillStyle = '#f5f5dc';
      c.beginPath(); c.moveTo(400, -100); c.lineTo(x + 50, 600); c.lineTo(x + 100, 600); c.lineTo(400, -100); c.fill();
    }
    
    // Ring Floor
    c.fillStyle = '#d2b48c'; c.beginPath(); c.ellipse(400, 500, 400, 100, 0, 0, math.pi*2); c.fill();
    c.strokeStyle = '#ff0000'; c.lineWidth = 15; c.stroke();
    
    // Podium
    c.fillStyle = '#00008b'; c.fillRect(350, 420, 100, 80);
    c.fillStyle = '#ffd700';
    for (double i = 350; i <= 430; i += 20) {
      c.fillRect(i, 420, 10, 80);
    }
    c.fillStyle = '#ff0000'; c.beginPath(); c.ellipse(400, 420, 50, 15, 0, 0, math.pi*2); c.fill();
    
    // Trapeze
    c.strokeStyle = '#a9a9a9'; c.lineWidth = 3;
    c.beginPath(); c.moveTo(300, -50); c.lineTo(300, 150); c.stroke();
    c.beginPath(); c.moveTo(500, -50); c.lineTo(500, 150); c.stroke();
    c.strokeStyle = '#8b4513'; c.lineWidth = 8;
    c.beginPath(); c.moveTo(280, 150); c.lineTo(520, 150); c.stroke();
    
    // Spotlights
    c.fillStyle = 'rgba(255,255,255,0.2)';
    c.beginPath(); c.moveTo(100, -50); c.lineTo(250, 430); c.lineTo(550, 430); c.fill();
    c.beginPath(); c.moveTo(700, -50); c.lineTo(250, 430); c.lineTo(550, 430); c.fill();
    
    // Stars Decorations
    void drawStar(double cx, double cy, String color) {
      c.save(); c.translate(cx, cy);
      c.fillStyle = color;
      c.beginPath();
      for (double i = 0; i < 5; i++) {
        c.lineTo(math.cos((18 + i * 72) * math.pi / 180) * 20, -math.sin((18 + i * 72) * math.pi / 180) * 20);
        c.lineTo(math.cos((54 + i * 72) * math.pi / 180) * 10, -math.sin((54 + i * 72) * math.pi / 180) * 10);
      }
      c.fill(); c.restore();
    }
    
    drawStar(100, 200, '#ffd700');
    drawStar(700, 250, '#ffd700');
    drawStar(150, 350, '#ffd700');
    drawStar(650, 150, '#ffd700');
  }

  @override
  List<Difference> get differences => [
    Difference(
      'starColor',
      const Rect.fromLTWH(80.0, 180.0, 40.0, 40.0),
      const Offset(100, 200),
      (HtmlCanvas c) {
        c.save(); c.translate(100, 200);
        c.fillStyle = '#c0c0c0'; // Silver
        c.beginPath();
        c.moveTo(math.cos(18 * math.pi / 180) * 20, -math.sin(18 * math.pi / 180) * 20);
        for (double i = 0; i < 5; i++) {
          c.lineTo(math.cos((18 + i * 72) * math.pi / 180) * 20, -math.sin((18 + i * 72) * math.pi / 180) * 20);
          c.lineTo(math.cos((54 + i * 72) * math.pi / 180) * 10, -math.sin((54 + i * 72) * math.pi / 180) * 10);
        }
        c.fill(); c.restore();
      }
    ),
    Difference(
      'podiumStripe',
      const Rect.fromLTWH(385.0, 420.0, 20.0, 80.0),
      const Offset(395, 460),
      (HtmlCanvas c) {
        c.fillStyle = '#00008b'; c.fillRect(390, 420, 10, 80);
      }
    ),
    Difference(
      'extraStar',
      const Rect.fromLTWH(380.0, 80.0, 40.0, 40.0),
      const Offset(400, 100),
      (HtmlCanvas c) {
        c.save(); c.translate(400, 100);
        c.fillStyle = '#ffd700';
        c.beginPath();
        c.moveTo(math.cos(18 * math.pi / 180) * 20, -math.sin(18 * math.pi / 180) * 20);
        for (double i = 0; i < 5; i++) {
          c.lineTo(math.cos((18 + i * 72) * math.pi / 180) * 20, -math.sin((18 + i * 72) * math.pi / 180) * 20);
          c.lineTo(math.cos((54 + i * 72) * math.pi / 180) * 10, -math.sin((54 + i * 72) * math.pi / 180) * 10);
        }
        c.fill(); c.restore();
      }
    ),
    Difference(
      'trapezeRing',
      const Rect.fromLTWH(380.0, 140.0, 40.0, 50.0),
      const Offset(400, 165),
      (HtmlCanvas c) {
        c.strokeStyle = '#ff0000'; c.lineWidth = 4;
        c.beginPath(); c.arc(400, 165, 15, 0, math.pi*2); c.stroke();
      }
    ),
    Difference(
      'extraBall',
      const Rect.fromLTWH(200.0, 480.0, 40.0, 40.0),
      const Offset(220, 500),
      (HtmlCanvas c) {
        c.fillStyle = '#ff0000';
        c.beginPath(); c.arc(220, 500, 15, 0, math.pi*2); c.fill();
        c.fillStyle = '#ffffff';
        c.beginPath(); c.arc(215, 495, 5, 0, math.pi*2); c.fill();
      }
    )
  ];
}