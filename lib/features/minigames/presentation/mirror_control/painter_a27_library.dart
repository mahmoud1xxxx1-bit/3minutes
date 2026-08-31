import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'game_engine.dart';

class GamePainterA27Library extends CustomPainter {
  GamePainterA27Library({required this.engine, this.images});

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

    // 1. Draw Background (Wooden Floor with Glowing Runes)
    canvas.drawRect(const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize), Paint()..color = const Color(0xFF3E2723));

    final floorLine = Paint()..color = const Color(0xFF271310)..strokeWidth = 2.0;
    for (double x = 0; x < GameEngine.fieldSize; x+=40) {
      canvas.drawLine(Offset(x, 0), Offset(x, GameEngine.fieldSize), floorLine);
    }
    
    // Glowing runes
    final runePaint = Paint()..color = const Color(0x3300FFFF)..strokeWidth = 2.0..style = PaintingStyle.stroke;
    for (int i = 0; i < 10; i++) {
      double px = (i * 123.0) % GameEngine.fieldSize;
      double py = (i * 97.0) % GameEngine.fieldSize;
      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(i.toDouble());
      // Draw random triangle/circle rune
      canvas.drawCircle(Offset.zero, 15, runePaint);
      canvas.drawPath(Path()..moveTo(0, -15)..lineTo(12, 10)..lineTo(-12, 10)..close(), runePaint);
      canvas.restore();
    }

    // 2. Draw Obstacles (Bookshelves)
    for (int i = 0; i < engine.obstacles.length; i++) {
      final obs = engine.obstacles[i];
      
      final woodColor = const Color(0xFF5D4037);
      canvas.drawRect(obs, Paint()..color = woodColor);
      
      // Shelf dividers
      final darkWood = Paint()..color = const Color(0xFF3E2723)..strokeWidth = 2;
      canvas.drawLine(Offset(obs.left, obs.top + 5), Offset(obs.right, obs.top + 5), darkWood);
      canvas.drawLine(Offset(obs.left, obs.bottom - 5), Offset(obs.right, obs.bottom - 5), darkWood);
      
      // Books on shelf
      final bookColors = [Colors.red, Colors.blue, Colors.green, Colors.purple, Colors.orange];
      for (double x = obs.left + 5; x < obs.right - 5; x+=40) {
        if ((x.toInt() * i) % 7 == 0) continue; // Gap
        final bColor = bookColors[(x.toInt() + i) % bookColors.length];
        canvas.drawRect(Rect.fromLTWH(x, obs.top + 5, 4, obs.height - 10), Paint()..color = bColor);
      }
    }

    // 3. Draw Targets (Glowing Orbs / Mana Crystals)
    for (int i = 0; i < engine.targets.length; i++) {
      if (i < engine.currentTargetIndex) continue;
      
      final target = engine.targets[i];
      final isNext = i == engine.currentTargetIndex;
      
      if (isNext) {
        final glowPaint = Paint()
          ..color = const Color(0xFF9932CC).withValues(alpha: 0.5)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        canvas.drawCircle(target, GameEngine.targetRadius * 1.5, glowPaint);
      }

      canvas.save();
      canvas.translate(target.dx, target.dy);
      // Bobbing
      canvas.translate(0, math.sin(engine.time * 4 + i) * 3);
      
      final orbColor = isNext ? const Color(0xFFDDA0DD) : const Color(0xFF800080);
      final highlight = Paint()..color = Colors.white.withValues(alpha: 0.5);
      
      canvas.drawCircle(Offset.zero, 8, Paint()..color = orbColor);
      canvas.drawCircle(const Offset(-2, -3), 2, highlight);
      
      // Small orbiting particle
      double ox = math.cos(engine.time * 5 + i) * 12;
      double oy = math.sin(engine.time * 5 + i) * 12;
      canvas.drawCircle(Offset(ox, oy), 2, Paint()..color = Colors.white);

      canvas.restore();
    }

    // 4. Draw Exit Gate (Magic Portal Mirror)
    if (engine.exitGate != null) {
      canvas.save();
      canvas.translate(engine.exitGate!.dx, engine.exitGate!.dy);

      final frame = Paint()..color = const Color(0xFFFFD700)..style = PaintingStyle.stroke..strokeWidth = 4;
      final glass = Paint()..color = const Color(0xFF4B0082); // Indigo
      
      canvas.drawOval(const Rect.fromLTWH(-20, -30, 40, 60), glass);
      canvas.drawOval(const Rect.fromLTWH(-20, -30, 40, 60), frame);
      
      // Swirling galaxy inside
      final swirl = Paint()..color = const Color(0xFF9400D3)..style = PaintingStyle.stroke..strokeWidth = 2;
      canvas.rotate(engine.time * 2);
      canvas.drawArc(const Rect.fromLTWH(-10, -15, 20, 30), 0, math.pi, false, swirl);
      canvas.drawArc(const Rect.fromLTWH(-10, -15, 20, 30), math.pi, math.pi, false, swirl);

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
  bool shouldRepaint(covariant GamePainterA27Library oldDelegate) => true; 
}
