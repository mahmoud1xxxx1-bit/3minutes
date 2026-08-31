import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'game_engine.dart';

class GamePainterA8Neon extends CustomPainter {
  GamePainterA8Neon({required this.engine, this.images});

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

    // 1. Draw Background (Cyberpunk Grid)
    canvas.drawRect(const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize), Paint()..color = const Color(0xFF050510));

    final gridPaint = Paint()
      ..color = const Color(0xFF00FFCC).withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    double scrollY = (engine.time * 50) % 40;
    for (double y = scrollY; y < GameEngine.fieldSize; y+=40) {
      canvas.drawLine(Offset(0, y), Offset(GameEngine.fieldSize, y), gridPaint);
    }
    for (double x = 0; x < GameEngine.fieldSize; x+=40) {
      canvas.drawLine(Offset(x, 0), Offset(x, GameEngine.fieldSize), gridPaint);
    }

    // 2. Draw Obstacles (Neon Skyscrapers)
    for (int i = 0; i < engine.obstacles.length; i++) {
      final obs = engine.obstacles[i];
      
      final buildingPaint = Paint()..color = const Color(0xFF111122);
      final neonBorder = Paint()
        ..color = (i % 2 == 0) ? const Color(0xFFFF00FF) : const Color(0xFF00FFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      
      canvas.drawRect(obs, buildingPaint);
      canvas.drawRect(obs, neonBorder);
      
      // Windows
      final windowPaint = Paint()..color = Colors.yellowAccent.withValues(alpha: 0.8);
      for (double wy = obs.top + 5; wy < obs.bottom - 5; wy+=60) {
        for (double wx = obs.left + 5; wx < obs.right - 5; wx+=60) {
          if ((wy + wx).toInt() % 3 != 0) { // Randomly lit
            canvas.drawRect(Rect.fromLTWH(wx, wy, 8, 8), windowPaint);
          }
        }
      }
    }

    // 3. Draw Targets (Energy Cores)
    for (int i = 0; i < engine.targets.length; i++) {
      if (i < engine.currentTargetIndex) continue;
      
      final target = engine.targets[i];
      final isNext = i == engine.currentTargetIndex;
      
      if (isNext) {
        final glowPaint = Paint()
          ..color = const Color(0xFF00FFFF).withValues(alpha: 0.6)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        canvas.drawCircle(target, GameEngine.targetRadius * 1.5, glowPaint);
      }

      canvas.save();
      canvas.translate(target.dx, target.dy);
      canvas.rotate(engine.time * -3);
      
      final coreColor = isNext ? const Color(0xFF00FFFF) : const Color(0xFF008888);
      final corePaint = Paint()
        ..color = coreColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      
      // Hexagon shape
      final hex = Path();
      for (int j = 0; j < 6; j++) {
        double a = (math.pi / 3) * j;
        double px = math.cos(a) * 12;
        double py = math.sin(a) * 12;
        if (j == 0) {
          hex.moveTo(px, py);
        } else {
          hex.lineTo(px, py);
        }
      }
      hex.close();
      canvas.drawPath(hex, corePaint);
      canvas.drawCircle(Offset.zero, 5, Paint()..color = coreColor);
      
      canvas.restore();

      final textSpan = TextSpan(
        text: '${i + 1}',
        style: TextStyle(
          color: isNext ? Colors.white : Colors.white54,
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

    // 4. Draw Exit Gate (Wormhole Portal)
    if (engine.exitGate != null) {
      canvas.save();
      canvas.translate(engine.exitGate!.dx, engine.exitGate!.dy);
      canvas.rotate(engine.time * 5); // Fast spin

      final portalPaint = Paint()
        ..color = const Color(0xFFFF0055).withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      
      for (int r = 10; r <= 40; r+=40) {
        canvas.drawCircle(Offset.zero, r.toDouble(), portalPaint);
      }
      canvas.drawCircle(Offset.zero, 40, Paint()..color = const Color(0xFFFF0055)..style = PaintingStyle.stroke..strokeWidth = 2.0);

      canvas.restore();

      final textSpan = const TextSpan(
        text: 'JUMP',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 2.0),
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
  bool shouldRepaint(covariant GamePainterA8Neon oldDelegate) {
    return true; 
  }
}
