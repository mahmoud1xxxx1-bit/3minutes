import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../html_canvas.dart';
import '../puzzle_model.dart';

class Puzzle01 extends PuzzleDefinition {
  @override
  int get id => 1;

  @override
  void drawBaseScene(HtmlCanvas c) {
    c.fillStyle = '#e8efe9'; c.fillRect(0, 0, 800, 600);
    c.fillStyle = '#c0c8c3'; c.fillRect(0, 480, 800, 120);
    c.strokeStyle = '#aab2ad'; c.lineWidth = 2;
    for(double i=0.0; i<=800; i+=80) { c.beginPath(); c.moveTo(i, 480); c.lineTo(i, 600); c.stroke(); }
    for(double i=480.0; i<=600; i+=40) { c.beginPath(); c.moveTo(0, i); c.lineTo(800, i); c.stroke(); }
    c.fillStyle = '#87ceeb'; c.fillRect(280, 80, 240, 180);
    c.fillStyle = '#f0f8ff';
    c.beginPath(); c.arc(320, 130, 20, 0, math.pi*2); c.arc(350, 120, 25, 0, math.pi*2); c.arc(380, 130, 20, 0, math.pi*2); c.fill();
    c.strokeStyle = '#5a3d2b'; c.lineWidth = 12; c.strokeRect(280, 80, 240, 180);
    c.beginPath(); c.moveTo(400, 80); c.lineTo(400, 260); c.stroke();
    c.beginPath(); c.moveTo(280, 170); c.lineTo(520, 170); c.stroke();
    c.fillStyle = '#fff'; c.beginPath(); c.arc(710, 120, 35, 0, math.pi*2); c.fill();
    c.strokeStyle = '#333'; c.lineWidth = 5; c.stroke();
    c.beginPath(); c.moveTo(710, 120); c.lineTo(710, 100); c.moveTo(710, 120); c.lineTo(725, 120); c.stroke();
    c.fillStyle = '#ffffff'; c.fillRect(40, 40, 180, 130);
    c.strokeStyle = '#d0d0d0'; c.lineWidth = 2; c.strokeRect(40, 40, 90, 130); c.strokeRect(130, 40, 90, 130);
    c.fillStyle = '#888'; c.fillRect(115, 95, 5, 20); c.fillRect(140, 95, 5, 20);
    c.fillStyle = '#ffffff'; c.fillRect(550, 40, 110, 130);
    c.strokeStyle = '#d0d0d0'; c.strokeRect(550, 40, 110, 130);
    c.fillStyle = '#888'; c.fillRect(595, 95, 5, 20);
    c.fillStyle = '#3a3a3a'; c.fillRect(50, 320, 700, 20);
    c.fillStyle = '#2b4f60'; c.fillRect(60, 340, 680, 140);
    c.strokeStyle = '#203d4a'; c.lineWidth = 4;
    for(double i=60.0; i<740; i+=113.3) {
      c.strokeRect(i, 340, 113.3, 140);
      c.fillStyle = '#aaa'; c.fillRect(i+45, 360, 20, 6);
    }
    c.fillStyle = '#e2e2e2'; c.beginPath(); c.roundRect(30, 160, 130, 320, 10); c.fill();
    c.strokeStyle = '#b0b0b0'; c.lineWidth = 2; c.strokeRect(30, 160, 130, 130);
    c.fillStyle = '#555'; c.fillRect(140, 210, 6, 45); c.fillRect(140, 330, 6, 70);
    c.fillStyle = '#444'; c.fillRect(560, 320, 130, 160);
    c.fillStyle = '#222'; c.fillRect(575, 360, 100, 80);
    c.fillStyle = '#ff7f50'; c.fillRect(585, 410, 80, 20);
    c.fillStyle = '#111';
    c.beginPath(); c.ellipse(590, 315, 25, 5, 0, 0, math.pi*2); c.fill();
    c.beginPath(); c.ellipse(660, 315, 25, 5, 0, 0, math.pi*2); c.fill();
    c.fillStyle = '#c4d4e0'; c.fillRect(360, 320, 80, 10);
    c.strokeStyle = '#a4b4c0'; c.lineWidth = 8;
    c.beginPath(); c.moveTo(400, 320); c.lineTo(400, 260); c.quadraticCurveTo(400, 240, 370, 240); c.stroke();
    c.fillStyle = '#d14949'; c.beginPath(); c.roundRect(570, 275, 45, 40, 5); c.fill();
    c.fillStyle = '#111'; c.fillRect(560, 285, 10, 6); c.fillRect(615, 285, 10, 6);
    c.fillStyle = '#999'; c.fillRect(565, 270, 55, 5);
    c.fillStyle = '#222'; c.fillRect(585, 265, 15, 5);
    c.fillStyle = '#7ca2b8'; c.beginPath(); c.roundRect(200, 280, 55, 40, 8); c.fill();
    c.fillStyle = '#333'; c.fillRect(210, 275, 35, 5);
    c.fillStyle = '#a06a46'; c.fillRect(715, 290, 30, 30);
    c.fillStyle = '#4f9878';
    c.beginPath(); c.arc(730, 275, 22, 0, math.pi*2); c.arc(715, 260, 18, 0, math.pi*2); c.arc(745, 265, 16, 0, math.pi*2); c.fill();
  }

  @override
  List<Difference> get differences => [
    Difference(
      'clockTime',
      const Rect.fromLTWH(675.0, 85.0, 70.0, 70.0),
      const Offset(710, 120),
      (HtmlCanvas c) {
        c.fillStyle='#fff'; c.beginPath(); c.arc(710,120,35,0,math.pi*2); c.fill();
        c.strokeStyle='#333'; c.lineWidth = 5; c.stroke();
        c.beginPath(); c.moveTo(710,120); c.lineTo(690,120); c.moveTo(710,120); c.lineTo(710,95); c.stroke();
      }
    ),
    Difference(
      'potLidKnobMissing',
      const Rect.fromLTWH(572.0, 245.0, 40, 40),
      const Offset(592, 265),
      (HtmlCanvas c) {
        c.fillStyle='#e8efe9'; c.fillRect(580,255,25,15);
        c.fillStyle='#999'; c.fillRect(565,270,55,5);
      }
    ),
    Difference(
      'stoveBurnerExtra',
      const Rect.fromLTWH(605.0, 295.0, 40, 40),
      const Offset(625, 315),
      (HtmlCanvas c) {
        c.fillStyle='#111'; c.beginPath(); c.ellipse(625, 315, 15, 5, 0, 0, math.pi*2); c.fill();
      }
    ),
    Difference(
      'fridgeHandleShort',
      const Rect.fromLTWH(123.0, 360.0, 40, 40),
      const Offset(143, 380),
      (HtmlCanvas c) {
        c.fillStyle='#e2e2e2'; c.fillRect(135,325,16,80);
        c.fillStyle='#555'; c.fillRect(140, 330, 6, 40);
      }
    ),
    Difference(
      'cabinetHandleColor',
      const Rect.fromLTWH(577.0, 85.0, 40, 40),
      const Offset(597, 105),
      (HtmlCanvas c) {
        c.fillStyle='#222'; c.fillRect(595,95,5,20);
      }
    )
  ];
}
