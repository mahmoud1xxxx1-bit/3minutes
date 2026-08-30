import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'game_engine.dart';

class GamePainterA37 extends CustomPainter {
  GamePainterA37({required this.engine, this.images});
  final GameEngine engine;
  final Map<String, ui.Image>? images;

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / GameEngine.fieldSize;
    final scaleY = size.height / GameEngine.fieldSize;
    final scale = scaleX < scaleY ? scaleX : scaleY;
    
    canvas.translate((size.width - (GameEngine.fieldSize * scale)) / 2, (size.height - (GameEngine.fieldSize * scale)) / 2);
    canvas.scale(scale, scale);
    canvas.clipRect(const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize));

    // FLOOR

    canvas.drawRect(const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize), Paint()..color = const Color(0xFF795548)); // Wood desk
    final grain = Paint()..color=const Color(0xFF5D4037)..style=PaintingStyle.stroke..strokeWidth=2;
    for(double y=0; y<GameEngine.fieldSize; y+=40) {
        Path w = Path();
        for(double x=0; x<=GameEngine.fieldSize; x+=50) {
            if(x==0) w.moveTo(x, y);
            else w.quadraticBezierTo(x-25, y + math.sin(x)*10, x, y);
        }
        canvas.drawPath(w, grain);
    }
    // A blueprint paper scattered
    canvas.save(); canvas.translate(200, 200); canvas.rotate(0.2);
    canvas.drawRect(const Rect.fromLTWH(0, 0, 400, 300), Paint()..color=const Color(0xFF1976D2).withOpacity(0.8));
    canvas.drawCircle(const Offset(200, 150), 100, Paint()..color=Colors.white.withOpacity(0.5)..style=PaintingStyle.stroke..strokeWidth=2);
    canvas.restore();
    

    // WEATHER

    // Floating dust motes in light
    for (int i = 0; i < 30; i++) {
      double px = ((i * 75) + math.sin(engine.time*0.5 + i)*20) % GameEngine.fieldSize;
      double py = ((i * 120) + engine.time * -15) % GameEngine.fieldSize;
      if (py < 0) py += GameEngine.fieldSize;
      canvas.drawCircle(Offset(px, py), 2, Paint()..color=Colors.white.withOpacity(0.4)); 
    }
    

    // OBSTACLES

    for (int i = 0; i < engine.obstacles.length; i++) {
      final obs = engine.obstacles[i];
      canvas.drawRect(obs.shift(const Offset(5, 10)), Paint()..color=Colors.black54);
      canvas.drawRect(obs, Paint()..color=const Color(0xFFCFD8DC)); // Steel block
      // Giant screw heads
      for(double x = obs.left+15; x < obs.right; x+=40) {
          canvas.drawCircle(Offset(x, obs.top+15), 10, Paint()..color=const Color(0xFF90A4AE));
          canvas.drawLine(Offset(x-7, obs.top+15), Offset(x+7, obs.top+15), Paint()..color=const Color(0xFF546E7A)..strokeWidth=3);
      }
      canvas.drawRect(obs, Paint()..color=const Color(0xFFFFD700)..style=PaintingStyle.stroke..strokeWidth=3); // brass trim
    }
    

    // TARGETS
    for (int i = 0; i < engine.targets.length; i++) {
      if (i < engine.currentTargetIndex) continue;
      final target = engine.targets[i];
      final tr = GameEngine.targetRadius; 
      double floatOffset = math.sin(engine.time * 4 + i) * 5;

      final isNext = i == engine.currentTargetIndex;
      canvas.drawOval(Rect.fromCenter(center: target + const Offset(0, 15), width: tr*1.5, height: tr*0.8), Paint()..color=Colors.black26);
      canvas.save(); canvas.translate(target.dx, target.dy - floatOffset);
      if (isNext) {
          // Glowing Ruby Watch Bearing
          Path ruby = Path()..moveTo(0, -15)..lineTo(12, 0)..lineTo(0, 15)..lineTo(-12, 0)..close();
          canvas.drawPath(ruby, Paint()..color=const Color(0xFFFF1744));
          canvas.drawPath(ruby, Paint()..color=Colors.white..style=PaintingStyle.stroke..strokeWidth=2);
          canvas.drawCircle(Offset.zero, tr*2, Paint()..shader = ui.Gradient.radial(Offset.zero, tr*2, [const Color(0xFFFF1744).withOpacity(0.5), Colors.transparent]));
      } else {
          // Tiny brass gear
          canvas.drawCircle(Offset.zero, 10, Paint()..color=const Color(0xFFD7CCC8));
          canvas.drawCircle(Offset.zero, 10, Paint()..color=const Color(0xFF8D6E63)..style=PaintingStyle.stroke..strokeWidth=3);
      }
      canvas.restore();
    
    }

    // EXIT GATE
    if (engine.exitGate != null) {
      final center = engine.exitGate!;

      canvas.drawCircle(center, 40, Paint()..color=const Color(0xFFFFD700));
      canvas.drawCircle(center, 35, Paint()..color=Colors.white);
      // Roman numerals (abstracted as lines)
      for(int a=0; a<12; a++) {
          double angle = a * math.pi/6;
          canvas.drawLine(center + Offset(math.cos(angle)*25, math.sin(angle)*25), center + Offset(math.cos(angle)*35, math.sin(angle)*35), Paint()..color=Colors.black..strokeWidth=2);
      }
      // Hands
      canvas.save(); canvas.translate(center.dx, center.dy); canvas.rotate(engine.time * 5);
      canvas.drawLine(Offset.zero, const Offset(0, -25), Paint()..color=Colors.black..strokeWidth=4);
      canvas.restore();
    
    }

    // ==========================================
    // 5. UNIFIED CHASER IDENTITY
    // ==========================================
    if (images != null && images!['enemy'] != null) {
      if (engine.chaserInWall) {
          canvas.drawCircle(engine.chaserPos, GameEngine.chaserRadius * 1.5, Paint()..color = Colors.black87);
          canvas.drawCircle(engine.chaserPos, GameEngine.chaserRadius * 0.8, Paint()..color = Colors.black);
          final eyeGlow = Paint()..color = Colors.red.withOpacity(0.6)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
          canvas.drawCircle(engine.chaserPos + const Offset(-6, -4), 8, eyeGlow);
          canvas.drawCircle(engine.chaserPos + const Offset(6, -4), 8, eyeGlow);
          canvas.drawCircle(engine.chaserPos + const Offset(-6, -4), 3, Paint()..color = Colors.white);
          canvas.drawCircle(engine.chaserPos + const Offset(6, -4), 3, Paint()..color = Colors.white);
      } else {
          canvas.drawCircle(engine.chaserPos + const Offset(0, 15), GameEngine.chaserRadius, Paint()..color=Colors.black.withOpacity(0.35));
          if(engine.chaserStunTimer <= GameEngine.recoveryDuration) {
             double pulse = 1.0 + math.sin(engine.time * 20) * 0.1;
             canvas.drawCircle(engine.chaserPos, GameEngine.chaserRadius * 2.5 * pulse, Paint()..color = Colors.redAccent.withOpacity(0.3));
          }
          canvas.save(); canvas.translate(engine.chaserPos.dx, engine.chaserPos.dy);
          if (engine.chaserVelocity.dx > 0) canvas.scale(-1, 1);
          canvas.translate(0, math.sin(engine.time * 6) * 4); 
          
          Paint chaserPaint = (engine.chaserStunTimer > GameEngine.recoveryDuration) 
              ? (Paint()..color=Colors.grey.withOpacity(0.5)) 
              : Paint();
              
          canvas.drawImageRect(images!['enemy']!, 
              Rect.fromLTWH(0,0, images!['enemy']!.width.toDouble(), images!['enemy']!.height.toDouble()), 
              Rect.fromCenter(center: Offset.zero, width: GameEngine.chaserRadius*2.5, height: GameEngine.chaserRadius*2.5), 
              chaserPaint);
          canvas.restore();
      }
    }

    // ==========================================
    // 6. UNIFIED PLAYER IDENTITY
    // ==========================================
    if (images != null && images!['player'] != null) {
      canvas.drawCircle(engine.playerPos + const Offset(0, 15), GameEngine.playerRadius, Paint()..color=Colors.black.withOpacity(0.35));
      
      double vLen = engine.playerVelocity.distance;
      if (vLen > 0) {
        canvas.save(); canvas.translate(engine.playerPos.dx, engine.playerPos.dy);
        canvas.rotate(math.atan2(engine.playerVelocity.dy, engine.playerVelocity.dx));
        canvas.drawOval(Rect.fromCenter(center: const Offset(-20, 0), width: 40, height: 10), Paint()..color=Colors.white.withOpacity(0.5));
        canvas.restore();
      }
      
      canvas.save(); canvas.translate(engine.playerPos.dx, engine.playerPos.dy);
      if (engine.playerVelocity.dx > 0) canvas.scale(-1, 1);
      if (vLen > 0) canvas.translate(0, math.sin(engine.time * 20) * 3);
      
      canvas.drawImageRect(images!['player']!, 
          Rect.fromLTWH(0, 0, images!['player']!.width.toDouble(), images!['player']!.height.toDouble()), 
          Rect.fromCenter(center: Offset.zero, width: GameEngine.playerRadius*2.8, height: GameEngine.playerRadius*2.8), 
          Paint());
      canvas.restore();
    }

  }
  @override bool shouldRepaint(covariant GamePainterA37 old) => true;
}
