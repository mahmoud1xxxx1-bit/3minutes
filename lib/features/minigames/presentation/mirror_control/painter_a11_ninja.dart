import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'game_engine.dart';

class GamePainterA11Ninja extends CustomPainter {
  GamePainterA11Ninja({required this.engine, this.images});

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

    // 1. Draw Background (Tatami Mat)
    canvas.drawRect(const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize), Paint()..color = const Color(0xFFCDBA96));

    // Tatami grid lines
    final matBorder = Paint()..color = const Color(0xFF111111)..strokeWidth = 4.0;
    final matLine = Paint()..color = const Color(0xFFA09070)..strokeWidth = 1.0;
    
    for (double x = 0; x <= GameEngine.fieldSize; x+=100) {
      canvas.drawLine(Offset(x, 0), Offset(x, GameEngine.fieldSize), matBorder);
      for (double subX = x; subX < x + 100; subX+=40) {
        canvas.drawLine(Offset(subX, 0), Offset(subX, GameEngine.fieldSize), matLine);
      }
    }

    // 2. Draw Obstacles (Bamboo Shoots)
    for (int i = 0; i < engine.obstacles.length; i++) {
      final obs = engine.obstacles[i];
      
      final bambooColor = const Color(0xFF2E8B57);
      final bambooShade = const Color(0xFF006400);
      
      canvas.drawRect(obs, Paint()..color = bambooColor);
      
      // Bamboo joints
      final jointPaint = Paint()..color = bambooShade..strokeWidth = 3.0;
      for (double y = obs.top + 15; y < obs.bottom; y+=60) {
        canvas.drawLine(Offset(obs.left - 2, y), Offset(obs.right + 2, y), jointPaint);
      }
    }

    // 3. Draw Targets (Sacred Scrolls)
    for (int i = 0; i < engine.targets.length; i++) {
      if (i < engine.currentTargetIndex) continue;
      
      final target = engine.targets[i];
      final isNext = i == engine.currentTargetIndex;
      
      if (isNext) {
        final glowPaint = Paint()
          ..color = const Color(0xFFFFFF00).withValues(alpha: 0.5)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        canvas.drawCircle(target, GameEngine.targetRadius * 1.5, glowPaint);
      }

      canvas.save();
      canvas.translate(target.dx, target.dy);
      canvas.rotate(engine.time + i); // Rotating scroll
      
      final paperColor = isNext ? const Color(0xFFF5DEB3) : const Color(0xFFD2B48C);
      final woodColor = const Color(0xFF8B4513);
      
      // Open scroll
      canvas.drawRect(const Rect.fromLTWH(-8, -12, 16, 24), Paint()..color = paperColor);
      canvas.drawRect(const Rect.fromLTWH(-10, -14, 20, 4), Paint()..color = woodColor);
      canvas.drawRect(const Rect.fromLTWH(-10, 10, 20, 4), Paint()..color = woodColor);
      
      canvas.restore();

      final textSpan = TextSpan(
        text: '${i + 1}',
        style: TextStyle(
          color: isNext ? Colors.white : Colors.black54,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      textPainter.layout();
      textPainter.paint(canvas, target - Offset(textPainter.width / 2, -15));
    }

    // 4. Draw Exit Gate (Torii Gate)
    if (engine.exitGate != null) {
      canvas.save();
      canvas.translate(engine.exitGate!.dx, engine.exitGate!.dy);

      final toriiPaint = Paint()..color = const Color(0xFFB22222); // Firebrick red
      
      // Pillars
      canvas.drawRect(const Rect.fromLTWH(-25, -20, 8, 40), toriiPaint);
      canvas.drawRect(const Rect.fromLTWH(17, -20, 8, 40), toriiPaint);
      
      // Top bars
      canvas.drawRect(const Rect.fromLTWH(-35, -20, 70, 8), toriiPaint);
      canvas.drawRect(const Rect.fromLTWH(-30, -8, 60, 5), toriiPaint);

      canvas.restore();

      final textSpan = const TextSpan(
        text: 'EXIT',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
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
  bool shouldRepaint(covariant GamePainterA11Ninja oldDelegate) {
    return true; 
  }
}
