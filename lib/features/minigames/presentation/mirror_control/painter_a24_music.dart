import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'game_engine.dart';

class GamePainterA24Music extends CustomPainter {
  GamePainterA24Music({required this.engine, this.images});

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

    // 1. Draw Background (Dance Floor)
    canvas.drawRect(const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize), Paint()..color = const Color(0xFF110022));

    final floorPaint = Paint()..style = PaintingStyle.fill;
    int beat = (engine.time * 2).toInt();
    
    for (double x = 0; x < GameEngine.fieldSize; x+=30) {
      for (double y = 0; y < GameEngine.fieldSize; y+=30) {
        if ((x + y + beat * 30).toInt() % 90 == 0) {
          floorPaint.color = const Color(0xFF8800FF).withValues(alpha: 0.3);
        } else if ((x - y + beat * 30).toInt() % 60 == 0) {
          floorPaint.color = const Color(0xFF00FFFF).withValues(alpha: 0.2);
        } else {
          floorPaint.color = const Color(0xFF221133);
        }
        canvas.drawRect(Rect.fromLTWH(x + 1, y + 1, 28, 28), floorPaint);
      }
    }

    // 2. Draw Obstacles (Speakers and Amps)
    for (int i = 0; i < engine.obstacles.length; i++) {
      final obs = engine.obstacles[i];
      
      final ampColor = const Color(0xFF222222);
      final meshColor = const Color(0xFF444444);
      
      canvas.drawRRect(RRect.fromRectAndRadius(obs, const Radius.circular(3)), Paint()..color = ampColor);
      canvas.drawRect(obs.deflate(3), Paint()..color = meshColor);
      
      // Speaker cones
      double throb = (math.sin(engine.time * 15 + i) + 1) * 2;
      canvas.drawCircle(Offset(obs.center.dx, obs.top + 10), 5 + throb, Paint()..color = Colors.black);
      canvas.drawCircle(Offset(obs.center.dx, obs.bottom - 10), 6 + throb, Paint()..color = Colors.black);
    }

    // 3. Draw Targets (Musical Notes)
    for (int i = 0; i < engine.targets.length; i++) {
      if (i < engine.currentTargetIndex) continue;
      
      final target = engine.targets[i];
      final isNext = i == engine.currentTargetIndex;
      
      if (isNext) {
        final glowPaint = Paint()
          ..color = const Color(0xFFFF00FF).withValues(alpha: 0.5)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        canvas.drawCircle(target, GameEngine.targetRadius * 1.5, glowPaint);
      }

      canvas.save();
      canvas.translate(target.dx, target.dy);
      // Floating animation
      canvas.translate(0, math.sin(engine.time * 4 + i) * 4);
      
      final noteColor = isNext ? const Color(0xFF00FFFF) : const Color(0xFF008888);
      final notePaint = Paint()..color = noteColor;
      
      // Draw an eighth note
      canvas.drawOval(const Rect.fromLTWH(-6, 2, 8, 6), notePaint);
      canvas.drawLine(const Offset(1, 4), const Offset(1, -8), notePaint..strokeWidth = 2);
      canvas.drawLine(const Offset(1, -8), const Offset(8, -4), notePaint..strokeWidth = 2);

      canvas.restore();
    }

    // 4. Draw Exit Gate (Disco Ball)
    if (engine.exitGate != null) {
      canvas.save();
      canvas.translate(engine.exitGate!.dx, engine.exitGate!.dy);

      final ballPaint = Paint()..color = const Color(0xFFDDDDDD);
      
      canvas.drawCircle(Offset.zero, 25, ballPaint);
      
      // Disco mirrors
      final mirrorPaint = Paint()..color = Colors.white.withValues(alpha: 0.8);
      for (double x = -20; x <= 20; x+=40) {
        for (double y = -20; y <= 20; y+=40) {
          if (x*x + y*y < 500) {
            if (math.Random((x*y).toInt() + engine.time.toInt()).nextDouble() > 0.5) {
              canvas.drawRect(Rect.fromLTWH(x, y, 4, 4), mirrorPaint);
            }
          }
        }
      }

      // Light beams
      final beamPaint = Paint()..color = Colors.white.withValues(alpha: 0.2)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
      canvas.save();
      canvas.rotate(engine.time);
      canvas.drawLine(const Offset(-40, 0), const Offset(40, 0), beamPaint..strokeWidth = 6);
      canvas.drawLine(const Offset(0, -40), const Offset(0, 40), beamPaint..strokeWidth = 6);
      canvas.restore();

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
  bool shouldRepaint(covariant GamePainterA24Music oldDelegate) => true; 
}
