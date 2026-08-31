import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../html_canvas.dart';
import '../puzzle_model.dart';

class Puzzle42 extends PuzzleDefinition {
  @override
  int get id => 42;

  void drawPineTree(HtmlCanvas c, double x, double y, double scale) {
    c.fillStyle = '#795548'; c.fillRect(x - 5*scale, y - 20*scale, 10*scale, 40*scale); // Trunk
    c.fillStyle = '#1b5e20';
    for(int i=0; i<4; i++) {
      c.beginPath(); 
      c.moveTo(x, y - (120 - i*20)*scale); 
      c.lineTo(x + (30 + i*10)*scale, y - (40 - i*20)*scale); 
      c.lineTo(x - (30 + i*10)*scale, y - (40 - i*20)*scale); 
      c.fill();
    }
    // Snow on tree
    c.fillStyle = '#ffffff';
    for(int i=0; i<4; i++) {
      c.beginPath(); 
      c.moveTo(x, y - (120 - i*20)*scale); 
      c.lineTo(x + (20 + i*8)*scale, y - (50 - i*20)*scale); 
      c.lineTo(x, y - (60 - i*20)*scale); 
      c.fill();
    }
  }

  void drawCabin(HtmlCanvas c, double x, double y, double scale) {
    c.save(); c.translate(x, y); c.scale(scale, scale);
    c.fillStyle = '#5d4037'; c.fillRect(-40, -40, 80, 40); // Body
    c.fillStyle = '#3e2723'; c.fillRect(-10, -30, 20, 30); // Door
    c.fillStyle = '#fff9c4'; c.fillRect(20, -25, 15, 15); // Window Right
    c.fillRect(-35, -25, 15, 15); // Window Left - Lit
    
    // Roof
    c.fillStyle = '#ffffff'; // Snow covered
    c.beginPath(); c.moveTo(-50, -40); c.lineTo(0, -80); c.lineTo(50, -40); c.fill();
    
    // Chimney
    c.fillStyle = '#d32f2f'; c.fillRect(15, -70, 10, 25);
    c.fillStyle = '#ffffff'; c.fillRect(13, -72, 14, 5); // Snow cap
    
    c.restore();
  }

  @override
  void drawBaseScene(HtmlCanvas c) {
    // Night sky
    final sky = c.createLinearGradient(0, 0, 0, 400);
    sky..addColorStop(0, '#0d47a1')..addColorStop(1, '#1565c0');
    c.fillStyle = sky; c.fillRect(0, 0, 800, 400);

    // Stars
    c.fillStyle = '#ffffff';
    math.Random rand = math.Random(10);
    for(int i=0; i<50; i++) {
      c.beginPath(); c.arc(rand.nextDouble()*800, rand.nextDouble()*300, rand.nextDouble()*2, 0, math.pi*2); c.fill();
    }

    // Moon
    c.fillStyle = '#ffecb3'; c.beginPath(); c.arc(700, 100, 40, 0, math.pi*2); c.fill();
    c.fillStyle = 'rgba(255, 236, 179, 0.2)'; c.beginPath(); c.arc(700, 100, 60, 0, math.pi*2); c.fill();

    // Mountains
    c.fillStyle = '#e0e0e0';
    c.beginPath(); c.moveTo(0, 400); c.lineTo(200, 150); c.lineTo(450, 400); c.fill();
    c.beginPath(); c.moveTo(300, 400); c.lineTo(550, 100); c.lineTo(800, 400); c.fill();
    c.fillStyle = '#bdbdbd';
    c.beginPath(); c.moveTo(200, 150); c.lineTo(250, 250); c.lineTo(450, 400); c.fill();
    c.beginPath(); c.moveTo(550, 100); c.lineTo(580, 200); c.lineTo(800, 400); c.fill();

    // Ground Snow
    c.fillStyle = '#ffffff';
    c.beginPath(); c.moveTo(0, 350); c.quadraticCurveTo(400, 300, 800, 350); c.lineTo(800, 600); c.lineTo(0, 600); c.fill();

    // Cabins
    drawCabin(c, 200, 450, 1.5);
    drawCabin(c, 600, 400, 1.0);
    drawCabin(c, 400, 520, 2.0);

    // Trees
    drawPineTree(c, 50, 450, 1.5);
    drawPineTree(c, 100, 480, 1.2);
    drawPineTree(c, 750, 430, 1.8);
    drawPineTree(c, 680, 480, 1.4); // Tree to modify

    // Chimney Smoke (cabin 3 - 400, 520)
    c.fillStyle = 'rgba(236, 239, 241, 0.6)';
    for(int i=0; i<4; i++) {
      c.beginPath(); c.arc(430 + i*15, 370 - i*20, 15 + i*5, 0, math.pi*2); c.fill(); // Specific smoke to hide
    }
    // Cabin 1 smoke
    for(int i=0; i<3; i++) {
      c.beginPath(); c.arc(222 + i*10, 340 - i*15, 10 + i*3, 0, math.pi*2); c.fill();
    }

    // Footprints in snow
    c.fillStyle = '#cfd8dc';
    for(int i=0; i<8; i++) {
      c.beginPath(); c.ellipse(350 + i*25, 580 - i*15, 8, 4, 0.5 + (i%2)*0.5, 0, math.pi*2); c.fill();
    }
    // Specific footprint: i=4 -> x=450, y=520
    c.beginPath(); c.ellipse(450, 520, 8, 4, 0.5, 0, math.pi*2); c.fill();

    // Weather vane on Cabin 2 (600, 400)
    c.strokeStyle = '#212121'; c.lineWidth = 2;
    c.beginPath(); c.moveTo(600, 320); c.lineTo(600, 290); c.stroke();
    c.beginPath(); c.moveTo(590, 305); c.lineTo(610, 305); c.stroke(); // E-W
    // Arrow pointing Right
    c.beginPath(); c.moveTo(585, 295); c.lineTo(615, 295); c.stroke();
    c.beginPath(); c.moveTo(615, 295); c.lineTo(610, 290); c.stroke();
    c.beginPath(); c.moveTo(615, 295); c.lineTo(610, 300); c.stroke();
  }

