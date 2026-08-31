import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'game_engine.dart';

class GamePainterA28Casino extends CustomPainter {
  GamePainterA28Casino({required this.engine, this.images});

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

    // 1. Draw Background (Green Felt)
    canvas.drawRect(const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize), Paint()..color = const Color(0xFF006400));

    final feltPaint = Paint()..color = const Color(0xFF005000);
    for (int i = 0; i < 50; i++) {
      double px = (i * 73.1) % GameEngine.fieldSize;
      double py = (i * 92.5) % GameEngine.fieldSize;
      canvas.drawCircle(Offset(px, py), 15, feltPaint);
    }

    // 2. Draw Obstacles (Stacks of Playing Cards)
    for (int i = 0; i < engine.obstacles.length; i++) {
      final obs = engine.obstacles[i];
      
      canvas.save();
      canvas.translate(obs.center.dx, obs.center.dy);
      
      // Draw a few cards stacked
      for(int j=0; j<3; j++) {
        canvas.rotate(0.2); // slight messy stack
        final cardRect = Rect.fromCenter(center: Offset(j*2.0, -j*2.0), width: obs.width, height: obs.height);
        
        canvas.drawRRect(RRect.fromRectAndRadius(cardRect, const Radius.circular(2)), Paint()..color = Colors.white);
        canvas.drawRRect(RRect.fromRectAndRadius(cardRect, const Radius.circular(2)), Paint()..color = Colors.black..style = PaintingStyle.stroke);
        
        // Red back pattern if it's the top card
        if (j == 2) {
          canvas.drawRRect(RRect.fromRectAndRadius(cardRect.deflate(2), const Radius.circular(1)), Paint()..color = const Color(0xFFB22222)..style = PaintingStyle.stroke..strokeWidth = 2);
        }
      }
      
      canvas.restore();
    }

    // 3. Draw Targets (Gold Coins)
    for (int i = 0; i < engine.targets.length; i++) {
      if (i < engine.currentTargetIndex) continue;
      
      final target = engine.targets[i];
      final isNext = i == engine.currentTargetIndex;
      
      if (isNext) {
        final glowPaint = Paint()
          ..color = const Color(0xFFFFD700).withValues(alpha: 0.5)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        canvas.drawCircle(target, GameEngine.targetRadius * 1.5, glowPaint);
      }

      canvas.save();
      canvas.translate(target.dx, target.dy);
      // Flipping coin
      double flip = math.cos(engine.time * 5 + i);
      canvas.scale(1.0, flip.abs());
      
      final coinColor = isNext ? const Color(0xFFFFD700) : const Color(0xFFDAA520);
      canvas.drawCircle(Offset.zero, 10, Paint()..color = coinColor);
      canvas.drawCircle(Offset.zero, 8, Paint()..color = const Color(0xFFB8860B)..style = PaintingStyle.stroke..strokeWidth = 1);
      
      // "$" symbol
      final textSpan = const TextSpan(text: '\$', style: TextStyle(color: Color(0xFF8B6508), fontWeight: FontWeight.bold, fontSize: 12));
      final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr, textAlign: TextAlign.center);
      textPainter.layout();
      textPainter.paint(canvas, Offset(-textPainter.width/2, -textPainter.height/2));

      canvas.restore();
    }

    // 4. Draw Exit Gate (Roulette Wheel)
    if (engine.exitGate != null) {
      canvas.save();
      canvas.translate(engine.exitGate!.dx, engine.exitGate!.dy);

      final wood = Paint()..color = const Color(0xFF8B4513);
      canvas.drawCircle(Offset.zero, 30, wood);
      
      canvas.rotate(engine.time * -3); // Spinning wheel
      
      final red = Paint()..color = Colors.red;
      final black = Paint()..color = Colors.black;
      
      for(int r=0; r<12; r++) {
        canvas.drawArc(const Rect.fromLTWH(-25, -25, 50, 50), r * math.pi/6, math.pi/6, true, (r%2==0) ? red : black);
      }
      
      canvas.drawCircle(Offset.zero, 15, Paint()..color = const Color(0xFFDAA520)); // Gold center
      canvas.drawCircle(const Offset(18, 0), 3, Paint()..color = Colors.white); // The ball

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
  bool shouldRepaint(covariant GamePainterA28Casino oldDelegate) => true; 
}
