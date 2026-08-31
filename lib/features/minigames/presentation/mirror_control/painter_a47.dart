import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'game_engine.dart';

class GamePainterA47 extends CustomPainter {
  GamePainterA47({required this.engine, this.images});
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

    canvas.drawRect(const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize), Paint()..color = const Color(0xFF00050A)); // Deep void
    // Abstract geometric nodes connecting
    final line = Paint()..color=const Color(0xFF00FFFF).withValues(alpha: 0.2)..strokeWidth=1;
    final rnd = math.Random(47);
    List<Offset> nodes = [];
    for(int i=0; i<30; i++) {
      nodes.add(Offset(rnd.nextDouble()*GameEngine.fieldSize, rnd.nextDouble()*GameEngine.fieldSize));
    }
    for(int i=0; i<nodes.length; i++) {
        for(int j=i+1; j<nodes.length; j++) {
            if((nodes[i] - nodes[j]).distance < 200) canvas.drawLine(nodes[i], nodes[j], line);
        }
    }
    

    // WEATHER

    // Floating subatomic particles
    for (int i = 0; i < 40; i++) {
      double px = ((i * 55) + math.sin(engine.time*3 + i)*50) % GameEngine.fieldSize;
      double py = ((i * 110) + math.cos(engine.time*2 + i)*50) % GameEngine.fieldSize;
      canvas.drawCircle(Offset(px, py), 2, Paint()..color=const Color(0xFFFF00FF));
    }
    

    // OBSTACLES

    for (int i = 0; i < engine.obstacles.length; i++) {
      final obs = engine.obstacles[i];
      // Atom structure
      canvas.drawCircle(obs.center, 8, Paint()..color=Colors.white);
      canvas.save(); canvas.translate(obs.center.dx, obs.center.dy);
      canvas.rotate(engine.time * 2 + i);
      canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: obs.width, height: 10), Paint()..color=const Color(0xFF00FFFF)..style=PaintingStyle.stroke..strokeWidth=2);
      canvas.rotate(math.pi/3);
      canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: obs.width, height: 10), Paint()..color=const Color(0xFFFF00FF)..style=PaintingStyle.stroke..strokeWidth=2);
      canvas.rotate(math.pi/3);
      canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: obs.width, height: 10), Paint()..color=const Color(0xFF00FFFF)..style=PaintingStyle.stroke..strokeWidth=2);
      canvas.restore();
    }
    

    // TARGETS
    for (int i = 0; i < engine.targets.length; i++) {
      if (i < engine.currentTargetIndex) continue;
      final target = engine.targets[i];
      final tr = GameEngine.targetRadius; 
      double floatOffset = math.sin(engine.time * 4 + i) * 5;

      final isNext = i == engine.currentTargetIndex;
      canvas.save(); canvas.translate(target.dx, target.dy - floatOffset);
      if (isNext) {
          // Glowing Quark
          double pulse = 1.0 + math.sin(engine.time * 10) * 0.2;
          canvas.save(); canvas.scale(pulse, pulse);
          canvas.drawCircle(Offset.zero, 15, Paint()..color=const Color(0xFFFF00FF));
          canvas.drawCircle(Offset.zero, 10, Paint()..color=Colors.white);
          canvas.restore();
          canvas.drawCircle(Offset.zero, tr*2, Paint()..shader = ui.Gradient.radial(Offset.zero, tr*2, [const Color(0xFFFF00FF).withValues(alpha: 0.6), Colors.transparent]));
      } else {
          // Collapsed wave function (dot)
          canvas.drawCircle(Offset.zero, 4, Paint()..color=const Color(0xFF424242));
      }
      canvas.restore();
    
    }

    // EXIT GATE
    if (engine.exitGate != null) {
      final center = engine.exitGate!;

      canvas.drawCircle(center, 45, Paint()..color=const Color(0xFF00050A));
      canvas.save(); canvas.translate(center.dx, center.dy); canvas.rotate(engine.time * 4);
      for(double r=10; r<=40; r+=40) {
          canvas.drawCircle(Offset.zero, r, Paint()..color=const Color(0xFF00FFFF).withValues(alpha: 0.5)..style=PaintingStyle.stroke..strokeWidth=2);
      }
      canvas.drawLine(const Offset(-45, 0), const Offset(45, 0), Paint()..color=const Color(0xFFFF00FF)..strokeWidth=3);
      canvas.drawLine(const Offset(0, -45), const Offset(0, 45), Paint()..color=const Color(0xFFFF00FF)..strokeWidth=3);
      canvas.restore();
    
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
  @override bool shouldRepaint(covariant GamePainterA47 old) => true;
}
