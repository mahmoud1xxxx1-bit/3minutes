import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'game_engine.dart';

class GamePainterA30Void extends CustomPainter {
  GamePainterA30Void({required this.engine, this.images});

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

    // 1. Draw Background (The Void / Event Horizon edge)
    canvas.drawRect(const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize), Paint()..color = const Color(0xFF050010));

    // Distorted grid lines (Spacetime bending)
    final gridPaint = Paint()..color = const Color(0xFF8A2BE2).withValues(alpha: 0.3)..style = PaintingStyle.stroke..strokeWidth = 1.0;
    
    for (double i = 0; i < GameEngine.fieldSize; i+=40) {
      final vPath = Path();
      final hPath = Path();
      for (double j = 0; j <= GameEngine.fieldSize; j+=40) {
        // Bend towards center
        double dx = j - GameEngine.fieldSize/2;
        double dy = i - GameEngine.fieldSize/2;
        double dist = math.sqrt(dx*dx + dy*dy);
        double pull = 1000 / (dist + 50);
        
        double vx = i - (i - GameEngine.fieldSize/2) * pull * 0.01;
        double vy = j - (j - GameEngine.fieldSize/2) * pull * 0.01;
        if (j == 0) {
          vPath.moveTo(vx, vy);
        } else {
          vPath.lineTo(vx, vy);
        }
        
        double hx = j - (j - GameEngine.fieldSize/2) * pull * 0.01;
        double hy = i - (i - GameEngine.fieldSize/2) * pull * 0.01;
        if (j == 0) {
          hPath.moveTo(hx, hy);
        } else {
          hPath.lineTo(hx, hy);
        }
      }
      canvas.drawPath(vPath, gridPaint);
      canvas.drawPath(hPath, gridPaint);
    }

    // 2. Draw Obstacles (Spacetime Rifts / Dark Matter)
    for (int i = 0; i < engine.obstacles.length; i++) {
      final obs = engine.obstacles[i];
      
      final riftBorder = Paint()
        ..color = const Color(0xFF9400D3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);
      final riftCore = Paint()..color = Colors.black;
      
      canvas.drawRRect(RRect.fromRectAndRadius(obs, const Radius.circular(10)), riftCore);
      
      // Wobbling edge
      double p1 = math.sin(engine.time * 5 + i) * 3;
      double p2 = math.cos(engine.time * 4 + i) * 3;
      canvas.drawRRect(RRect.fromRectAndRadius(obs.inflate(p1), const Radius.circular(10)), riftBorder);
      canvas.drawRRect(RRect.fromRectAndRadius(obs.inflate(p2), const Radius.circular(10)), riftBorder..color = const Color(0xFF4B0082));
    }

    // 3. Draw Targets (Quasars / Starlight)
    for (int i = 0; i < engine.targets.length; i++) {
      if (i < engine.currentTargetIndex) continue;
      
      final target = engine.targets[i];
      final isNext = i == engine.currentTargetIndex;
      
      if (isNext) {
        final glowPaint = Paint()
          ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.5)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        canvas.drawCircle(target, GameEngine.targetRadius * 1.5, glowPaint);
      }

      canvas.save();
      canvas.translate(target.dx, target.dy);
      // Pulsing brightness
      double bright = (math.sin(engine.time * 10 + i) + 1) / 2;
      
      final coreColor = isNext ? Colors.white : const Color(0xFF00FFFF);
      final rayColor = isNext ? Color.lerp(Colors.cyan, Colors.white, bright)! : const Color(0xFF000088);
      
      // 4-point star
      final star = Path()..moveTo(0, -12)..quadraticBezierTo(2, -2, 12, 0)..quadraticBezierTo(2, 2, 0, 12)..quadraticBezierTo(-2, 2, -12, 0)..quadraticBezierTo(-2, -2, 0, -12)..close();
      canvas.drawPath(star, Paint()..color = rayColor);
      canvas.drawCircle(Offset.zero, 3, Paint()..color = coreColor);
      
      canvas.restore();
    }

    // 4. Draw Exit Gate (Black Hole)
    if (engine.exitGate != null) {
      canvas.save();
      canvas.translate(engine.exitGate!.dx, engine.exitGate!.dy);

      final accretion = Paint()
        ..color = const Color(0xFFFF4500).withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      
      canvas.rotate(engine.time * 5); // Spinning fast
      
      // Accretion disk (elliptical)
      canvas.drawOval(const Rect.fromLTWH(-40, -15, 80, 30), accretion);
      canvas.drawOval(const Rect.fromLTWH(-40, -15, 80, 30), accretion..color = const Color(0xFFFFD700));
      
      // Event horizon (perfectly black circle)
      canvas.drawCircle(Offset.zero, 18, Paint()..color = Colors.black);
      // Glowing edge
      canvas.drawCircle(Offset.zero, 18, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 1.0..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0));

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
  bool shouldRepaint(covariant GamePainterA30Void oldDelegate) => true; 
}
