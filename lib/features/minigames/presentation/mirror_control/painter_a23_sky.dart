import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'game_engine.dart';

class GamePainterA23Sky extends CustomPainter {
  GamePainterA23Sky({required this.engine, this.images});

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

    // 1. Draw Background (Blue Sky with scrolling clouds)
    canvas.drawRect(const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize), Paint()..color = const Color(0xFF87CEEB)); // Sky Blue

    final bgCloudPaint = Paint()..color = Colors.white.withOpacity(0.4);
    for (int i = 0; i < 8; i++) {
      double px = (i * 120.0 + engine.time * 10) % (GameEngine.fieldSize + 100) - 50;
      double py = (i * 70.0) % GameEngine.fieldSize;
      
      canvas.drawCircle(Offset(px, py), 20, bgCloudPaint);
      canvas.drawCircle(Offset(px + 15, py - 10), 25, bgCloudPaint);
      canvas.drawCircle(Offset(px + 30, py), 20, bgCloudPaint);
    }

    // 2. Draw Obstacles (Floating Islands)
    for (int i = 0; i < engine.obstacles.length; i++) {
      final obs = engine.obstacles[i];
      
      final grass = Paint()..color = const Color(0xFF32CD32);
      final dirt = Paint()..color = const Color(0xFF8B4513);
      
      canvas.save();
      canvas.translate(obs.center.dx, obs.center.dy);
      
      // Floating animation
      canvas.translate(0, math.sin(engine.time * 2 + i) * 3);
      
      // Dirt cone pointing down
      final dirtPath = Path()..moveTo(-obs.width/2, 0)..lineTo(obs.width/2, 0)..lineTo(0, obs.height/2 + 10)..close();
      canvas.drawPath(dirtPath, dirt);
      
      // Grass top
      canvas.drawOval(Rect.fromLTWH(-obs.width/2, -obs.height/4, obs.width, obs.height/2), grass);
      
      canvas.restore();
    }

    // 3. Draw Targets (Sun Orbs)
    for (int i = 0; i < engine.targets.length; i++) {
      if (i < engine.currentTargetIndex) continue;
      
      final target = engine.targets[i];
      final isNext = i == engine.currentTargetIndex;
      
      if (isNext) {
        final glowPaint = Paint()
          ..color = const Color(0xFFFFD700).withOpacity(0.5)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        canvas.drawCircle(target, GameEngine.targetRadius * 1.5, glowPaint);
      }

      canvas.save();
      canvas.translate(target.dx, target.dy);
      canvas.rotate(engine.time * 2);
      
      final sunColor = isNext ? const Color(0xFFFFFF00) : const Color(0xFFDAA520);
      final rayColor = isNext ? const Color(0xFFFFA500) : const Color(0xFFCD853F);
      
      // Rays
      for (int r = 0; r < 8; r++) {
        canvas.rotate(math.pi / 4);
        final ray = Path()..moveTo(0, 8)..lineTo(3, 15)..lineTo(-3, 15)..close();
        canvas.drawPath(ray, Paint()..color = rayColor);
      }
      
      // Center
      canvas.drawCircle(Offset.zero, 8, Paint()..color = sunColor);

      canvas.restore();
    }

    // 4. Draw Exit Gate (Rainbow Bridge)
    if (engine.exitGate != null) {
      canvas.save();
      canvas.translate(engine.exitGate!.dx, engine.exitGate!.dy);

      final colors = [Colors.red, Colors.orange, Colors.yellow, Colors.green, Colors.blue, Colors.purple];
      
      for(int i=0; i<colors.length; i++) {
        final rPaint = Paint()..color = colors[i]..style = PaintingStyle.stroke..strokeWidth = 3.0;
        canvas.drawArc(Rect.fromLTWH(-30 + (i*3), -20 + (i*3), 60 - (i*6), 40 - (i*6)), -math.pi, math.pi, false, rPaint);
      }
      
      // Clouds at base
      final cPaint = Paint()..color = Colors.white;
      canvas.drawCircle(const Offset(-30, 0), 8, cPaint);
      canvas.drawCircle(const Offset(-25, 5), 8, cPaint);
      canvas.drawCircle(const Offset(30, 0), 8, cPaint);
      canvas.drawCircle(const Offset(25, 5), 8, cPaint);

      canvas.restore();
    }

    // ==========================================
    // 5. UNIFIED CHASER IDENTITY
    // ==========================================
    if (images != null && images!['enemy'] != null) {
      if (engine.chaserInWall) {
          canvas.drawCircle(engine.chaserPos, GameEngine.chaserRadius * 1.5, Paint()..color = Colors.black87);
          canvas.drawCircle(engine.chaserPos, GameEngine.chaserRadius * 0.8, Paint()..color = Colors.black);
          final eyeGlow = Paint()..color = Colors.red.withOpacity(0.6)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
          canvas.drawCircle(engine.chaserPos + const Offset(-6, -4), 8, eyeGlow);
          canvas.drawCircle(engine.chaserPos + const Offset(6, -4), 8, eyeGlow);
          canvas.drawCircle(engine.chaserPos + const Offset(-6, -4), 3, Paint()..color = Colors.white);
          canvas.drawCircle(engine.chaserPos + const Offset(6, -4), 3, Paint()..color = Colors.white);
      } else {
          canvas.drawCircle(engine.chaserPos + const Offset(0, 15), GameEngine.chaserRadius, Paint()..color=Colors.black.withOpacity(0.35));
          if(engine.chaserStunTimer <= GameEngine.recoveryDuration) {
             double pulse = 1.0 + math.sin(engine.time * 20) * 0.1;
             canvas.drawCircle(engine.chaserPos, GameEngine.chaserRadius * 2.5 * pulse, Paint()..color = Colors.redAccent.withOpacity(0.3));
          }
          canvas.save(); canvas.translate(engine.chaserPos.dx, engine.chaserPos.dy);
          if (engine.chaserVelocity.dx > 0) canvas.scale(-1, 1);
          canvas.translate(0, math.sin(engine.time * 6) * 4); 
          
          Paint chaserPaint = (engine.chaserStunTimer > GameEngine.recoveryDuration) 
              ? (Paint()..color=Colors.grey.withOpacity(0.5)) 
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
      canvas.drawCircle(engine.playerPos + const Offset(0, 15), GameEngine.playerRadius, Paint()..color=Colors.black.withOpacity(0.35));
      
      double vLen = engine.playerVelocity.distance;
      if (vLen > 0) {
        canvas.save(); canvas.translate(engine.playerPos.dx, engine.playerPos.dy);
        canvas.rotate(math.atan2(engine.playerVelocity.dy, engine.playerVelocity.dx));
        canvas.drawOval(Rect.fromCenter(center: const Offset(-20, 0), width: 40, height: 10), Paint()..color=Colors.white.withOpacity(0.5));
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
  bool shouldRepaint(covariant GamePainterA23Sky oldDelegate) => true; 
}
