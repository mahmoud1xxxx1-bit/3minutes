import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'game_engine.dart';

class GamePainterA54 extends CustomPainter {
  GamePainterA54({required this.engine, this.images});
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

    final rnd = math.Random(54);

    // 1. FLOOR & BACKGROUND - Neon Sushi Bar
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize), 
      Paint()..color = const Color(0xFF0D0221)
    );

    // Neon grid
    for(double i=0; i<GameEngine.fieldSize; i+=50) {
       canvas.drawLine(Offset(i, 0), Offset(i, GameEngine.fieldSize), Paint()..color=const Color(0xFF26C485).withOpacity(0.2)..strokeWidth=2);
       canvas.drawLine(Offset(0, i), Offset(GameEngine.fieldSize, i), Paint()..color=const Color(0xFF26C485).withOpacity(0.2)..strokeWidth=2);
    }
    
    // Abstract neon signs on floor
    for(int i=0; i<5; i++) {
       double nx = rnd.nextDouble() * GameEngine.fieldSize;
       double ny = rnd.nextDouble() * GameEngine.fieldSize;
       canvas.drawCircle(Offset(nx, ny), 40, Paint()..color=const Color(0xFFFF007F).withOpacity(0.1)..maskFilter=const MaskFilter.blur(BlurStyle.normal, 3));
       canvas.drawRect(Rect.fromCenter(center: Offset(nx, ny), width: 30, height: 10), Paint()..color=const Color(0xFFFF007F)..maskFilter=const MaskFilter.blur(BlurStyle.solid, 5));
    }

    // 2. WEATHER / PARTICLES - Neon sparks
    for(int i = 0; i < 25; i++) {
      double sx = (rnd.nextDouble() * GameEngine.fieldSize + math.cos(engine.time*2+i) * 10) % GameEngine.fieldSize;
      double sy = (rnd.nextDouble() * GameEngine.fieldSize + engine.time * 40) % GameEngine.fieldSize;
      canvas.drawCircle(Offset(sx, sy), 2, Paint()..color=Colors.cyanAccent..maskFilter=const MaskFilter.blur(BlurStyle.solid, 2));
    }

    // 3. OBSTACLES - Conveyor belt tables / Neon blocks
    for (int i = 0; i < engine.obstacles.length; i++) {
        final obs = engine.obstacles[i];
        
        canvas.drawRect(obs.shift(const Offset(0, 15)), Paint()..color=const Color(0xFF000000).withOpacity(0.8));
        
        // Neon edge
        canvas.drawRect(obs, Paint()..color=const Color(0xFF00F0FF)..maskFilter=const MaskFilter.blur(BlurStyle.normal, 3));
        // Solid body
        canvas.drawRect(obs, Paint()..color=const Color(0xFF1E1E24));
        
        // Sushi plate on top
        if (obs.width > 20 && obs.height > 20) {
           canvas.drawCircle(obs.center, 8, Paint()..color=Colors.white);
           canvas.drawRect(Rect.fromCenter(center: obs.center, width: 8, height: 4), Paint()..color=Colors.redAccent);
        }
    }

    // 4. TARGETS - Golden Sushi Rolls
    for (int i = 0; i < engine.targets.length; i++) {
        if (i < engine.currentTargetIndex) continue; 
        
        bool isActive = (i == engine.currentTargetIndex);
        final target = engine.targets[i];

        if (isActive) {
            double p = 1.0 + math.sin(engine.time*8)*0.2;
            canvas.drawCircle(target, 35*p, Paint()..color=Colors.pinkAccent.withOpacity(0.6)..maskFilter=const MaskFilter.blur(BlurStyle.normal, 3));
            canvas.drawCircle(target, 20*p, Paint()..color=Colors.white.withOpacity(0.8)..maskFilter=const MaskFilter.blur(BlurStyle.normal, 5));
        }

        canvas.saveLayer(Rect.fromCenter(center: target, width: 80, height: 80), Paint()..color=Colors.white.withOpacity(isActive ? 1.0 : 0.3));
        
        // Golden sushi
        canvas.drawCircle(target, 12, Paint()..color=Colors.amber);
        canvas.drawCircle(target, 6, Paint()..color=Colors.green);
        
        canvas.restore();
    }

    // 5. EXIT GATE - Neon Torii Gate
    if (engine.exitGate != null) {
        canvas.drawRect(Rect.fromCenter(center: engine.exitGate!, width: 70, height: 70), Paint()..color=Colors.redAccent.withOpacity(0.4)..maskFilter=const MaskFilter.blur(BlurStyle.normal, 3));
        canvas.drawLine(engine.exitGate! + const Offset(-35, -20), engine.exitGate! + const Offset(35, -20), Paint()..color=Colors.redAccent..strokeWidth=8);
        canvas.drawLine(engine.exitGate! + const Offset(-25, -20), engine.exitGate! + const Offset(-25, 30), Paint()..color=Colors.redAccent..strokeWidth=6);
        canvas.drawLine(engine.exitGate! + const Offset(25, -20), engine.exitGate! + const Offset(25, 30), Paint()..color=Colors.redAccent..strokeWidth=6);
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

  @override bool shouldRepaint(covariant GamePainterA54 old) => true;
}
