import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'game_engine.dart';

class GamePainterA49 extends CustomPainter {
  GamePainterA49({required this.engine, this.images});
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

    canvas.drawRect(const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize), Paint()..color = const Color(0xFF81D4FA)); // Sky blue
    // Massive white marble tiles floating
    final tile = Paint()..color=Colors.white.withOpacity(0.9);
    final shadow = Paint()..color=const Color(0xFF0277BD).withOpacity(0.3);
    for(double x=100; x<GameEngine.fieldSize-100; x+=120) {
       for(double y=100; y<GameEngine.fieldSize-100; y+=120) {
           canvas.drawRect(Rect.fromLTWH(x+10, y+15, 100, 100), shadow);
           canvas.drawRect(Rect.fromLTWH(x, y, 100, 100), tile);
       }
    }
    

    // WEATHER

    // Floating clouds moving across
    for (int i = 0; i < 8; i++) {
      double px = ((i * 200) + engine.time * 50) % (GameEngine.fieldSize*1.5) - 200;
      double py = ((i * 150)) % GameEngine.fieldSize;
      canvas.drawCircle(Offset(px, py), 40, Paint()..color=Colors.white.withOpacity(0.5));
      canvas.drawCircle(Offset(px+30, py+10), 30, Paint()..color=Colors.white.withOpacity(0.5));
      canvas.drawCircle(Offset(px-30, py+10), 30, Paint()..color=Colors.white.withOpacity(0.5));
    }
    

    // OBSTACLES

    for (int i = 0; i < engine.obstacles.length; i++) {
      final obs = engine.obstacles[i];
      canvas.drawRect(obs.shift(const Offset(10, 20)), Paint()..color=Colors.black26);
      // Marble Greek Pillar
      canvas.drawRect(obs, Paint()..color=const Color(0xFFECEFF1));
      canvas.drawRect(obs, Paint()..color=const Color(0xFFB0BEC5)..style=PaintingStyle.stroke..strokeWidth=2);
      // Fluting (vertical lines)
      for(double x = obs.left+8; x < obs.right; x+=40) {
          canvas.drawLine(Offset(x, obs.top), Offset(x, obs.bottom), Paint()..color=const Color(0xFFCFD8DC)..strokeWidth=2);
      }
      // Gold draped bands
      canvas.drawRect(Rect.fromLTWH(obs.left-5, obs.top+10, obs.width+10, 10), Paint()..color=const Color(0xFFFFD700));
      canvas.drawRect(Rect.fromLTWH(obs.left-5, obs.bottom-20, obs.width+10, 10), Paint()..color=const Color(0xFFFFD700));
    }
    

    // TARGETS
    for (int i = 0; i < engine.targets.length; i++) {
      if (i < engine.currentTargetIndex) continue;
      final target = engine.targets[i];
      final tr = GameEngine.targetRadius; 
      double floatOffset = math.sin(engine.time * 4 + i) * 5;

      final isNext = i == engine.currentTargetIndex;
      canvas.drawOval(Rect.fromCenter(center: target + const Offset(0, 30), width: tr*1.5, height: tr*0.8), Paint()..color=Colors.black12); // high shadow
      canvas.save(); canvas.translate(target.dx, target.dy - floatOffset*1.5);
      if (isNext) {
          // Glowing Sun Orb
          canvas.drawCircle(Offset.zero, 15, Paint()..color=Colors.white);
          canvas.drawCircle(Offset.zero, 18, Paint()..color=const Color(0xFFFFD700)..style=PaintingStyle.stroke..strokeWidth=4);
          canvas.save(); canvas.rotate(engine.time * 2);
          for(int a=0; a<8; a++) {
              canvas.rotate(math.pi/4);
              canvas.drawLine(const Offset(20, 0), const Offset(30, 0), Paint()..color=const Color(0xFFFFD700)..strokeWidth=4);
          }
          canvas.restore();
          canvas.drawCircle(Offset.zero, tr*2.5, Paint()..shader = ui.Gradient.radial(Offset.zero, tr*2.5, [const Color(0xFFFFD700).withOpacity(0.5), Colors.transparent]));
      } else {
          // Extinguished orb
          canvas.drawCircle(Offset.zero, 12, Paint()..color=const Color(0xFFCFD8DC));
      }
      canvas.restore();
    
    }

    // EXIT GATE
    if (engine.exitGate != null) {
      final center = engine.exitGate!;

      canvas.drawRect(Rect.fromCenter(center: center, width: 80, height: 80), Paint()..color=Colors.white); // Pearly gates
      canvas.drawRect(Rect.fromCenter(center: center, width: 60, height: 60), Paint()..color=const Color(0xFF81D4FA)); // Sky behind it
      canvas.drawLine(center + const Offset(0, -30), center + const Offset(0, 30), Paint()..color=const Color(0xFFFFD700)..strokeWidth=4); // gold division
      canvas.drawCircle(center + const Offset(-10, 0), 4, Paint()..color=const Color(0xFFFFD700)); // handles
      canvas.drawCircle(center + const Offset(10, 0), 4, Paint()..color=const Color(0xFFFFD700));
    
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
  @override bool shouldRepaint(covariant GamePainterA49 old) => true;
}
