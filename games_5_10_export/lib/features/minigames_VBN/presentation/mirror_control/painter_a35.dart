import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'game_engine.dart';

class GamePainterA35 extends CustomPainter {
  GamePainterA35({required this.engine, this.images});
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

    canvas.drawRect(const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize), Paint()..color = const Color(0xFFD7CCC8)); // Sandstone
    final grout = Paint()..color=const Color(0xFFA1887F)..style=PaintingStyle.stroke..strokeWidth=2;
    for(double i=0; i<GameEngine.fieldSize; i+=120) {
       canvas.drawLine(Offset(i, 0), Offset(i, GameEngine.fieldSize), grout);
       canvas.drawLine(Offset(0, i), Offset(GameEngine.fieldSize, i), grout);
       // Eye of Horus abstract glyph
       canvas.drawArc(Rect.fromCenter(center: Offset(i+60, i+60), width: 40, height: 20), 0, math.pi, false, grout);
       canvas.drawCircle(Offset(i+60, i+60), 5, grout);
    }
    

    // WEATHER

    for (int i = 0; i < 25; i++) {
      double px = ((i * 45) + math.sin(engine.time*0.2 + i)*10) % GameEngine.fieldSize;
      double py = ((i * 90) + engine.time * 20) % GameEngine.fieldSize;
      canvas.drawCircle(Offset(px, py), 2, Paint()..color=const Color(0xFFFFE082).withOpacity(0.5)); // Gold dust
    }
    

    // OBSTACLES

    for (int i = 0; i < engine.obstacles.length; i++) {
      final obs = engine.obstacles[i];
      canvas.drawRect(obs.shift(const Offset(10, 20)), Paint()..color=Colors.black38);
      // Golden Sarcophagus / Pillar
      canvas.drawRRect(RRect.fromRectAndRadius(obs, const Radius.circular(10)), Paint()..color=const Color(0xFFFFD54F));
      canvas.drawRRect(RRect.fromRectAndRadius(obs, const Radius.circular(10)), Paint()..color=const Color(0xFFF57F17)..style=PaintingStyle.stroke..strokeWidth=4);
      // Lapis lazuli and ruby bands
      canvas.drawRect(Rect.fromLTWH(obs.left, obs.top+20, obs.width, 10), Paint()..color=const Color(0xFF1565C0));
      canvas.drawRect(Rect.fromLTWH(obs.left, obs.bottom-30, obs.width, 10), Paint()..color=const Color(0xFFC62828));
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
          // Glowing Ankh
          canvas.drawCircle(const Offset(0, -10), 6, Paint()..color=const Color(0xFF00E5FF)..style=PaintingStyle.stroke..strokeWidth=3);
          canvas.drawLine(const Offset(0, -4), const Offset(0, 10), Paint()..color=const Color(0xFF00E5FF)..strokeWidth=3);
          canvas.drawLine(const Offset(-8, 0), const Offset(8, 0), Paint()..color=const Color(0xFF00E5FF)..strokeWidth=3);
          canvas.drawCircle(Offset.zero, tr*2, Paint()..shader = ui.Gradient.radial(Offset.zero, tr*2, [const Color(0xFF00E5FF).withOpacity(0.5), Colors.transparent]));
      } else {
          // Stone scarab
          canvas.drawOval(const Rect.fromLTWH(-8, -10, 16, 20), Paint()..color=const Color(0xFF8D6E63));
          canvas.drawLine(const Offset(0, -10), const Offset(0, 10), Paint()..color=const Color(0xFF5D4037)..strokeWidth=2);
      }
      canvas.restore();
    
    }

    // EXIT GATE
    if (engine.exitGate != null) {
      final center = engine.exitGate!;

      canvas.drawRect(Rect.fromCenter(center: center, width: 80, height: 80), Paint()..color=const Color(0xFFFFD54F));
      canvas.drawCircle(center, 30, Paint()..color=const Color(0xFF000000));
      // Golden rays
      canvas.save(); canvas.translate(center.dx, center.dy); canvas.rotate(engine.time);
      for(int a=0; a<8; a++) {
          canvas.rotate(math.pi/4);
          canvas.drawLine(const Offset(30, 0), const Offset(45, 0), Paint()..color=const Color(0xFFF57F17)..strokeWidth=4);
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
  @override bool shouldRepaint(covariant GamePainterA35 old) => true;
}
