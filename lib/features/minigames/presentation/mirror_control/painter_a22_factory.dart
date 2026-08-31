import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'game_engine.dart';

class GamePainterA22Factory extends CustomPainter {
  GamePainterA22Factory({required this.engine, this.images});

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

    // 1. Draw Background (Metal Grating & Toxic Slime)
    canvas.drawRect(const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize), Paint()..color = const Color(0xFF222222));

    final gratePaint = Paint()..color = const Color(0xFF444444)..strokeWidth = 1.0;
    for (double i = 0; i < GameEngine.fieldSize; i+=60) {
      canvas.drawLine(Offset(0, i), Offset(GameEngine.fieldSize, i), gratePaint);
      canvas.drawLine(Offset(i, 0), Offset(i, GameEngine.fieldSize), gratePaint);
    }
    
    // Slime puddles
    final slimePaint = Paint()..color = const Color(0xFF32CD32).withValues(alpha: 0.4)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    for (int i = 0; i < 5; i++) {
      double px = (i * 153.2) % GameEngine.fieldSize;
      double py = (i * 88.7) % GameEngine.fieldSize;
      double pulse = math.sin(engine.time * 2 + i) * 10;
      canvas.drawCircle(Offset(px, py), 40 + pulse, slimePaint);
    }

    // 2. Draw Obstacles (Toxic Barrels)
    for (int i = 0; i < engine.obstacles.length; i++) {
      final obs = engine.obstacles[i];
      
      final barrelColor = const Color(0xFF111111);
      final stripeColor = const Color(0xFFFFD700); // Yellow warning stripe
      
      canvas.drawRect(obs, Paint()..color = barrelColor);
      canvas.drawRect(Rect.fromLTWH(obs.left, obs.top + 10, obs.width, 10), Paint()..color = stripeColor);
      canvas.drawRect(Rect.fromLTWH(obs.left, obs.bottom - 20, obs.width, 10), Paint()..color = stripeColor);
      
      // Radioactive symbol on barrel (simple approximation)
      canvas.drawCircle(obs.center, 5, Paint()..color = Colors.black);
      canvas.drawCircle(obs.center, 2, Paint()..color = stripeColor);
    }

    // 3. Draw Targets (Uranium Rods)
    for (int i = 0; i < engine.targets.length; i++) {
      if (i < engine.currentTargetIndex) continue;
      
      final target = engine.targets[i];
      final isNext = i == engine.currentTargetIndex;
      
      if (isNext) {
        final glowPaint = Paint()
          ..color = const Color(0xFF39FF14).withValues(alpha: 0.6) // Neon green
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        canvas.drawCircle(target, GameEngine.targetRadius * 1.5, glowPaint);
      }

      canvas.save();
      canvas.translate(target.dx, target.dy);
      canvas.rotate(math.pi / 4); // Slanted rod
      
      final glassColor = const Color(0x66FFFFFF);
      final rodColor = isNext ? const Color(0xFF39FF14) : const Color(0xFF006400);
      final capColor = const Color(0xFF555555);
      
      // Outer glass tube
      canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-6, -12, 12, 24), const Radius.circular(3)), Paint()..color = glassColor);
      
      // Inner glowing rod
      canvas.drawRect(const Rect.fromLTWH(-2, -10, 4, 20), Paint()..color = rodColor);
      
      // Metal caps
      canvas.drawRect(const Rect.fromLTWH(-7, -14, 14, 4), Paint()..color = capColor);
      canvas.drawRect(const Rect.fromLTWH(-7, 10, 14, 4), Paint()..color = capColor);
      
      canvas.restore();
    }

    // 4. Draw Exit Gate (Decontamination Chamber)
    if (engine.exitGate != null) {
      canvas.save();
      canvas.translate(engine.exitGate!.dx, engine.exitGate!.dy);

      final metal = Paint()..color = const Color(0xFF777777);
      final glass = Paint()..color = const Color(0x88ADD8E6);

      canvas.drawRect(const Rect.fromLTWH(-25, -20, 50, 40), metal);
      // Chamber doors
      canvas.drawRect(const Rect.fromLTWH(-20, -15, 18, 30), glass);
      canvas.drawRect(const Rect.fromLTWH(2, -15, 18, 30), glass);
      
      // Spraying steam/chemicals from top
      final sprayPaint = Paint()..color = Colors.white.withValues(alpha: 0.5)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
      for(int i=0; i<3; i++) {
        double sy = -15 + (engine.time * 20 % 30);
        canvas.drawCircle(Offset(0, sy), 10, sprayPaint);
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
  bool shouldRepaint(covariant GamePainterA22Factory oldDelegate) => true; 
}