  @override
  List<Difference> get differences => [
    Difference(
      'extraFootprint',
      const Rect.fromLTWH(290, 540, 40, 40),
      const Offset(310, 560),
      (HtmlCanvas c) {
        c.fillStyle = '#cfd8dc';
        c.beginPath(); c.ellipse(310, 560, 8, 4, 0.5, 0, math.pi*2); c.fill();
      }
    ),
    Difference(
      'windowLightOff',
      const Rect.fromLTWH(310, 450, 60, 60),
      const Offset(330, 470),
      (HtmlCanvas c) {
        c.save(); c.translate(400, 520); c.scale(2.0, 2.0);
        c.fillStyle = '#212121'; // Dark window instead of lit
        c.fillRect(-35, -25, 15, 15);
        c.restore();
      }
    ),
    Difference(
      'missingFootprint',
      const Rect.fromLTWH(430, 500, 40, 40),
      const Offset(450, 520),
      (HtmlCanvas c) {
        c.fillStyle = '#ffffff'; // Snow color
        c.beginPath(); c.ellipse(450, 520, 10, 6, 0.5, 0, math.pi*2); c.fill();
      }
    ),
    Difference(
      'extraStar',
      const Rect.fromLTWH(480, 180, 40, 40),
      const Offset(500, 200),
      (HtmlCanvas c) {
        c.fillStyle = '#ffffff';
        c.beginPath();
        c.moveTo(500, 190);
        c.lineTo(505, 205);
        c.lineTo(520, 205);
        c.lineTo(508, 215);
        c.lineTo(512, 230);
        c.lineTo(500, 220);
        c.lineTo(488, 230);
        c.lineTo(492, 215);
        c.lineTo(480, 205);
        c.lineTo(495, 205);
        c.fill();
      }
    ),
    Difference(
      'moonCrater',
      const Rect.fromLTWH(670, 70, 40, 40),
      const Offset(690, 90),
      (HtmlCanvas c) {
        c.fillStyle = '#dcb873'; // Darker moon color
        c.beginPath(); c.arc(690, 90, 12, 0, math.pi*2); c.fill();
        c.beginPath(); c.arc(710, 110, 8, 0, math.pi*2); c.fill();
      }
    )
  ];
}