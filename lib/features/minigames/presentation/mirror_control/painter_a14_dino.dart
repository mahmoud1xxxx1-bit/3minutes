import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'game_engine.dart';

class GamePainterA14Dino extends CustomPainter {
  GamePainterA14Dino({required this.engine, this.images});

  final GameEngine engine;
  final Map<String, ui.Image>? images;

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / GameEngine.fieldSize;
    final scaleY = size.height / GameEngine.fieldSize;
    final scale = scaleX < scaleY ? scaleX : scaleY;
    
    final offsetX = (size.width - (GameEngine.fieldSize * scale)) / 2;
    final offsetY = (size.height - (GameEngine.fieldSize * scale)) / 2;

    canvas.translate(offsetX, offsetY);
    canvas.scale(scale, scale);
    canvas.clipRect(const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize));

    // 1. Draw Background (Jungle Mud)
    canvas.drawRect(const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize), Paint()..color = const Color(0xFF4A3C2A));

    // Dino footprints in the mud
    final printPaint = Paint()..color = const Color(0xFF38291A)..style = PaintingStyle.fill;
    for (int i = 0; i < 12; i++) {
      double px = (i * 90.0) % GameEngine.fieldSize;
      double py = (i * 150.0) % GameEngine.fieldSize;
      canvas.save();
      canvas.translate(px, py);
      canvas.rotate((i * 30.0) * math.pi / 180.0);
      
      // Three toes
      canvas.drawOval(const Rect.fromLTWH(-8, -10, 6, 12), printPaint); // Left toe
      canvas.drawOval(const Rect.fromLTWH(-3, -15, 6, 14), printPaint); // Middle toe
      canvas.drawOval(const Rect.fromLTWH(2, -10, 6, 12), printPaint); // Right toe
      // Heel pad
      canvas.drawCircle(const Offset(0, 2), 6, printPaint);
      
      canvas.restore();
    }

    // 2. Draw Obstacles (Prehistoric Ferns / Trunks)
    for (int i = 0; i < engine.obstacles.length; i++) {
      final obs = engine.obstacles[i];
      
      // Tree trunk base
      final trunkBase = Paint()..color = const Color(0xFF3B2F2F);
      canvas.drawOval(Rect.fromCenter(center: obs.center, width: obs.width * 0.8, height: obs.height * 0.8), trunkBase);
      
      // Fern leaves spreading out
      final fernPaint = Paint()..color = const Color(0xFF228B22);
      
      canvas.save();
      canvas.translate(obs.center.dx, obs.center.dy);
      for(int j=0; j<8; j++) {
        canvas.rotate(math.pi / 4);
        final leaf = Path()..moveTo(0, 0)..quadraticBezierTo(5, 10, 0, 20)..quadraticBezierTo(-5, 10, 0, 0)..close();
        canvas.drawPath(leaf, fernPaint);
      }
      canvas.restore();
    }

    // 3. Draw Targets (Amber Fossils)
    for (int i = 0; i < engine.targets.length; i++) {
      if (i < engine.currentTargetIndex) continue;
      
      final target = engine.targets[i];
      final isNext = i == engine.currentTargetIndex;
      
      if (isNext) {
        final glowPaint = Paint()
          ..color = const Color(0xFFFFB300).withValues(alpha: 0.5)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        canvas.drawCircle(target, GameEngine.targetRadius * 1.5, glowPaint);
      }

      final amberBase = Paint()..color = isNext ? const Color(0xFFFFC107) : const Color(0xFFB08D00);
      final amberHighlight = Paint()..color = Colors.white.withValues(alpha: 0.4);
      
      canvas.save();
      canvas.translate(target.dx, target.dy);
      canvas.rotate(math.sin(engine.time * 2 + i) * 0.2); // Gentle sway
      
      // Irregular oval
      final amberPath = Path()..moveTo(0, -12)..quadraticBezierTo(10, -10, 10, 0)..quadraticBezierTo(8, 12, 0, 12)..quadraticBezierTo(-10, 10, -10, 0)..close();
      canvas.drawPath(amberPath, amberBase);
      
      // Mosquito inside
      final bugPaint = Paint()..color = const Color(0xFF332211);
      canvas.drawOval(const Rect.fromLTWH(-2, -3, 4, 6), bugPaint);
      canvas.drawLine(const Offset(-2, -2), const Offset(-5, -5), bugPaint); // Leg
      canvas.drawLine(const Offset(2, -2), const Offset(5, -5), bugPaint); // Leg
      
      // Shine
      canvas.drawArc(const Rect.fromLTWH(-8, -8, 16, 16), math.pi, math.pi/2, false, amberHighlight..style = PaintingStyle.stroke..strokeWidth = 2);

      canvas.restore();
    }

    // 4. Draw Exit Gate (Cave Entrance)
    if (engine.exitGate != null) {
      canvas.save();
      canvas.translate(engine.exitGate!.dx, engine.exitGate!.dy);

      final rockPaint = Paint()..color = const Color(0xFF696969);
      final darkCave = Paint()..color = const Color(0xFF111111);

      canvas.drawArc(const Rect.fromLTWH(-35, -25, 70, 60), -math.pi, math.pi, true, rockPaint);
      canvas.drawArc(const Rect.fromLTWH(-25, -15, 50, 45), -math.pi, math.pi, true, darkCave);
      
      // Two glowing eyes in the cave
      double blink = (engine.time * 5).toInt() % 10 == 0 ? 0 : 2; // Occasional blink
      canvas.drawOval(Rect.fromLTWH(-8, -5, 4, blink), Paint()..color = Colors.redAccent);
      canvas.drawOval(Rect.fromLTWH(4, -5, 4, blink), Paint()..color = Colors.redAccent);

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

  @override
  bool shouldRepaint(covariant GamePainterA14Dino oldDelegate) => true; 
}
