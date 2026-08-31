import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'game_engine.dart';

class GamePainterA15Steampunk extends CustomPainter {
  GamePainterA15Steampunk({required this.engine, this.images});

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

    // 1. Draw Background (Copper Metal Plates)
    canvas.drawRect(const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize), Paint()..color = const Color(0xFF5C3A21)); // Dark copper

    final plateBorder = Paint()..color = const Color(0xFF331A0F)..strokeWidth = 2.0;
    final rivetPaint = Paint()..color = const Color(0xFF221100);
    
    for (double y = 0; y < GameEngine.fieldSize; y+=50) {
      canvas.drawLine(Offset(0, y), Offset(GameEngine.fieldSize, y), plateBorder);
      for (double x = 0; x < GameEngine.fieldSize; x+=50) {
        canvas.drawLine(Offset(x, 0), Offset(x, GameEngine.fieldSize), plateBorder);
        // Rivets in corners
        canvas.drawCircle(Offset(x + 5, y + 5), 1.5, rivetPaint);
        canvas.drawCircle(Offset(x + 45, y + 5), 1.5, rivetPaint);
        canvas.drawCircle(Offset(x + 5, y + 45), 1.5, rivetPaint);
        canvas.drawCircle(Offset(x + 45, y + 45), 1.5, rivetPaint);
      }
    }

    // 2. Draw Obstacles (Brass Pipes and Valves)
    for (int i = 0; i < engine.obstacles.length; i++) {
      final obs = engine.obstacles[i];
      
      final pipeColor = const Color(0xFFB5A642); // Brass
      final pipeShadow = const Color(0xFF7A6F2A);
      
      // Main pipe body
      canvas.drawRect(obs, Paint()..color = pipeColor);
      canvas.drawRect(Rect.fromLTWH(obs.left, obs.top + 5, obs.width, obs.height - 10), Paint()..color = pipeShadow); // rounded shading
      
      // Valve wheel
      if (i % 2 == 0) {
        final wheelColor = const Color(0xFF8B0000); // Red wheel
        canvas.save();
        canvas.translate(obs.center.dx, obs.center.dy);
        canvas.rotate(engine.time * 2); // Steam turning it
        canvas.drawCircle(Offset.zero, 12, Paint()..color = wheelColor..style = PaintingStyle.stroke..strokeWidth = 3);
        for(int k=0; k<4; k++) {
          canvas.rotate(math.pi / 2);
          canvas.drawLine(Offset.zero, const Offset(0, 12), Paint()..color = wheelColor..strokeWidth = 3);
        }
        canvas.drawCircle(Offset.zero, 4, Paint()..color = Colors.black);
        canvas.restore();
      }
      
      // Steam puffs from pipes
      final steamPaint = Paint()..color = Colors.white.withValues(alpha: 0.3)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);
      double sy = obs.top - (engine.time * 20 % 20);
      canvas.drawCircle(Offset(obs.center.dx, sy), 8 + (engine.time * 5 % 5), steamPaint);
    }

    // 3. Draw Targets (Glowing Vacuum Tubes)
    for (int i = 0; i < engine.targets.length; i++) {
      if (i < engine.currentTargetIndex) continue;
      
      final target = engine.targets[i];
      final isNext = i == engine.currentTargetIndex;
      
      if (isNext) {
        final glowPaint = Paint()
          ..color = const Color(0xFFFF9900).withValues(alpha: 0.5)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        canvas.drawCircle(target, GameEngine.targetRadius * 1.5, glowPaint);
      }

      canvas.save();
      canvas.translate(target.dx, target.dy);
      
      final glass = Paint()..color = const Color(0x88AAAAFF);
      final filament = Paint()..color = isNext ? const Color(0xFFFF8800) : const Color(0xFF553300)..strokeWidth = 2;
      final base = Paint()..color = const Color(0xFF333333);
      
      canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-6, -12, 12, 20), const Radius.circular(5)), glass);
      canvas.drawRect(const Rect.fromLTWH(-5, 8, 10, 6), base);
      
      // Filament wires
      canvas.drawLine(const Offset(-2, 8), const Offset(-2, -5), filament);
      canvas.drawLine(const Offset(2, 8), const Offset(2, -5), filament);
      canvas.drawLine(const Offset(-2, -5), const Offset(2, -5), filament);
      
      canvas.restore();
    }

    // 4. Draw Exit Gate (Furnace Door)
    if (engine.exitGate != null) {
      canvas.save();
      canvas.translate(engine.exitGate!.dx, engine.exitGate!.dy);

      final iron = Paint()..color = const Color(0xFF222222);
      final fire = Paint()..color = const Color(0xFFFF4400)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);

      canvas.drawArc(const Rect.fromLTWH(-30, -20, 60, 40), -math.pi, math.pi, true, iron);
      
      // Fire inside
      double fWobble = math.sin(engine.time * 20) * 2;
      canvas.drawArc(Rect.fromLTWH(-20, -10 + fWobble, 40, 20), -math.pi, math.pi, true, fire);
      
      // Grill bars
      final bar = Paint()..color = const Color(0xFF111111)..strokeWidth = 3;
      canvas.drawLine(const Offset(-10, -20), const Offset(-10, 0), bar);
      canvas.drawLine(const Offset(0, -20), const Offset(0, 0), bar);
      canvas.drawLine(const Offset(10, -20), const Offset(10, 0), bar);

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
  bool shouldRepaint(covariant GamePainterA15Steampunk oldDelegate) => true; 
}
