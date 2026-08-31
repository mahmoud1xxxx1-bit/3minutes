
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../html_canvas.dart';
import '../puzzle_model.dart';

class Puzzle02 extends PuzzleDefinition {
  @override
  int get id => 2;



  @override
  void drawBaseScene(HtmlCanvas c) {
    
    // Sky (نفس لون نافذة المطبخ)
    c.fillStyle = '#87ceeb'; c.fillRect(0, 0, 800, 600);
    // Sun (نفس لون الصنبور الذهبي)
    c.fillStyle = '#d4af37';
    c.beginPath(); c.arc(100, 120, 45, 0, math.pi*2); c.fill();
    // Clouds (نفس سحابة المطبخ)
    c.fillStyle = '#f0f8ff';
    c.beginPath(); c.arc(220, 130, 20, 0, math.pi*2); c.arc(250, 120, 25, 0, math.pi*2); c.arc(280, 130, 20, 0, math.pi*2); c.fill();
    c.beginPath(); c.arc(520, 160, 25, 0, math.pi*2); c.arc(560, 140, 35, 0, math.pi*2); c.arc(600, 160, 25, 0, math.pi*2); c.fill();
    // Distant Hills (ألوان هادئة متناسقة)
    c.fillStyle = '#86a392';
    c.beginPath(); c.ellipse(300, 400, 500, 150, 0, 0, math.pi*2); c.fill();
    c.fillStyle = '#739580';
    c.beginPath(); c.ellipse(650, 420, 350, 180, 0, 0, math.pi*2); c.fill();
    // Foreground Grass (لون أخضر مريح)
    c.fillStyle = '#5c8a6b';
    c.fillRect(0, 400, 800, 200);
    // Concrete Path (نفس أرضية المطبخ تماماً)
    c.fillStyle = '#c0c8c3';
    c.beginPath(); c.moveTo(300, 600); c.lineTo(500, 600); c.lineTo(450, 400); c.lineTo(350, 400); c.fill();
    c.strokeStyle = '#aab2ad'; c.lineWidth = 2;
    c.beginPath(); c.moveTo(350, 400); c.lineTo(300, 600); c.stroke();
    c.beginPath(); c.moveTo(450, 400); c.lineTo(500, 600); c.stroke();
    // خطوط الممر (Horizontal lines)
    c.beginPath(); c.moveTo(340, 440); c.lineTo(460, 440); c.stroke();
    c.beginPath(); c.moveTo(325, 490); c.lineTo(475, 490); c.stroke();
    c.beginPath(); c.moveTo(310, 550); c.lineTo(490, 550); c.stroke();
    // Tree (Left)
    c.fillStyle = '#5a3d2b'; // لون إطار نافذة المطبخ
    c.fillRect(140, 250, 30, 180); // Trunk
    c.fillStyle = '#4c8f5e'; // لون نبتة المطبخ والقدر
    c.beginPath(); c.arc(155, 220, 70, 0, math.pi*2); c.fill();
    c.beginPath(); c.arc(105, 260, 60, 0, math.pi*2); c.fill();
    c.beginPath(); c.arc(205, 260, 60, 0, math.pi*2); c.fill();
    c.beginPath(); c.arc(155, 160, 60, 0, math.pi*2); c.fill();
    // Bench (Right side of path)
    c.fillStyle = '#2b4f60'; // لون خزائن المطبخ السفلية للمعادن
    c.fillRect(560, 450, 8, 40);
    c.fillRect(660, 450, 8, 40);
    c.fillStyle = '#b8915e'; // مقبض الثلاجة للون الخشب
    c.beginPath(); c.roundRect(540, 440, 140, 12, 4); c.fill(); // Seat
    c.beginPath(); c.roundRect(540, 400, 140, 10, 4); c.fill(); // Back 1
    c.beginPath(); c.roundRect(540, 420, 140, 10, 4); c.fill(); // Back 2
    c.fillStyle = '#2b4f60'; 
    c.fillRect(565, 400, 5, 45); 
    c.fillRect(655, 400, 5, 45); 
    // Pond
    c.fillStyle = '#5baad4'; // لون ماء صنبور المطبخ
    c.beginPath(); c.ellipse(150, 530, 80, 25, 0, 0, math.pi*2); c.fill();
    c.strokeStyle = '#e8efe9'; c.lineWidth = 2; // تموج الماء
    c.beginPath(); c.moveTo(130, 535); c.lineTo(170, 535); c.stroke();
    // Flowers (ألوان القدر والزهرة في المطبخ)
    c.fillStyle = '#d14949'; 
    c.beginPath(); c.arc(600, 550, 8, 0, math.pi*2); c.fill();
    c.fillStyle = '#c15886'; 
    c.beginPath(); c.arc(630, 530, 8, 0, math.pi*2); c.fill();
    c.fillStyle = '#fff'; 
    c.beginPath(); c.arc(600, 550, 3, 0, math.pi*2); c.fill();
    c.beginPath(); c.arc(630, 530, 3, 0, math.pi*2); c.fill();

  }

