import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'game_engine.dart';

class GamePainterA17Egypt extends CustomPainter {
  GamePainterA17Egypt({required this.engine, this.images});

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

    // 1. Draw Background (Sand/Hieroglyphs)
    canvas.drawRect(const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize), Paint()..color = const Color(0xFFEEDC82)); // Sand

    final hieroglyphPaint = Paint()..color = const Color(0xFFD4C26A)..strokeWidth = 2.0..style = PaintingStyle.stroke;
    
    // Draw faint lines in sand
    for (double x = 0; x < GameEngine.fieldSize; x+=60) {
      for (double y = 0; y < GameEngine.fieldSize; y+=60) {
        // Random eye of horus roughly
        canvas.drawOval(Rect.fromLTWH(x + 10, y + 10, 20, 10), hieroglyphPaint);
        canvas.drawCircle(Offset(x + 20, y + 15), 3, hieroglyphPaint);
        canvas.drawLine(Offset(x + 20, y + 20), Offset(x + 15, y + 30), hieroglyphPaint);
      }
    }

    // 2. Draw Obstacles (Sandstone Pillars)
    for (int i = 0; i < engine.obstacles.length; i++) {
      final obs = engine.obstacles[i];
      
      final pillarColor = const Color(0xFFCDBA96);
      final shadowColor = const Color(0xFFA08A64);
      
      canvas.drawRect(obs, Paint()..color = pillarColor);
      canvas.drawRect(Rect.fromLTWH(obs.left, obs.top, obs.width / 2, obs.height), Paint()..color = shadowColor); // simple 3D effect
      
      // Top and bottom caps
      canvas.drawRect(Rect.fromLTWH(obs.left - 2, obs.top, obs.width + 4, 10), Paint()..color = pillarColor);
      canvas.drawRect(Rect.fromLTWH(obs.left - 2, obs.bottom - 10, obs.width + 4, 10), Paint()..color = pillarColor);
    }

    // 3. Draw Targets (Scarab Jewels)
    for (int i = 0; i < engine.targets.length; i++) {
      if (i < engine.currentTargetIndex) continue;
      
      final target = engine.targets[i];
      final isNext = i == engine.currentTargetIndex;
      
      if (isNext) {
        final glowPaint = Paint()
          ..color = const Color(0xFF00FFCC).withOpacity(0.5)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        canvas.drawCircle(target, GameEngine.targetRadius * 1.5, glowPaint);
      }

      canvas.save();
      canvas.translate(target.dx, target.dy);
      
      final gemColor = isNext ? const Color(0xFF00CED1) : const Color(0xFF00688B);
      final goldEdge = const Color(0xFFFFD700);
      
      // Scarab body
      canvas.drawOval(const Rect.fromLTWH(-8, -12, 16, 24), Paint()..color = goldEdge);
      canvas.drawOval(const Rect.fromLTWH(-6, -10, 12, 20), Paint()..color = gemColor);
      
      // Wings outline
      canvas.drawLine(const Offset(0, -6), const Offset(0, 10), Paint()..color = goldEdge..strokeWidth = 1.5);
      canvas.drawLine(const Offset(-6, -2), const Offset(6, -2), Paint()..color = goldEdge..strokeWidth = 1.5);
      
      canvas.restore();
    }

    // 4. Draw Exit Gate (Sarcophagus / Tomb Door)
    if (engine.exitGate != null) {
      canvas.save();
      canvas.translate(engine.exitGate!.dx, engine.exitGate!.dy);

      final gold = Paint()..color = const Color(0xFFFFD700);
      final blue = Paint()..color = const Color(0xFF0000CD);

      // Sarcophagus shape
      final sarc = Path()..moveTo(0, -25)..quadraticBezierTo(20, -20, 15, 25)..lineTo(-15, 25)..quadraticBezierTo(-20, -20, 0, -25)..close();
      canvas.drawPath(sarc, gold);
      
      // Stripes
      canvas.drawLine(const Offset(-15, -5), const Offset(15, -5), Paint()..color = const Color(0xFF0000CD)..strokeWidth = 3);
      canvas.drawLine(const Offset(-13, 5), const Offset(13, 5), Paint()..color = const Color(0xFF0000CD)..strokeWidth = 3);
      canvas.drawLine(const Offset(-14, 15), const Offset(14, 15), Paint()..color = const Color(0xFF0000CD)..strokeWidth = 3);
      
      // Face
      canvas.drawCircle(const Offset(0, -12), 4, blue);

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
  bool shouldRepaint(covariant GamePainterA17Egypt oldDelegate) => true; 
}
