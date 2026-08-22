import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'game_engine.dart';

class GamePainterA21Castle extends CustomPainter {
  GamePainterA21Castle({required this.engine, this.images});

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

    // 1. Draw Background (Cobblestone)
    canvas.drawRect(const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize), Paint()..color = const Color(0xFF555555));

    final stonePaint = Paint()..color = const Color(0xFF444444);
    for (double x = 0; x < GameEngine.fieldSize; x+=30) {
      for (double y = 0; y < GameEngine.fieldSize; y+=30) {
        double shift = ((y / 30).toInt() % 2 == 0) ? 15 : 0;
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x + shift + 2, y + 2, 26, 26), const Radius.circular(4)), stonePaint);
      }
    }

    // 2. Draw Obstacles (Castle Walls / Turrets)
    for (int i = 0; i < engine.obstacles.length; i++) {
      final obs = engine.obstacles[i];
      
      final wallColor = const Color(0xFF888888);
      final wallLine = Paint()..color = const Color(0xFF333333)..strokeWidth = 1.0;
      
      canvas.drawRect(obs, Paint()..color = wallColor);
      
      // Crenellations (battlements) at the top edge (assuming top is north)
      for (double x = obs.left; x < obs.right; x+=40) {
        canvas.drawRect(Rect.fromLTWH(x, obs.top, 5, 5), Paint()..color = wallColor);
        canvas.drawRect(Rect.fromLTWH(x, obs.top, 5, 5), wallLine..style = PaintingStyle.stroke);
      }
      
      // Brick pattern
      canvas.drawRect(obs, wallLine..style = PaintingStyle.stroke);
      for (double y = obs.top + 10; y < obs.bottom; y+=40) {
        canvas.drawLine(Offset(obs.left, y), Offset(obs.right, y), wallLine);
      }
    }

    // 3. Draw Targets (Goblets / Chalices)
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
      // Gentle bob
      canvas.translate(0, math.sin(engine.time * 3 + i) * 3);
      
      final gold = isNext ? const Color(0xFFFFD700) : const Color(0xFFB8860B);
      final ruby = const Color(0xFFDC143C);
      
      // Goblet bowl
      final bowl = Path()..moveTo(-8, -10)..lineTo(8, -10)..quadraticBezierTo(8, 2, 0, 4)..quadraticBezierTo(-8, 2, -8, -10)..close();
      canvas.drawPath(bowl, Paint()..color = gold);
      
      // Stem and base
      canvas.drawRect(const Rect.fromLTWH(-2, 4, 4, 6), Paint()..color = gold);
      canvas.drawOval(const Rect.fromLTWH(-6, 8, 12, 4), Paint()..color = gold);
      
      // Ruby jewel
      canvas.drawCircle(const Offset(0, -2), 2, Paint()..color = ruby);

      canvas.restore();
    }

    // 4. Draw Exit Gate (Drawbridge)
    if (engine.exitGate != null) {
      canvas.save();
      canvas.translate(engine.exitGate!.dx, engine.exitGate!.dy);

      final moatColor = const Color(0xFF1E90FF);
      final woodColor = const Color(0xFF8B4513);
      final chainColor = const Color(0xFF555555);

      // Moat
      canvas.drawRect(const Rect.fromLTWH(-30, -10, 60, 20), Paint()..color = moatColor);
      
      // Wooden bridge
      canvas.drawRect(const Rect.fromLTWH(-15, -25, 30, 35), Paint()..color = woodColor);
      // Planks
      for(double y = -20; y < 10; y+=40) {
        canvas.drawLine(Offset(-15, y), Offset(15, y), Paint()..color = Colors.black..strokeWidth = 1);
      }
      
      // Chains
      canvas.drawLine(const Offset(-15, -25), const Offset(-20, -5), Paint()..color = chainColor..strokeWidth = 2);
      canvas.drawLine(const Offset(15, -25), const Offset(20, -5), Paint()..color = chainColor..strokeWidth = 2);

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
  bool shouldRepaint(covariant GamePainterA21Castle oldDelegate) => true; 
}
