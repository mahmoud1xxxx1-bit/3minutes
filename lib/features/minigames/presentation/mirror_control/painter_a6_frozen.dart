import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'game_engine.dart';

class GamePainterA6Frozen extends CustomPainter {
  GamePainterA6Frozen({required this.engine, this.images});

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

    // 1. Draw Background (Ice / Snow)
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFE0FFFF), Color(0xFFB0E0E6)],
      ).createShader(const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize));
    canvas.drawRect(const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize), bgPaint);

    // Snowflakes falling
    final snowPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;
    for (int i = 0; i < 50; i++) {
      double speed = 15.0 + (i % 5) * 5;
      double px = (i * 87.5 + math.sin(engine.time + i) * 20) % GameEngine.fieldSize;
      double py = (engine.time * speed + i * 113.2) % GameEngine.fieldSize;
      double radius = 1.0 + (i % 3);
      canvas.drawCircle(Offset(px, py), radius, snowPaint);
    }

    // 2. Draw Obstacles (Ice Blocks / Glaciers)
    for (int i = 0; i < engine.obstacles.length; i++) {
      final obs = engine.obstacles[i];
      
      final iceBase = Paint()
        ..color = const Color(0xFFADD8E6)
        ..style = PaintingStyle.fill;
      final iceTop = Paint()
        ..color = const Color(0xFFF0F8FF)
        ..style = PaintingStyle.fill;
      final iceReflection = Paint()
        ..color = Colors.white.withValues(alpha: 0.5)
        ..style = PaintingStyle.fill;
      
      canvas.drawRRect(RRect.fromRectAndRadius(obs, const Radius.circular(3)), iceBase);
      canvas.drawRRect(RRect.fromRectAndRadius(obs.deflate(2), const Radius.circular(2)), iceTop);
      
      // Reflection line on the ice block
      final path = Path();
      path.moveTo(obs.left + 5, obs.top + 2);
      path.lineTo(obs.right - 5, obs.bottom - 2);
      path.lineTo(obs.right - 8, obs.bottom - 2);
      path.lineTo(obs.left + 2, obs.top + 2);
      path.close();
      canvas.drawPath(path, iceReflection);
    }

    // 3. Draw Targets (Magic Ice Crystals)
    for (int i = 0; i < engine.targets.length; i++) {
      if (i < engine.currentTargetIndex) continue;
      
      final target = engine.targets[i];
      final isNext = i == engine.currentTargetIndex;
      
      if (isNext) {
        final glowPaint = Paint()
          ..color = const Color(0xFF00FFFF).withValues(alpha: 0.5)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        canvas.drawCircle(target, GameEngine.targetRadius * 1.5, glowPaint);
      }

      final crystalPaint = Paint()
        ..color = isNext ? const Color(0xFF00FFFF) : const Color(0xFF4682B4)
        ..style = PaintingStyle.fill;
      
      canvas.save();
      canvas.translate(target.dx, target.dy);
      // Floating bounce
      canvas.translate(0, math.sin(engine.time * 3 + i) * 3);
      canvas.rotate(engine.time * 1.5);
      
      final path = Path();
      path.moveTo(0, -12);
      path.lineTo(8, 0);
      path.lineTo(0, 12);
      path.lineTo(-8, 0);
      path.close();
      canvas.drawPath(path, crystalPaint);
      
      // Inner bright part
      final innerPaint = Paint()..color = Colors.white.withValues(alpha: 0.8);
      final innerPath = Path();
      innerPath.moveTo(0, -8);
      innerPath.lineTo(4, 0);
      innerPath.lineTo(0, 8);
      innerPath.lineTo(-4, 0);
      innerPath.close();
      canvas.drawPath(innerPath, innerPaint);
      
      canvas.restore();

      final textSpan = TextSpan(
        text: '${i + 1}',
        style: TextStyle(
          color: isNext ? Colors.black87 : Colors.black54,
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

    // 4. Draw Exit Gate (Igloo / Ice Castle Door)
    if (engine.exitGate != null) {
      final gateGlow = Paint()
        ..color = const Color(0xFF87CEFA).withValues(alpha: 0.5)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawCircle(engine.exitGate!, 45, gateGlow);

      final iglooPaint = Paint()..color = const Color(0xFFF0F8FF);
      final linePaint = Paint()..color = const Color(0xFFB0C4DE)..strokeWidth = 1.5;

      canvas.save();
      canvas.translate(engine.exitGate!.dx, engine.exitGate!.dy);

      // Dome
      canvas.drawArc(const Rect.fromLTWH(-30, -25, 60, 50), -math.pi, math.pi, true, iglooPaint);
      // Ice block lines
      canvas.drawArc(const Rect.fromLTWH(-30, -25, 60, 50), -math.pi, math.pi, false, linePaint);
      canvas.drawLine(const Offset(-15, -15), const Offset(-15, 0), linePaint);
      canvas.drawLine(const Offset(15, -15), const Offset(15, 0), linePaint);
      
      // Door opening
      canvas.drawArc(const Rect.fromLTWH(-12, -10, 24, 25), -math.pi, math.pi, true, Paint()..color = const Color(0xFF4682B4));

      canvas.restore();

      final textSpan = const TextSpan(
        text: 'SHELTER',
        style: TextStyle(color: Color(0xFF191970), fontWeight: FontWeight.w900, fontSize: 12),
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
  bool shouldRepaint(covariant GamePainterA6Frozen oldDelegate) {
    return true; 
  }
}
