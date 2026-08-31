import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'game_engine.dart';

class GamePainterA34 extends CustomPainter {
  GamePainterA34({required this.engine, this.images});
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

    canvas.drawRect(const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize), Paint()..color = const Color(0xFF110000)); // Dark obsidian
    final magma = Paint()..color=const Color(0xFFFF3D00)..style=PaintingStyle.stroke..strokeWidth=6;
    final rnd = math.Random(34);
    for(int i=0; i<15; i++) {
        Path crack = Path()..moveTo(rnd.nextDouble()*GameEngine.fieldSize, rnd.nextDouble()*GameEngine.fieldSize);
        crack.lineTo(rnd.nextDouble()*GameEngine.fieldSize, rnd.nextDouble()*GameEngine.fieldSize);
        crack.lineTo(rnd.nextDouble()*GameEngine.fieldSize, rnd.nextDouble()*GameEngine.fieldSize);
        canvas.drawPath(crack, magma);
        canvas.drawPath(crack, Paint()..color=const Color(0xFFFFEA00)..style=PaintingStyle.stroke..strokeWidth=2); // bright core
    }
    

    // WEATHER

    for (int i = 0; i < 40; i++) {
      double px = ((i * 55) + math.sin(engine.time + i)*20) % GameEngine.fieldSize;
      double py = ((i * 90) - engine.time * 60) % GameEngine.fieldSize;
      if(py < 0) py += GameEngine.fieldSize;
      canvas.drawCircle(Offset(px, py), 2 + (i%3).toDouble(), Paint()..color=(i%2==0)?const Color(0xFF9E9E9E):const Color(0xFFFF3D00)); // Ash and sparks
    }
    

    // OBSTACLES

    for (int i = 0; i < engine.obstacles.length; i++) {
      final obs = engine.obstacles[i];
      canvas.drawRect(obs.shift(const Offset(0, 15)), Paint()..color=Colors.black87);
      // Cooled basalt block
      canvas.drawRect(obs, Paint()..color=const Color(0xFF212121));
      canvas.drawRect(obs, Paint()..color=const Color(0xFF424242)..style=PaintingStyle.stroke..strokeWidth=3);
      // Lava cracks inside the rock
      canvas.drawLine(obs.topLeft, obs.center, Paint()..color=const Color(0xFFFF3D00)..strokeWidth=2);
      canvas.drawLine(obs.center, obs.bottomRight, Paint()..color=const Color(0xFFFF3D00)..strokeWidth=2);
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
          // Floating Magma Core
          canvas.drawCircle(Offset.zero, 12, Paint()..color=const Color(0xFFFFD600));
          canvas.drawCircle(Offset.zero, 16, Paint()..color=const Color(0xFFFF3D00)..style=PaintingStyle.stroke..strokeWidth=4);
          canvas.drawCircle(Offset.zero, tr*2.5, Paint()..shader = ui.Gradient.radial(Offset.zero, tr*2.5, [const Color(0xFFFF3D00).withValues(alpha: 0.7), Colors.transparent]));
          // Orbiting rocks
          canvas.save(); canvas.rotate(engine.time * 3);
          canvas.drawCircle(const Offset(22, 0), 4, Paint()..color=const Color(0xFF424242));
          canvas.drawCircle(const Offset(-22, 0), 4, Paint()..color=const Color(0xFF424242));
          canvas.restore();
      } else {
          // Cooled rock target
          canvas.drawCircle(Offset.zero, 12, Paint()..color=const Color(0xFF424242));
          canvas.drawCircle(Offset.zero, 12, Paint()..color=const Color(0xFF212121)..style=PaintingStyle.stroke..strokeWidth=2);
      }
      canvas.restore();
    
    }

    // EXIT GATE
    if (engine.exitGate != null) {
      final center = engine.exitGate!;

      canvas.drawCircle(center, 40, Paint()..color=const Color(0xFF212121));
      canvas.drawCircle(center, 30, Paint()..color=const Color(0xFFFF3D00)..style=PaintingStyle.stroke..strokeWidth=6);
      canvas.drawCircle(center, 25, Paint()..color=const Color(0xFF000000));
    
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
  @override bool shouldRepaint(covariant GamePainterA34 old) => true;
}
