import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'game_engine.dart';

class GamePainterA10Candyland extends CustomPainter {
  GamePainterA10Candyland({required this.engine, this.images});

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

    // 1. Draw Background (Pink Frosting)
    canvas.drawRect(const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize), Paint()..color = const Color(0xFFFFB6C1));

    // Sprinkles
    final sprinkleColors = [Colors.red, Colors.blue, Colors.green, Colors.yellow, Colors.orange];
    for (int i = 0; i < 60; i++) {
      final sPaint = Paint()..color = sprinkleColors[i % sprinkleColors.length]..strokeWidth = 3.0..strokeCap = StrokeCap.round;
      double px = (i * 77.7) % GameEngine.fieldSize;
      double py = (i * 99.9) % GameEngine.fieldSize;
      double angle = (i * 45.0) * math.pi / 180.0;
      
      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(angle);
      canvas.drawLine(const Offset(-4, 0), const Offset(4, 0), sPaint);
      canvas.restore();
    }

    // 2. Draw Obstacles (Chocolate Bars / Wafers)
    for (int i = 0; i < engine.obstacles.length; i++) {
      final obs = engine.obstacles[i];
      
      final chocPaint = Paint()..color = const Color(0xFF8B4513);
      final chocHighlight = Paint()..color = const Color(0xFFA0522D);
      
      canvas.drawRRect(RRect.fromRectAndRadius(obs, const Radius.circular(2)), chocPaint);
      
      // Wafer grid lines
      final gridPaint = Paint()..color = const Color(0xFF6B3E11)..strokeWidth = 1.0;
      for (double x = obs.left + 10; x < obs.right; x+=40) {
        canvas.drawLine(Offset(x, obs.top), Offset(x, obs.bottom), gridPaint);
      }
      for (double y = obs.top + 10; y < obs.bottom; y+=40) {
        canvas.drawLine(Offset(obs.left, y), Offset(obs.right, y), gridPaint);
      }
    }

    // 3. Draw Targets (Peppermints)
    for (int i = 0; i < engine.targets.length; i++) {
      if (i < engine.currentTargetIndex) continue;
      
      final target = engine.targets[i];
      final isNext = i == engine.currentTargetIndex;
      
      if (isNext) {
        final glowPaint = Paint()
          ..color = const Color(0xFFFFFFFF).withOpacity(0.5)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        canvas.drawCircle(target, GameEngine.targetRadius * 1.5, glowPaint);
      }

      canvas.save();
      canvas.translate(target.dx, target.dy);
      canvas.rotate(engine.time * 2);
      
      final whitePaint = Paint()..color = Colors.white;
      final redPaint = Paint()..color = isNext ? Colors.red : const Color(0xFF880000);
      
      canvas.drawCircle(Offset.zero, 12, whitePaint);
      
      // Mint stripes
      for (int j = 0; j < 4; j++) {
        canvas.rotate(math.pi / 2);
        final path = Path()..moveTo(0, 0)..lineTo(12, -4)..lineTo(12, 4)..close();
        canvas.drawPath(path, redPaint);
      }
      
      canvas.drawCircle(Offset.zero, 12, Paint()..color = Colors.red..style = PaintingStyle.stroke..strokeWidth = 1.5);
      
      canvas.restore();

      final textSpan = TextSpan(
        text: '${i + 1}',
        style: TextStyle(
          color: isNext ? Colors.black : Colors.black54,
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

    // 4. Draw Exit Gate (Gingerbread House)
    if (engine.exitGate != null) {
      canvas.save();
      canvas.translate(engine.exitGate!.dx, engine.exitGate!.dy);

      // House body
      canvas.drawRect(const Rect.fromLTWH(-20, -10, 40, 30), Paint()..color = const Color(0xFFCD853F));
      
      // Roof (Frosting)
      final roofPath = Path()..moveTo(-25, -10)..lineTo(0, -30)..lineTo(25, -10)..close();
      canvas.drawPath(roofPath, Paint()..color = Colors.white);
      
      // Door
      canvas.drawRect(const Rect.fromLTWH(-8, 5, 16, 15), Paint()..color = const Color(0xFF8B4513));

      canvas.restore();

      final textSpan = const TextSpan(
        text: 'HOUSE',
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
  bool shouldRepaint(covariant GamePainterA10Candyland oldDelegate) {
    return true; 
  }
}
