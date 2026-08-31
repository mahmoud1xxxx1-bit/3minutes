import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'game_engine.dart';

class GamePainterA20Alien extends CustomPainter {
  GamePainterA20Alien({required this.engine, this.images});

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

    // 1. Draw Background (Purple Alien Soil)
    canvas.drawRect(const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize), Paint()..color = const Color(0xFF2E0854));

    final soilPaint = Paint()..color = const Color(0xFF4B0082);
    for (int i = 0; i < 30; i++) {
      double px = (i * 87.5) % GameEngine.fieldSize;
      double py = (i * 123.1) % GameEngine.fieldSize;
      canvas.drawCircle(Offset(px, py), 15 + (i%5)*2, soilPaint);
    }

    // 2. Draw Obstacles (Glowing Cyan Crystals)
    for (int i = 0; i < engine.obstacles.length; i++) {
      final obs = engine.obstacles[i];
      
      final crystalBase = Paint()..color = const Color(0xFF008B8B);
      final crystalTip = Paint()..color = const Color(0xFF00FFFF);
      
      canvas.save();
      canvas.translate(obs.center.dx, obs.center.dy);
      
      // Hexagonal base crystal
      final path = Path()..moveTo(0, -obs.height/2)
                         ..lineTo(obs.width/2, -obs.height/4)
                         ..lineTo(obs.width/2, obs.height/4)
                         ..lineTo(0, obs.height/2)
                         ..lineTo(-obs.width/2, obs.height/4)
                         ..lineTo(-obs.width/2, -obs.height/4)..close();
      canvas.drawPath(path, crystalBase);
      
      // Highlights
      canvas.drawLine(Offset(0, -obs.height/2), Offset(0, obs.height/2), Paint()..color = const Color(0xFF20B2AA)..strokeWidth = 2);
      canvas.drawLine(Offset.zero, Offset(obs.width/2, -obs.height/4), Paint()..color = const Color(0xFF20B2AA)..strokeWidth = 2);
      
      // Glowing tip
      canvas.drawCircle(Offset(0, -obs.height/2), 3, crystalTip);
      
      canvas.restore();
    }

    // 3. Draw Targets (Energy Pods)
    for (int i = 0; i < engine.targets.length; i++) {
      if (i < engine.currentTargetIndex) continue;
      
      final target = engine.targets[i];
      final isNext = i == engine.currentTargetIndex;
      
      if (isNext) {
        final glowPaint = Paint()
          ..color = const Color(0xFF7CFC00).withValues(alpha: 0.5)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        canvas.drawCircle(target, GameEngine.targetRadius * 1.5, glowPaint);
      }

      canvas.save();
      canvas.translate(target.dx, target.dy);
      // Pulsing scale
      double pulse = isNext ? 1.0 + math.sin(engine.time * 5) * 0.1 : 1.0;
      canvas.scale(pulse, pulse);
      
      final podColor = isNext ? const Color(0xFF7CFC00) : const Color(0xFF228B22);
      final podEdge = const Color(0xFFADFF2F);
      
      canvas.drawOval(const Rect.fromLTWH(-8, -12, 16, 24), Paint()..color = podColor);
      canvas.drawOval(const Rect.fromLTWH(-8, -12, 16, 24), Paint()..color = podEdge..style = PaintingStyle.stroke..strokeWidth = 1.5);
      
      // Fluid bubbles inside
      canvas.drawCircle(const Offset(0, 5), 2, Paint()..color = podEdge);
      canvas.drawCircle(const Offset(-3, 0), 1.5, Paint()..color = podEdge);
      canvas.drawCircle(const Offset(2, -4), 1, Paint()..color = podEdge);

      canvas.restore();
    }

    // 4. Draw Exit Gate (Teleporter Pad)
    if (engine.exitGate != null) {
      canvas.save();
      canvas.translate(engine.exitGate!.dx, engine.exitGate!.dy);

      final padMetal = Paint()..color = const Color(0xFF888888);
      final beam = Paint()..color = const Color(0x8800FFFF);

      // Base
      canvas.drawOval(const Rect.fromLTWH(-30, -10, 60, 20), padMetal);
      canvas.drawOval(const Rect.fromLTWH(-25, -7, 50, 14), Paint()..color = const Color(0xFF005555));
      
      // Upward beam
      canvas.drawRect(const Rect.fromLTWH(-25, -40, 50, 35), beam);
      
      // Floating rings
      double rHeight = -10 - (engine.time * 20 % 30);
      canvas.drawOval(Rect.fromLTWH(-25, rHeight, 50, 10), Paint()..color = const Color(0xFF00FFFF)..style = PaintingStyle.stroke..strokeWidth = 2);

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
  bool shouldRepaint(covariant GamePainterA20Alien oldDelegate) => true; 
}
