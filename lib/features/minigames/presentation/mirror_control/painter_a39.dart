import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'game_engine.dart';

class GamePainterA39 extends CustomPainter {
  GamePainterA39({required this.engine, this.images});
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

    canvas.drawRect(const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize), Paint()..color = const Color(0xFF311B92)); // Deep indigo grass
    final rnd = math.Random(39);
    for(int i=0; i<60; i++) {
        canvas.drawCircle(Offset(rnd.nextDouble()*GameEngine.fieldSize, rnd.nextDouble()*GameEngine.fieldSize), 3, Paint()..color=const Color(0xFF7E57C2).withOpacity(0.5));
    }
    

    // WEATHER

    for (int i = 0; i < 30; i++) {
      double px = ((i * 55) + math.sin(engine.time + i)*40) % GameEngine.fieldSize;
      double py = ((i * 90) + math.cos(engine.time + i)*40) % GameEngine.fieldSize;
      canvas.drawCircle(Offset(px, py), 3, Paint()..color=Colors.white);
      canvas.drawCircle(Offset(px, py), 8, Paint()..shader=ui.Gradient.radial(Offset(px, py), 8, [Colors.white, Colors.transparent]));
    }
    

    // OBSTACLES

    for (int i = 0; i < engine.obstacles.length; i++) {
      final obs = engine.obstacles[i];
      canvas.drawRect(obs.shift(const Offset(0, 20)), Paint()..color=Colors.black54);
      // Giant Mushroom Cap (Top down view)
      canvas.drawRect(obs, Paint()..color=const Color(0xFF9C27B0)); // Purple cap
      canvas.drawRect(obs, Paint()..shader=ui.Gradient.radial(obs.center, obs.width/2, [const Color(0xFFE040FB), Colors.transparent])); // Glow
      // Spots
      canvas.drawCircle(obs.center + const Offset(-10, -10), obs.width/6, Paint()..color=const Color(0xFFF3E5F5));
      canvas.drawCircle(obs.center + const Offset(15, 5), obs.width/8, Paint()..color=const Color(0xFFF3E5F5));
      canvas.drawCircle(obs.center + const Offset(-5, 15), obs.width/5, Paint()..color=const Color(0xFFF3E5F5));
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
          // Trapped Star
          canvas.save(); canvas.rotate(engine.time * 3);
          Path star = Path();
          for(int s=0; s<10; s++) {
             double r = (s%2==0) ? 15.0 : 6.0;
             double angle = s * math.pi / 5;
             if(s==0) star.moveTo(r*math.cos(angle), r*math.sin(angle)); else star.lineTo(r*math.cos(angle), r*math.sin(angle));
          }
          star.close();
          canvas.drawPath(star, Paint()..color=const Color(0xFFFFFF00));
          canvas.restore();
          canvas.drawCircle(Offset.zero, tr*2.5, Paint()..shader = ui.Gradient.radial(Offset.zero, tr*2.5, [const Color(0xFFFFFF00).withOpacity(0.6), Colors.transparent]));
      } else {
          // Acorn cup / empty
          canvas.drawCircle(Offset.zero, 10, Paint()..color=const Color(0xFF512DA8));
      }
      canvas.restore();
    
    }

    // EXIT GATE
    if (engine.exitGate != null) {
      final center = engine.exitGate!;

      canvas.drawCircle(center, 40, Paint()..color=const Color(0xFFD500F9));
      canvas.drawCircle(center, 30, Paint()..color=const Color(0xFF311B92));
      canvas.drawCircle(center, 30, Paint()..color=Colors.white..style=PaintingStyle.stroke..strokeWidth=2);
      canvas.drawCircle(center, 15, Paint()..shader = ui.Gradient.radial(center, 15, [Colors.white, Colors.transparent]));
    
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
  @override bool shouldRepaint(covariant GamePainterA39 old) => true;
}