  @override
  List<Difference> get differences => [
    
    Difference(
      'extraCloud',
      const Rect.fromLTWH(90.0, 180.0, 40, 40),
      const Offset(110, 200),
      (HtmlCanvas c) {
        
        // إضافة غيمة صغيرة مخفية بجانب الشجرة
        c.fillStyle = '#f0f8ff';
        c.beginPath(); c.ellipse(110, 200, 20, 10, 0, 0, math.pi*2); c.fill();
    
      }
    ),
    Difference(
      'benchSlatColor',
      const Rect.fromLTWH(590.0, 405.0, 40, 40),
      const Offset(610, 425),
      (HtmlCanvas c) {
        
        // اللوح الخشبي السفلي في المقعد لونه أغمق قليلاً
        c.fillStyle = '#8b6b43';
        c.beginPath(); c.roundRect(540, 420, 140, 10, 4); c.fill();
        c.fillStyle = '#2b4f60'; 
        c.fillRect(565, 420, 5, 10); 
        c.fillRect(655, 420, 5, 10); 
    
      }
    ),
    Difference(
      'flowerColor',
      const Rect.fromLTWH(622.0, 522.0, 16.0, 16.0),
      const Offset(630, 530),
      (HtmlCanvas c) {
        
        // تغير لون الزهرة الوردية إلى الأبيض
        c.fillStyle = '#e8efe9'; 
        c.beginPath(); c.arc(630, 530, 8, 0, math.pi*2); c.fill();
        c.fillStyle = '#c15886'; // القلب وردي
        c.beginPath(); c.arc(630, 530, 3, 0, math.pi*2); c.fill();
    
      }
    ),
    Difference(
      'pathLineMissing',
      const Rect.fromLTWH(380.0, 470.0, 40, 40),
      const Offset(400, 490),
      (HtmlCanvas c) {
        
        // مسح الخط الأفقي الأوسط في الممر الإسمنتي
        c.fillStyle = '#c0c8c3'; 
        c.fillRect(320, 488, 160, 5); 
    
      }
    ),
    Difference(
      'pondReflectionMoved',
      const Rect.fromLTWH(130.0, 522.0, 40, 40),
      const Offset(150, 542),
      (HtmlCanvas c) {
        
        // مسح تموج الماء الأبيض ورسمه في مكان آخر
        c.strokeStyle = '#5baad4'; c.lineWidth = 4; 
        c.beginPath(); c.moveTo(125, 535); c.lineTo(175, 535); c.stroke();
        c.strokeStyle = '#e8efe9'; c.lineWidth = 2; 
        c.beginPath(); c.moveTo(140, 542); c.lineTo(160, 542); c.stroke();
    
      }
    )
  ];
}
