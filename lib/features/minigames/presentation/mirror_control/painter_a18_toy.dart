import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'game_engine.dart';

class GamePainterA18Toy extends CustomPainter {
  GamePainterA18Toy({required this.engine, this.images});

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

    // 1. Draw Background (Playmat with roads)
    canvas.drawRect(const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize), Paint()..color = const Color(0xFF98FB98)); // Pale green carpet

    final roadPaint = Paint()..color = const Color(0xFF555555);
    final linePaint = Paint()..color = Colors.white..strokeWidth = 2;
    
    // Draw some toy roads across the background
    canvas.drawRect(const Rect.fromLTWH(0, 100, GameEngine.fieldSize, 40), roadPaint);
    canvas.drawRect(const Rect.fromLTWH(150, 0, 40, GameEngine.fieldSize), roadPaint);
    
    for(double x = 10; x < GameEngine.fieldSize; x+=60) {
      canvas.drawLine(Offset(x, 120), Offset(x + 10, 120), linePaint);
    }
    for(double y = 10; y < GameEngine.fieldSize; y+=60) {
      canvas.drawLine(Offset(170, y), Offset(170, y + 10), linePaint);
    }

    // 2. Draw Obstacles (Wooden Alphabet Blocks)
    final blockColors = [Colors.red, Colors.blue, Colors.orange, Colors.purple];
    final letters = ['A', 'B', 'C', 'D'];
    
    for (int i = 0; i < engine.obstacles.length; i++) {
      final obs = engine.obstacles[i];
      
      final bColor = blockColors[i % blockColors.length];
      
      // Block body
      canvas.drawRRect(RRect.fromRectAndRadius(obs, const Radius.circular(2)), Paint()..color = const Color(0xFFDEB887)); // Burlywood
      // Colored inset
      canvas.drawRect(obs.deflate(4), Paint()..color = bColor);
      
      // Letter
      final textSpan = TextSpan(
        text: letters[i % letters.length],
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
      );
      final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr, textAlign: TextAlign.center);
      textPainter.layout();
      textPainter.paint(canvas, Offset(obs.center.dx - textPainter.width/2, obs.center.dy - textPainter.height/2));
    }

    // 3. Draw Targets (Jigsaw Puzzle Pieces)
    for (int i = 0; i < engine.targets.length; i++) {
      if (i < engine.currentTargetIndex) continue;
      
      final target = engine.targets[i];
      final isNext = i == engine.currentTargetIndex;
      
      if (isNext) {
        final glowPaint = Paint()
          ..color = Colors.yellow.withOpacity(0.5)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        canvas.drawCircle(target, GameEngine.targetRadius * 1.5, glowPaint);
      }

      canvas.save();
      canvas.translate(target.dx, target.dy);
      
      final pColor = isNext ? Colors.yellowAccent : const Color(0xFFDDDD00);
      final pPaint = Paint()..color = pColor;
      final border = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 1;
      
      // Basic puzzle piece shape
      final path = Path()..moveTo(-8, -8)..lineTo(8, -8)..lineTo(8, 8)..lineTo(-8, 8)..close();
      canvas.drawPath(path, pPaint);
      canvas.drawPath(path, border);
      // Nubs
      canvas.drawCircle(const Offset(0, -8), 3, pPaint); canvas.drawCircle(const Offset(0, -8), 3, border);
      canvas.drawCircle(const Offset(8, 0), 3, pPaint); canvas.drawCircle(const Offset(8, 0), 3, border);
      
      canvas.restore();
    }

    // 4. Draw Exit Gate (Toy Box)
    if (engine.exitGate != null) {
      canvas.save();
      canvas.translate(engine.exitGate!.dx, engine.exitGate!.dy);

      final boxPaint = Paint()..color = const Color(0xFF1E90FF); // Dodger blue
      final lidPaint = Paint()..color = const Color(0xFFFF4500); // Orange red

      canvas.drawRect(const Rect.fromLTWH(-20, -10, 40, 25), boxPaint);
      
      // Star decoration
      final starPath = Path()..moveTo(0, -5)..lineTo(3, 5)..lineTo(-5, 0)..lineTo(5, 0)..lineTo(-3, 5)..close();
      canvas.drawPath(starPath, Paint()..color = Colors.yellow);
      
      // Open lid
      canvas.drawRect(const Rect.fromLTWH(-22, -15, 44, 5), lidPaint);

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
  bool shouldRepaint(covariant GamePainterA18Toy oldDelegate) => true; 
}
