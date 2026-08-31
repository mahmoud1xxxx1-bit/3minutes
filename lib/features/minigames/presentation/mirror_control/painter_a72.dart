import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'game_engine.dart';

class GamePainterA72 extends CustomPainter {
  GamePainterA72({required this.engine, this.images});
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

    final rnd = math.Random(72);

    // 1. FLOOR & BACKGROUND (Clockwork Automaton Factory)
    canvas.drawRect(const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize), Paint()..color = const Color(0xFF2A1F1A));

    // Giant Gears in Background
    for (int i = 0; i < 8; i++) {
      double cx = rnd.nextDouble() * GameEngine.fieldSize;
      double cy = rnd.nextDouble() * GameEngine.fieldSize;
      double r = rnd.nextDouble() * 150 + 50;
      double rotation = engine.time * (i % 2 == 0 ? 1 : -1) * (100/r);

      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(rotation);
      
      final gearPaint = Paint()..color = const Color(0xFF5C4033)..style = PaintingStyle.fill;
      canvas.drawCircle(Offset.zero, r, gearPaint);
      
      for(int t=0; t<12; t++) {
        canvas.rotate(math.pi/6);
        canvas.drawRect(Rect.fromCenter(center: Offset(0, -r), width: 20, height: 30), gearPaint);
      }
      
      canvas.drawCircle(Offset.zero, r * 0.6, Paint()..color = const Color(0xFF2A1F1A));
      canvas.drawCircle(Offset.zero, r * 0.2, gearPaint);
      
      canvas.restore();
    }

    // 2. WEATHER / PARTICLES (Steam)
    for (int i = 0; i < 150; i++) {
      double px = (rnd.nextDouble() * GameEngine.fieldSize + math.sin(engine.time + i) * 20) % GameEngine.fieldSize;
      double py = (GameEngine.fieldSize - (rnd.nextDouble() * GameEngine.fieldSize + engine.time * 40)) % GameEngine.fieldSize;
      
      canvas.drawCircle(Offset(px, py), rnd.nextDouble() * 15 + 5, Paint()..color = Colors.white.withValues(alpha: 0.1)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
    }

    // 3. OBSTACLES
    for (int i = 0; i < engine.obstacles.length; i++) {
        final obs = engine.obstacles[i];
        canvas.drawRect(obs.shift(const Offset(0, 15)), Paint()..color=Colors.black54);
        
        // Brass/Copper Crates
        canvas.drawRect(obs, Paint()..color=const Color(0xFFB87333)); // Copper
        canvas.drawRect(obs.deflate(5), Paint()..color=const Color(0xFFCD7F32)..style=PaintingStyle.stroke..strokeWidth=3); // Bronze trim
        
        // Rivets
        canvas.drawCircle(Offset(obs.left + 5, obs.top + 5), 2, Paint()..color=Colors.black54);
        canvas.drawCircle(Offset(obs.right - 5, obs.top + 5), 2, Paint()..color=Colors.black54);
        canvas.drawCircle(Offset(obs.left + 5, obs.bottom - 5), 2, Paint()..color=Colors.black54);
        canvas.drawCircle(Offset(obs.right - 5, obs.bottom - 5), 2, Paint()..color=Colors.black54);
    }

    // 4. TARGETS
    for (int i = 0; i < engine.targets.length; i++) {
        if (i < engine.currentTargetIndex) continue; 
        
        bool isActive = (i == engine.currentTargetIndex);
        final target = engine.targets[i];

        if (isActive) {
            double p = 1.0 + math.sin(engine.time*8)*0.2;
            canvas.drawCircle(target, 35*p, Paint()..color=Colors.lightBlueAccent.withValues(alpha: 0.6)..maskFilter=const MaskFilter.blur(BlurStyle.normal, 3));
            canvas.drawCircle(target, 20*p, Paint()..color=Colors.white.withValues(alpha: 0.8)..maskFilter=const MaskFilter.blur(BlurStyle.normal, 5));
        }

        canvas.saveLayer(Rect.fromCenter(center: target, width: 80, height: 80), Paint()..color=Colors.white.withValues(alpha: isActive ? 1.0 : 0.3));
        
        // Cog Target
        canvas.save();
        canvas.translate(target.dx, target.dy);
        canvas.rotate(engine.time*2);
        for(int t=0; t<6; t++) {
           canvas.rotate(math.pi/3);
           canvas.drawRect(Rect.fromCenter(center: const Offset(0, -12), width: 8, height: 8), Paint()..color=Colors.grey);
        }
        canvas.drawCircle(Offset.zero, 10, Paint()..color=Colors.blueGrey);
        canvas.drawCircle(Offset.zero, 4, Paint()..color=Colors.white);
        canvas.restore();
        
        canvas.restore();
    }

    // 5. EXIT GATE
    if (engine.exitGate != null) {
        canvas.drawCircle(engine.exitGate!, 45, Paint()..color=Colors.amber..style=PaintingStyle.stroke..strokeWidth=8);
        canvas.drawCircle(engine.exitGate!, 35, Paint()..color=Colors.orange..style=PaintingStyle.stroke..strokeWidth=4..maskFilter=const MaskFilter.blur(BlurStyle.normal, 5));
    }

    // ==========================================
    // 5. UNIFIED CHASER IDENTITY
    // ==========================================
    if (images != null && images!['enemy'] != null) {
      if (engine.chaserInWall) {
          canvas.drawCircle(engine.chaserPos, GameEngine.chaserRadius * 1.5, Paint()..color = Colors.black87);
          canvas.drawCircle(engine.chaserPos, GameEngine.chaserRadius * 0.8, Paint()..color = Colors.black);
          final eyeGlow = Paint()..color = Colors.red.withValues(alpha: 0.6)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
          canvas.drawCircle(engine.chaserPos + const Offset(-6, -4), 8, eyeGlow);
          canvas.drawCircle(engine.chaserPos + const Offset(6, -4), 8, eyeGlow);
          canvas.drawCircle(engine.chaserPos + const Offset(-6, -4), 3, Paint()..color = Colors.white);
          canvas.drawCircle(engine.chaserPos + const Offset(6, -4), 3, Paint()..color = Colors.white);
      } else {
          canvas.drawCircle(engine.chaserPos + const Offset(0, 15), GameEngine.chaserRadius, Paint()..color=Colors.black.withValues(alpha: 0.35));
          if(engine.chaserStunTimer <= GameEngine.recoveryDuration) {
             double pulse = 1.0 + math.sin(engine.time * 20) * 0.1;
             canvas.drawCircle(engine.chaserPos, GameEngine.chaserRadius * 2.5 * pulse, Paint()..color = Colors.redAccent.withValues(alpha: 0.3));
          }
          canvas.save(); canvas.translate(engine.chaserPos.dx, engine.chaserPos.dy);
          if (engine.chaserVelocity.dx > 0) canvas.scale(-1, 1);
          canvas.translate(0, math.sin(engine.time * 6) * 4); 
          
          Paint chaserPaint = (engine.chaserStunTimer > GameEngine.recoveryDuration) 
              ? (Paint()..color=Colors.grey.withValues(alpha: 0.5)) 
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
      canvas.drawCircle(engine.playerPos + const Offset(0, 15), GameEngine.playerRadius, Paint()..color=Colors.black.withValues(alpha: 0.35));
      
      double vLen = engine.playerVelocity.distance;
      if (vLen > 0) {
        canvas.save(); canvas.translate(engine.playerPos.dx, engine.playerPos.dy);
        canvas.rotate(math.atan2(engine.playerVelocity.dy, engine.playerVelocity.dx));
        canvas.drawOval(Rect.fromCenter(center: const Offset(-20, 0), width: 40, height: 10), Paint()..color=Colors.white.withValues(alpha: 0.5));
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

  @override bool shouldRepaint(covariant GamePainterA72 old) => true;
}
