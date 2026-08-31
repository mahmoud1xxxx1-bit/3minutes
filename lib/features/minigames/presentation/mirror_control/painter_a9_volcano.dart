import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'game_engine.dart';

class GamePainterA9Volcano extends CustomPainter {
  GamePainterA9Volcano({required this.engine, this.images});

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

    // 1. Draw Background (Lava)
    final bgPaint = Paint()..color = const Color(0xFFCC3300);
    canvas.drawRect(const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize), bgPaint);

    // Flowing magma waves
    final magmaPaint = Paint()
      ..color = const Color(0xFFFF5500).withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < 15; i++) {
      final path = Path();
      double startY = (i * 60.0) % GameEngine.fieldSize;
      path.moveTo(0, startY);
      for (double x = 0; x <= GameEngine.fieldSize; x+=30) {
        double y = startY + math.sin((x + engine.time * 20) * 0.05) * 20.0;
        path.lineTo(x, y);
      }
      path.lineTo(GameEngine.fieldSize, startY + 30);
      path.lineTo(0, startY + 30);
      path.close();
      canvas.drawPath(path, magmaPaint);
    }

    // Bubbles
    for(int i = 0; i < 20; i++) {
      double px = (i * 123.4) % GameEngine.fieldSize;
      double py = (i * 231.2 - engine.time * 30) % GameEngine.fieldSize;
      if (py < 0) py += GameEngine.fieldSize;
      double radius = (engine.time * 5 + i).remainder(10);
      canvas.drawCircle(Offset(px, py), radius, Paint()..color = const Color(0xFFFF8800)..style = PaintingStyle.stroke..strokeWidth = 1.0);
    }

    // 2. Draw Obstacles (Volcanic Rock)
    for (int i = 0; i < engine.obstacles.length; i++) {
      final obs = engine.obstacles[i];
      
      final rockBase = Paint()..color = const Color(0xFF221111);
      final rockTop = Paint()..color = const Color(0xFF332222);
      
      canvas.drawRRect(RRect.fromRectAndRadius(obs, const Radius.circular(3)), rockBase);
      canvas.drawRRect(RRect.fromRectAndRadius(obs.deflate(3), const Radius.circular(2)), rockTop);
      
      // Cracks with lava
      final crackPaint = Paint()..color = const Color(0xFFFF4400)..strokeWidth = 1.5;
      canvas.drawLine(Offset(obs.left + 5, obs.top + 5), Offset(obs.center.dx, obs.center.dy), crackPaint);
      if (i % 2 == 0) {
        canvas.drawLine(Offset(obs.center.dx, obs.center.dy), Offset(obs.right - 5, obs.bottom - 5), crackPaint);
      }
    }

    // 3. Draw Targets (Obsidian Gems)
    for (int i = 0; i < engine.targets.length; i++) {
      if (i < engine.currentTargetIndex) continue;
      
      final target = engine.targets[i];
      final isNext = i == engine.currentTargetIndex;
      
      if (isNext) {
        final glowPaint = Paint()
          ..color = const Color(0xFFAA00FF).withValues(alpha: 0.5)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        canvas.drawCircle(target, GameEngine.targetRadius * 1.5, glowPaint);
      }

      canvas.save();
      canvas.translate(target.dx, target.dy);
      // Floating bounce
      canvas.translate(0, math.sin(engine.time * 4 + i) * 4);
      
      final gemColor = isNext ? const Color(0xFF9900FF) : const Color(0xFF440088);
      
      final path = Path();
      path.moveTo(0, -10);
      path.lineTo(8, 0);
      path.lineTo(0, 10);
      path.lineTo(-8, 0);
      path.close();
      canvas.drawPath(path, Paint()..color = gemColor);
      canvas.drawPath(path, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 1.0);
      
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

    // 4. Draw Exit Gate (Minecart / Escape shaft)
    if (engine.exitGate != null) {
      canvas.save();
      canvas.translate(engine.exitGate!.dx, engine.exitGate!.dy);

      final trackPaint = Paint()..color = const Color(0xFF555555)..strokeWidth = 3.0;
      canvas.drawLine(const Offset(-20, -30), const Offset(20, 30), trackPaint);
      canvas.drawLine(const Offset(-10, -30), const Offset(30, 30), trackPaint);
      
      // Shaft opening
      canvas.drawCircle(Offset.zero, 25, Paint()..color = Colors.black);
      canvas.drawCircle(Offset.zero, 25, Paint()..color = const Color(0xFF663300)..style = PaintingStyle.stroke..strokeWidth = 4.0);

      canvas.restore();

      final textSpan = const TextSpan(
        text: 'SHAFT',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12),
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
  bool shouldRepaint(covariant GamePainterA9Volcano oldDelegate) {
    return true; 
  }
}
