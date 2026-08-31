import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'game_engine.dart';

class GamePainterA16Pirate extends CustomPainter {
  GamePainterA16Pirate({required this.engine, this.images});

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

    // 1. Draw Background (Wooden Ship Deck)
    canvas.drawRect(const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize), Paint()..color = const Color(0xFF6B4226));

    final plankLine = Paint()..color = const Color(0xFF4A2F1D)..strokeWidth = 2.0;
    final nailPaint = Paint()..color = const Color(0xFF333333);
    
    for (double x = 0; x < GameEngine.fieldSize; x+=30) {
      canvas.drawLine(Offset(x, 0), Offset(x, GameEngine.fieldSize), plankLine);
      // Horizontal breaks
      for (double y = 0; y < GameEngine.fieldSize; y+=40) {
        if ((x / 30).toInt() % 2 == 0) y+=60; // stagger
        canvas.drawLine(Offset(x, y), Offset(x + 30, y), plankLine);
        canvas.drawCircle(Offset(x + 5, y + 5), 1, nailPaint);
        canvas.drawCircle(Offset(x + 25, y + 5), 1, nailPaint);
      }
    }

    // 2. Draw Obstacles (Barrels / Cannons)
    for (int i = 0; i < engine.obstacles.length; i++) {
      final obs = engine.obstacles[i];
      
      final barrelWood = Paint()..color = const Color(0xFF8B5A2B);
      final barrelBand = Paint()..color = const Color(0xFF555555)..strokeWidth = 2;
      final barrelTop = Paint()..color = const Color(0xFF5C4033);
      
      canvas.drawRRect(RRect.fromRectAndRadius(obs, const Radius.circular(5)), barrelWood);
      canvas.drawRRect(RRect.fromRectAndRadius(obs.deflate(4), const Radius.circular(3)), barrelTop);
      
      canvas.drawRect(Rect.fromLTWH(obs.left, obs.top + 8, obs.width, 2), barrelBand);
      canvas.drawRect(Rect.fromLTWH(obs.left, obs.bottom - 10, obs.width, 2), barrelBand);
    }

    // 3. Draw Targets (Gold Dubloons)
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
      
      final goldColor = isNext ? const Color(0xFFFFD700) : const Color(0xFFB8860B);
      final goldEdge = isNext ? const Color(0xFFDAA520) : const Color(0xFF8B6508);
      
      canvas.drawCircle(Offset.zero, 12, Paint()..color = goldEdge);
      canvas.drawCircle(Offset.zero, 10, Paint()..color = goldColor);
      
      // Skull on the coin
      final skullColor = goldEdge;
      canvas.drawOval(const Rect.fromLTWH(-3, -4, 6, 6), Paint()..color = skullColor);
      canvas.drawRect(const Rect.fromLTWH(-2, 2, 4, 3), Paint()..color = skullColor); // teeth
      
      canvas.restore();
    }

    // 4. Draw Exit Gate (Treasure Chest)
    if (engine.exitGate != null) {
      canvas.save();
      canvas.translate(engine.exitGate!.dx, engine.exitGate!.dy);

      final chestWood = Paint()..color = const Color(0xFF8B4513);
      final chestGold = Paint()..color = const Color(0xFFFFD700);

      canvas.drawRect(const Rect.fromLTWH(-20, -10, 40, 20), chestWood); // Bottom half
      
      // Lid (open slightly)
      double open = (math.sin(engine.time * 5) + 1) * 3;
      canvas.drawArc(Rect.fromLTWH(-20, -20 - open, 40, 20), -math.pi, math.pi, true, chestWood);
      
      // Straps
      canvas.drawRect(const Rect.fromLTWH(-15, -10, 4, 20), chestGold);
      canvas.drawRect(const Rect.fromLTWH(11, -10, 4, 20), chestGold);
      canvas.drawCircle(Offset(0, 0), 4, chestGold); // Lock

      // Gold glow from inside
      final goldGlow = Paint()
        ..color = const Color(0xFFFFD700).withOpacity(0.8)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);
      canvas.drawRect(Rect.fromLTWH(-18, -10 - open/2, 36, open), goldGlow);

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
  bool shouldRepaint(covariant GamePainterA16Pirate oldDelegate) => true; 
}
