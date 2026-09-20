
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'html_canvas.dart';

void drawBaseScene(HtmlCanvas c) {

    c.fillStyle = '#e8efe9'; c.fillRect(0, 0, W, H);
    // Floor
    c.fillStyle = '#c0c8c3'; c.fillRect(0, 480, W, 120);
    c.strokeStyle = '#aab2ad'; c.lineWidth = 2.0;
    for(double i=0.0; i<=800; i+=80) { c.beginPath(); c.moveTo(i, 480); c.lineTo(i, 600); c.stroke(); }
    for(double i=480.0; i<=600; i+=40) { c.beginPath(); c.moveTo(0, i); c.lineTo(800, i); c.stroke(); }
    // Window & Sky
    c.fillStyle = '#87ceeb'; c.fillRect(280, 80, 240, 180);
    c.fillStyle = '#f0f8ff'; 
    c.beginPath(); c.arc(320, 130, 20, 0, math.pi*2); c.arc(350, 120, 25, 0, math.pi*2); c.arc(380, 130, 20, 0, math.pi*2); c.fill();
    c.strokeStyle = '#5a3d2b'; c.lineWidth = 12.0; c.strokeRect(280, 80, 240, 180);
    c.beginPath(); c.moveTo(400, 80); c.lineTo(400, 260); c.stroke();
    c.beginPath(); c.moveTo(280, 170); c.lineTo(520, 170); c.stroke();
    // Clock
    c.fillStyle = '#fff'; c.beginPath(); c.arc(710, 120, 35, 0, math.pi*2); c.fill();
    c.strokeStyle = '#333'; c.lineWidth = 5.0; c.stroke();
    c.beginPath(); c.moveTo(710, 120); c.lineTo(710, 100); c.moveTo(710, 120); c.lineTo(725, 120); c.stroke();
    // Cabinets Left
    c.fillStyle = '#ffffff'; c.fillRect(40, 40, 180, 130);
    c.strokeStyle = '#d0d0d0'; c.lineWidth = 2.0; c.strokeRect(40, 40, 90, 130); c.strokeRect(130, 40, 90, 130);
    c.fillStyle = '#888'; c.fillRect(115, 95, 5, 20); c.fillRect(140, 95, 5, 20);
    // Cabinets Right
    c.fillStyle = '#ffffff'; c.fillRect(550, 40, 110, 130);
    c.strokeStyle = '#d0d0d0'; c.strokeRect(550, 40, 110, 130);
    c.fillStyle = '#888'; c.fillRect(595, 95, 5, 20);
    // Counter & Lower Cabinets
    c.fillStyle = '#3a3a3a'; c.fillRect(50, 320, 700, 20);
    c.fillStyle = '#2b4f60'; c.fillRect(60, 340, 680, 140);
    c.strokeStyle = '#203d4a'; c.lineWidth = 4.0;
    for(double i=60.0; i<740; i+=113.3) { 
        c.strokeRect(i, 340, 113.3, 140); 
        c.fillStyle = '#aaa'; c.fillRect(i+45, 360, 20, 6);
    }
    // Fridge
    c.fillStyle = '#e2e2e2'; c.beginPath(); c.roundRect(30, 160, 130, 320, 10); c.fill();
    c.strokeStyle = '#b0b0b0'; c.lineWidth = 2.0; c.strokeRect(30, 160, 130, 130);
    c.fillStyle = '#555'; c.fillRect(140, 210, 6, 45); c.fillRect(140, 330, 6, 70);
    // Stove
    c.fillStyle = '#444'; c.fillRect(560, 320, 130, 160);
    c.fillStyle = '#222'; c.fillRect(575, 360, 100, 80);
    c.fillStyle = '#ff7f50'; c.fillRect(585, 410, 80, 20);
    c.fillStyle = '#111';
    c.beginPath(); c.ellipse(590, 315, 25, 5, 0, 0, math.pi*2); c.fill();
    c.beginPath(); c.ellipse(660, 315, 25, 5, 0, 0, math.pi*2); c.fill();
    // Faucet
    c.fillStyle = '#c4d4e0'; c.fillRect(360, 320, 80, 10);
    c.strokeStyle = '#a4b4c0'; c.lineWidth = 8.0;
    c.beginPath(); c.moveTo(400, 320); c.lineTo(400, 260); c.quadraticCurveTo(400, 240, 370, 240); c.stroke();
    // Pot
    c.fillStyle = '#d14949'; c.beginPath(); c.roundRect(570, 275, 45, 40, 5); c.fill();
    c.fillStyle = '#111'; c.fillRect(560, 285, 10, 6); c.fillRect(615, 285, 10, 6);
    c.fillStyle = '#999'; c.fillRect(565, 270, 55, 5);
    c.fillStyle = '#222'; c.fillRect(585, 265, 15, 5);
    // Toaster
    c.fillStyle = '#7ca2b8'; c.beginPath(); c.roundRect(200, 280, 55, 40, 8); c.fill();
    c.fillStyle = '#333'; c.fillRect(210, 275, 35, 5);
    // Plant
    c.fillStyle = '#a06a46'; c.fillRect(715, 290, 30, 30);
    c.fillStyle = '#4f9878'; 
    c.beginPath(); c.arc(730, 275, 22, 0, math.pi*2); c.arc(715, 260, 18, 0, math.pi*2); c.arc(745, 265, 16, 0, math.pi*2); c.fill();
}
