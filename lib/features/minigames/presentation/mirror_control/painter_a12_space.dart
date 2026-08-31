import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'game_engine.dart';

class GamePainterA12Space extends CustomPainter {
  GamePainterA12Space({required this.engine, this.images});

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

    // 1. Draw Background (Deep Space)
    canvas.drawRect(const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize), Paint()..color = const Color(0xFF000011));

    // Stars
    final starPaint = Paint()..color = Colors.white;
    for (int i = 0; i < 50; i++) {
      double px = (i * 137.5) % GameEngine.fieldSize;
      double py = (i * 93.1 + engine.time * (i % 3 + 1) * 10) % GameEngine.fieldSize;
      double radius = (i % 3) == 0 ? 1.5 : 0.8;
      
      if (i % 10 == 0) { // Twinkling stars
        starPaint.color = Colors.white.withValues(alpha: (math.sin(engine.time * 5 + i) + 1) / 2);
      } else {
        starPaint.color = Colors.white.withValues(alpha: 0.6);
      }
      canvas.drawCircle(Offset(px, py), radius, starPaint);
    }

    // 2. Draw Obstacles (Asteroids)
    for (int i = 0; i < engine.obstacles.length; i++) {
      final obs = engine.obstacles[i];
      
      final asteroidColor = const Color(0xFF555555);
      final craterColor = const Color(0xFF333333);
      
      canvas.drawRRect(RRect.fromRectAndRadius(obs, const Radius.circular(8)), Paint()..color = asteroidColor);
      
      // Craters
      canvas.drawCircle(Offset(obs.left + 8, obs.top + 8), 4, Paint()..color = craterColor);
      canvas.drawCircle(Offset(obs.right - 10, obs.bottom - 10), 6, Paint()..color = craterColor);
      canvas.drawCircle(Offset(obs.left + 15, obs.bottom - 8), 3, Paint()..color = craterColor);
    }

    // 3. Draw Targets (Glowing Energy Cells)
    for (int i = 0; i < engine.targets.length; i++) {
      if (i < engine.currentTargetIndex) continue;
      
      final target = engine.targets[i];
      final isNext = i == engine.currentTargetIndex;
      
      if (isNext) {
        final glowPaint = Paint()
          ..color = const Color(0xFF00AAFF).withValues(alpha: 0.6)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        canvas.drawCircle(target, GameEngine.targetRadius * 1.5, glowPaint);
      }

      canvas.save();
      canvas.translate(target.dx, target.dy);
      canvas.rotate(engine.time * 2);
      
      final cellPaint = Paint()..color = isNext ? const Color(0xFF00FFFF) : const Color(0xFF005588);
      canvas.drawRect(const Rect.fromLTWH(-8, -12, 16, 24), cellPaint);
      canvas.drawRect(const Rect.fromLTWH(-10, -14, 20, 4), Paint()..color = const Color(0xFF888888));
      canvas.drawRect(const Rect.fromLTWH(-10, 10, 20, 4), Paint()..color = const Color(0xFF888888));
      
      // Energy lines
      canvas.drawLine(const Offset(-4, -6), const Offset(4, 6), Paint()..color = Colors.white..strokeWidth = 2);
      
      canvas.restore();

      final textSpan = TextSpan(
        text: '${i + 1}',
        style: TextStyle(
          color: isNext ? Colors.white : Colors.white54,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      );
      final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr, textAlign: TextAlign.center);
      textPainter.layout();
      textPainter.paint(canvas, target - Offset(textPainter.width / 2, -15));
    }

    // 4. Draw Exit Gate (Wormhole)
    if (engine.exitGate != null) {
      canvas.save();
      canvas.translate(engine.exitGate!.dx, engine.exitGate!.dy);
      canvas.rotate(engine.time * -3);

      final portalPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      
      for (int r = 10; r <= 45; r+=40) {
        portalPaint.color = Color.lerp(const Color(0xFF0000FF), const Color(0xFFFF00FF), r / 45)!;
        canvas.drawCircle(Offset.zero, r.toDouble(), portalPaint);
      }
      
      canvas.drawCircle(Offset.zero, 10, Paint()..color = Colors.black);

      canvas.restore();

      final textSpan = const TextSpan(text: 'WARP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12));
      final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr, textAlign: TextAlign.center);
      textPainter.layout();
      textPainter.paint(canvas, engine.exitGate! - Offset(textPainter.width / 2, textPainter.height / 2 + 35));
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
  bool shouldRepaint(covariant GamePainterA12Space oldDelegate) => true; 
}
