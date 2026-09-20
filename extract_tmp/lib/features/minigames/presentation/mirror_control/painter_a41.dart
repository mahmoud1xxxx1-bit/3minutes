import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'game_engine.dart';

class GamePainterA41 extends CustomPainter {
  GamePainterA41({required this.engine, this.images});
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

    canvas.drawRect(const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize), Paint()..color = const Color(0xFF0F172A)); // Dark slate
    final rnd = math.Random(41);
    for(int i=0; i<30; i++) {
        double px = rnd.nextDouble()*GameEngine.fieldSize;
        double py = rnd.nextDouble()*GameEngine.fieldSize;
        // Cyan and Magenta moss patches
        canvas.drawCircle(Offset(px, py), 20 + rnd.nextDouble()*30, Paint()..color=(i%2==0)?const Color(0xFF00E5FF).withOpacity(0.1):const Color(0xFFFF00FF).withOpacity(0.1));
    }
    

    // WEATHER

    for (int i = 0; i < 20; i++) {
      double px = ((i * 75) + math.sin(engine.time + i)*10) % GameEngine.fieldSize;
      double py = ((i * 120) + engine.time * 80) % GameEngine.fieldSize;
      canvas.drawLine(Offset(px, py), Offset(px, py+10), Paint()..color=Colors.cyanAccent.withOpacity(0.5)..strokeWidth=2); // dripping water
      // Ripples on ground if py is near bottom of its cycle
      if (py > GameEngine.fieldSize - 20) {
          canvas.drawOval(Rect.fromCenter(center: Offset(px, py), width: 30, height: 10), Paint()..color=Colors.cyanAccent.withOpacity(0.3)..style=PaintingStyle.stroke..strokeWidth=2);
      }
    }
    

    // OBSTACLES

    for (int i = 0; i < engine.obstacles.length; i++) {
      final obs = engine.obstacles[i];
      canvas.drawRect(obs.shift(const Offset(0, 15)), Paint()..color=Colors.black87);
      // Giant Stalagmite (Top down cross section)
      canvas.drawRect(obs, Paint()..color=const Color(0xFF334155));
      canvas.drawRect(obs.deflate(4.0), Paint()..color=const Color(0xFF475569));
      canvas.drawRect(obs.deflate(10.0), Paint()..color=const Color(0xFF64748B));
      // Glowing fungi on rock
      canvas.drawCircle(obs.center + const Offset(-10, -10), 6, Paint()..color=const Color(0xFFFF00FF));
      canvas.drawCircle(obs.center + const Offset(10, 15), 4, Paint()..color=const Color(0xFF00E5FF));
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
          // Glowing Crystal
          Path crystal = Path()..moveTo(0, -20)..lineTo(10, 0)..lineTo(0, 20)..lineTo(-10, 0)..close();
          canvas.drawPath(crystal, Paint()..color=const Color(0xFF00E5FF));
          canvas.drawPath(crystal, Paint()..color=Colors.white..style=PaintingStyle.stroke..strokeWidth=2);
          canvas.drawCircle(Offset.zero, tr*2, Paint()..shader = ui.Gradient.radial(Offset.zero, tr*2, [const Color(0xFF00E5FF).withOpacity(0.5), Colors.transparent]));
      } else {
          // Dull rock
          canvas.drawCircle(Offset.zero, 12, Paint()..color=const Color(0xFF475569));
      }
      canvas.restore();
    
    }

    // EXIT GATE
    if (engine.exitGate != null) {
      final center = engine.exitGate!;

      canvas.drawCircle(center, 40, Paint()..color=const Color(0xFF1E293B));
      canvas.drawCircle(center, 30, Paint()..color=const Color(0xFF000000));
      // Magenta rim
      canvas.drawCircle(center, 30, Paint()..color=const Color(0xFFFF00FF)..style=PaintingStyle.stroke..strokeWidth=4);
      canvas.drawCircle(center, 30, Paint()..shader = ui.Gradient.radial(center, 40, [const Color(0xFFFF00FF).withOpacity(0.4), Colors.transparent]));
    
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
  @override bool shouldRepaint(covariant GamePainterA41 old) => true;
}
