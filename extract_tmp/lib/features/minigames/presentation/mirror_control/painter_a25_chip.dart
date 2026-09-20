import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'game_engine.dart';

class GamePainterA25Chip extends CustomPainter {
  GamePainterA25Chip({required this.engine, this.images});

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

    // 1. Draw Background (PCB Green)
    canvas.drawRect(const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize), Paint()..color = const Color(0xFF004400));

    // Circuit traces
    final tracePaint = Paint()..color = const Color(0xFF00AA00)..style = PaintingStyle.stroke..strokeWidth = 2.0;
    final padPaint = Paint()..color = const Color(0xFF00AA00);
    
    for (double x = 20; x < GameEngine.fieldSize; x+=40) {
      for (double y = 20; y < GameEngine.fieldSize; y+=50) {
        // Draw a little trace path
        final trace = Path()..moveTo(x, y)..lineTo(x + 10, y)..lineTo(x + 15, y + 5)..lineTo(x + 15, y + 15);
        canvas.drawPath(trace, tracePaint);
        canvas.drawCircle(Offset(x, y), 3, padPaint);
        canvas.drawCircle(Offset(x + 15, y + 15), 3, padPaint);
      }
    }

    // 2. Draw Obstacles (Microchips/Capacitors)
    for (int i = 0; i < engine.obstacles.length; i++) {
      final obs = engine.obstacles[i];
      
      final chipColor = const Color(0xFF222222);
      final pinColor = const Color(0xFFCCCCCC);
      
      // Pins
      for(double x = obs.left + 5; x < obs.right; x+=40) {
        canvas.drawRect(Rect.fromLTWH(x - 2, obs.top - 4, 4, 6), Paint()..color = pinColor);
        canvas.drawRect(Rect.fromLTWH(x - 2, obs.bottom - 2, 4, 6), Paint()..color = pinColor);
      }
      
      // Chip body
      canvas.drawRect(obs, Paint()..color = chipColor);
      canvas.drawCircle(Offset(obs.left + 6, obs.top + 6), 2, Paint()..color = const Color(0xFF111111)); // Pin 1 indicator
      
      // Text
      final textSpan = const TextSpan(text: 'CPU', style: TextStyle(color: Colors.white24, fontWeight: FontWeight.bold, fontSize: 10));
      final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr, textAlign: TextAlign.center);
      textPainter.layout();
      textPainter.paint(canvas, Offset(obs.center.dx - textPainter.width/2, obs.center.dy - textPainter.height/2));
    }

    // 3. Draw Targets (Data Packets)
    for (int i = 0; i < engine.targets.length; i++) {
      if (i < engine.currentTargetIndex) continue;
      
      final target = engine.targets[i];
      final isNext = i == engine.currentTargetIndex;
      
      if (isNext) {
        final glowPaint = Paint()
          ..color = const Color(0xFF00FFFF).withOpacity(0.5)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        canvas.drawCircle(target, GameEngine.targetRadius * 1.5, glowPaint);
      }

      canvas.save();
      canvas.translate(target.dx, target.dy);
      // Pulsing data
      double dataScale = 1.0 + math.sin(engine.time * 8 + i) * 0.2;
      canvas.scale(dataScale, dataScale);
      
      final dataColor = isNext ? const Color(0xFF00FFFF) : const Color(0xFF008888);
      
      canvas.drawRect(const Rect.fromLTWH(-6, -6, 12, 12), Paint()..color = dataColor);
      canvas.drawRect(const Rect.fromLTWH(-8, -2, 16, 4), Paint()..color = Colors.white);
      canvas.drawRect(const Rect.fromLTWH(-2, -8, 4, 16), Paint()..color = Colors.white);

      canvas.restore();
    }

    // 4. Draw Exit Gate (USB Port)
    if (engine.exitGate != null) {
      canvas.save();
      canvas.translate(engine.exitGate!.dx, engine.exitGate!.dy);

      final metal = Paint()..color = const Color(0xFFCCCCCC);
      final plastic = Paint()..color = Colors.black;
      final contact = Paint()..color = const Color(0xFFFFD700);

      // Port outer metal
      canvas.drawRect(const Rect.fromLTWH(-25, -15, 50, 30), metal);
      // Port inner void
      canvas.drawRect(const Rect.fromLTWH(-22, -12, 44, 24), plastic);
      // White plastic tongue
      canvas.drawRect(const Rect.fromLTWH(-20, 0, 40, 10), Paint()..color = Colors.white);
      
      // Gold contacts
      for(int i = -15; i <= 15; i+=40) {
        canvas.drawRect(Rect.fromLTWH(i.toDouble() - 2, 0, 4, 8), contact);
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

  @override
  bool shouldRepaint(covariant GamePainterA25Chip oldDelegate) => true; 
}
