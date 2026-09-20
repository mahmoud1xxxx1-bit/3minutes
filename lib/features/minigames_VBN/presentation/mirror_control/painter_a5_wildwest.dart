import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'game_engine.dart';

class GamePainterA5WildWest extends CustomPainter {
  GamePainterA5WildWest({required this.engine, this.images});
  final GameEngine engine;
  final Map<String, ui.Image>? images;

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / GameEngine.fieldSize;
    final scaleY = size.height / GameEngine.fieldSize;
    final scale = scaleX < scaleY ? scaleX : scaleY;
    
    canvas.translate((size.width - (GameEngine.fieldSize * scale)) / 2, (size.height - (GameEngine.fieldSize * scale)) / 2);
    canvas.scale(scale, scale);
    canvas.clipRect(const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize));

    // BACKGROUND
    final bgPaint = Paint()..shader = ui.Gradient.linear(const Offset(0, 0), const Offset(0, GameEngine.fieldSize), [const Color(0xFF1A0A00), const Color(0xFF2A1100)]);
    canvas.drawRect(const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize), bgPaint);
    
    // RADAR / GRID
    final radarLinePaint = Paint()..color = const Color(0xFFFF5500).withOpacity(0.04)..style=PaintingStyle.stroke..strokeWidth=2;
    canvas.save();
    canvas.translate(GameEngine.fieldSize/2, GameEngine.fieldSize/2);
    canvas.rotate(engine.time * 0.1); 
    for(int i=1; i<=6; i++) {
      canvas.drawCircle(Offset.zero, 150.0 * i, radarLinePaint);
    }
    final sweepPaint = Paint()..shader = ui.Gradient.sweep(Offset.zero, [const Color(0xFFFF5500).withOpacity(0.15), const Color(0xFFFF5500).withOpacity(0.0)], [0.0, 0.2]);
    canvas.drawArc(Rect.fromCircle(center: Offset.zero, radius: 1000), 0, math.pi/2, true, sweepPaint);
    canvas.restore();

    
    // Heat Haze & Embers
    final emberPaint = Paint()..color = const Color(0xFFFF5500).withOpacity(0.8);
    for (int i = 0; i < 35; i++) {
      double px = (i * 87.53 + math.sin(engine.time*3 + i)*15) % GameEngine.fieldSize;
      double speed = 20 + (i % 5) * 15;
      double py = GameEngine.fieldSize - ((engine.time * speed + i * 133.3) % GameEngine.fieldSize);
      canvas.drawCircle(Offset(px, py), 2.5, emberPaint);
    }


    // OBSTACLE PAINTS (Cached for Performance)
    final shadowPaint = Paint()..color = Colors.black.withOpacity(0.9)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    final blockSidePaint = Paint()..color = const Color(0xFF1A0500);
    final blockLaserPaint = Paint()..color = Colors.deepOrangeAccent.withOpacity(0.6)..strokeWidth = 2..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    final blockGlassPaint = Paint()..color = Colors.white.withOpacity(0.2);
    final neonBorderPaint = Paint()..color = const Color(0xFFFF5500).withOpacity(0.8)..style = PaintingStyle.stroke..strokeWidth = 2..maskFilter = const MaskFilter.blur(BlurStyle.solid, 3);
    
    final bracketPaint = Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2.5;
    double bL = 12.0;
    double pad = 2.0;

    // OBSTACLES (3D Blocks)
    for (int i = 0; i < engine.obstacles.length; i++) {
      final obs = engine.obstacles[i];
      
      // Shadow
      canvas.drawRRect(RRect.fromRectAndRadius(obs.shift(const Offset(0, 15)), const Radius.circular(8)), shadowPaint);
      
      // 3D Depth
      final depthRect = obs.shift(const Offset(0, 10));
      canvas.drawRRect(RRect.fromRectAndRadius(depthRect, const Radius.circular(8)), blockSidePaint);
      
      // Top Face
      final topPaint = Paint()..shader = ui.Gradient.linear(obs.topCenter, obs.bottomCenter, [const Color(0xFF552200), const Color(0xFF331100)]);
      canvas.drawRRect(RRect.fromRectAndRadius(obs, const Radius.circular(8)), topPaint);
      
      // Laser Scan
      canvas.save();
      canvas.clipRRect(RRect.fromRectAndRadius(obs, const Radius.circular(8)));
      double sweepY = obs.top + ((engine.time * 60) % obs.height);
      canvas.drawLine(Offset(obs.left, sweepY), Offset(obs.right, sweepY), blockLaserPaint);
      canvas.drawRect(Rect.fromLTWH(obs.left, obs.top, obs.width, 4), blockGlassPaint);
      canvas.restore();

      // Neon Border
      canvas.drawRRect(RRect.fromRectAndRadius(obs, const Radius.circular(8)), neonBorderPaint);
      
      // Targeting Brackets ⌜ ⌟ (Drawn with simple lines instead of Paths for speed)
      canvas.drawLine(Offset(obs.left-pad, obs.top+bL-pad), Offset(obs.left-pad, obs.top-pad), bracketPaint);
      canvas.drawLine(Offset(obs.left-pad, obs.top-pad), Offset(obs.left+bL-pad, obs.top-pad), bracketPaint);
      
      canvas.drawLine(Offset(obs.right-bL+pad, obs.top-pad), Offset(obs.right+pad, obs.top-pad), bracketPaint);
      canvas.drawLine(Offset(obs.right+pad, obs.top-pad), Offset(obs.right+pad, obs.top+bL-pad), bracketPaint);
      
      canvas.drawLine(Offset(obs.left-pad, obs.bottom-bL+pad), Offset(obs.left-pad, obs.bottom+pad), bracketPaint);
      canvas.drawLine(Offset(obs.left-pad, obs.bottom+pad), Offset(obs.left+bL-pad, obs.bottom+pad), bracketPaint);
      
      canvas.drawLine(Offset(obs.right-bL+pad, obs.bottom+pad), Offset(obs.right+pad, obs.bottom+pad), bracketPaint);
      canvas.drawLine(Offset(obs.right+pad, obs.bottom+pad), Offset(obs.right+pad, obs.bottom-bL+pad), bracketPaint);
    }

    // TARGET PAINTS
    final targetPulsePaint = Paint()..color = const Color(0xFFFF5500).withOpacity(0.4)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    final targetShadowPaint = Paint()..color = Colors.black.withOpacity(0.5)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    // TARGETS
    for (int i = 0; i < engine.targets.length; i++) {
      if (i < engine.currentTargetIndex) continue;
      final target = engine.targets[i];
      final isNext = i == engine.currentTargetIndex;
      final tr = GameEngine.targetRadius;
      double floatOffset = math.sin(engine.time * 4 + i) * 5;

      if (isNext) {
        double pulse = 1.0 + math.sin(engine.time * 10) * 0.15;
        canvas.drawCircle(target + Offset(0, floatOffset), tr * 3 * pulse, targetPulsePaint);
      }

      if (images != null && images!['target'] != null) {
        final img = images!['target']!;
        canvas.drawCircle(target + Offset(0, 10 - floatOffset), tr * 0.8, targetShadowPaint);
        canvas.drawImageRect(img, Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()), Rect.fromCenter(center: target + Offset(0, floatOffset), width: tr*2.5, height: tr*2.5), Paint());
      } else {
        canvas.drawCircle(target + Offset(0, floatOffset), tr, Paint()..color = isNext ? Colors.deepOrangeAccent : Colors.grey);
      }
    }

    // EXIT GATE (Magic Portal)
    if (engine.exitGate != null) {
      final center = engine.exitGate!;
      canvas.drawCircle(center + const Offset(0, 15), 35, Paint()..color = Colors.black.withOpacity(0.6)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
      
      canvas.save();
      canvas.translate(center.dx, center.dy);
      
      double pulse = 1.0 + math.sin(engine.time * 8) * 0.1;
      canvas.drawCircle(Offset.zero, 40 * pulse, Paint()..color = const Color(0xFFFF5500).withOpacity(0.5)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
      
      canvas.rotate(engine.time * 3);
      final pSweep = Paint()..shader = ui.Gradient.sweep(Offset.zero, [const Color(0xFFFF5500), Colors.white, const Color(0xFFFF5500)], [0.0, 0.5, 1.0]);
      canvas.drawCircle(Offset.zero, 30, pSweep);
      
      canvas.drawCircle(Offset.zero, 22, Paint()..color = Colors.black);
      
      canvas.rotate(-engine.time * 6);
      canvas.drawCircle(Offset.zero, 22, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2); // Removed tiny blur for perf
      
      final portalParticle = Paint()..color = Colors.white;
      for(int i=0; i<6; i++) {
         double angle = (i * math.pi / 3) + engine.time * 5;
         double radius = 22 + math.sin(engine.time * 10 + i) * 8;
         canvas.drawCircle(Offset(math.cos(angle)*radius, math.sin(angle)*radius), 2.5, portalParticle);
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
  @override bool shouldRepaint(covariant GamePainterA5WildWest old) => true;
}
