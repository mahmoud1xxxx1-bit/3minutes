import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'game_engine.dart';

class GamePainterA38 extends CustomPainter {
  GamePainterA38({required this.engine, this.images});
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

    canvas.drawRect(const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize), Paint()..color = const Color(0xFF111111));
    final grate = Paint()..color=const Color(0xFF333333)..style=PaintingStyle.stroke..strokeWidth=2;
    for(double i=0; i<GameEngine.fieldSize; i+=30) {
        canvas.drawLine(Offset(i, 0), Offset(i, GameEngine.fieldSize), grate);
        canvas.drawLine(Offset(0, i), Offset(GameEngine.fieldSize, i), grate);
    }
    // Emergency red flashing lights
    double flash = (math.sin(engine.time * 5) > 0) ? 0.3 : 0.05;
    canvas.drawRect(const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize), Paint()..color = Colors.red.withOpacity(flash));
    

    // WEATHER

    for (int i = 0; i < 20; i++) {
      double px = ((i * 85) + engine.time * 60) % GameEngine.fieldSize;
      double py = ((i * 140)) % GameEngine.fieldSize;
      canvas.drawLine(Offset(px, py), Offset(px-10, py), Paint()..color=Colors.white.withOpacity(0.5)..strokeWidth=1); // flying debris/sparks
    }
    

    // OBSTACLES

    for (int i = 0; i < engine.obstacles.length; i++) {
      final obs = engine.obstacles[i];
      canvas.drawRect(obs.shift(const Offset(0, 10)), Paint()..color=Colors.black);
      canvas.drawRect(obs, Paint()..color=const Color(0xFF263238)); // Server rack
      for(double y = obs.top + 10; y < obs.bottom; y+=60) {
          canvas.drawRect(Rect.fromLTWH(obs.left+5, y, obs.width-10, 5), Paint()..color=const Color(0xFF111111));
          // blinking server lights
          canvas.drawCircle(Offset(obs.left+10, y+2), 2, Paint()..color=[Colors.red, Colors.green, Colors.blue][(i+y.toInt())%3]);
      }
    }
    

    // TARGETS
    for (int i = 0; i < engine.targets.length; i++) {
      if (i < engine.currentTargetIndex) continue;
      final target = engine.targets[i];
      final tr = GameEngine.targetRadius; 
      double floatOffset = math.sin(engine.time * 4 + i) * 5;

      final isNext = i == engine.currentTargetIndex;
      canvas.drawOval(Rect.fromCenter(center: target + const Offset(0, 15), width: tr*1.5, height: tr*0.8), Paint()..color=Colors.black54);
      canvas.save(); canvas.translate(target.dx, target.dy - floatOffset);
      if (isNext) {
          // Glowing Data Core
          canvas.drawRect(const Rect.fromLTWH(-10, -15, 20, 30), Paint()..color=const Color(0xFF00FF00));
          canvas.drawRect(const Rect.fromLTWH(-10, -15, 20, 30), Paint()..color=Colors.white..style=PaintingStyle.stroke..strokeWidth=2);
          for(double y=-10; y<15; y+=40) canvas.drawLine(Offset(-6, y), Offset(6, y), Paint()..color=Colors.black..strokeWidth=2);
          canvas.drawCircle(Offset.zero, tr*2.5, Paint()..shader = ui.Gradient.radial(Offset.zero, tr*2.5, [const Color(0xFF00FF00).withOpacity(0.4), Colors.transparent]));
      } else {
          // Dead data core
          canvas.drawRect(const Rect.fromLTWH(-8, -12, 16, 24), Paint()..color=const Color(0xFF37474F));
      }
      canvas.restore();
    
    }

    // EXIT GATE
    if (engine.exitGate != null) {
      final center = engine.exitGate!;

      canvas.drawRect(Rect.fromCenter(center: center, width: 80, height: 80), Paint()..color=const Color(0xFF263238));
      canvas.drawRect(Rect.fromCenter(center: center, width: 60, height: 60), Paint()..color=const Color(0xFF000000));
      // Airlock teeth
      canvas.save(); canvas.translate(center.dx, center.dy); canvas.rotate(engine.time * 2);
      for(int a=0; a<4; a++) {
         canvas.rotate(math.pi/2);
         canvas.drawRect(const Rect.fromLTWH(-10, -30, 20, 10), Paint()..color=const Color(0xFF78909C));
      }
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
  @override bool shouldRepaint(covariant GamePainterA38 old) => true;
}
