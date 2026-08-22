import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'game_engine.dart';

class GamePainterA13Retro extends CustomPainter {
  GamePainterA13Retro({required this.engine, this.images});

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

    // 1. Draw Background (Black with retro grid)
    canvas.drawRect(const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize), Paint()..color = Colors.black);

    final dotPaint = Paint()..color = const Color(0xFF333333);
    for (double x = 0; x < GameEngine.fieldSize; x+=60) {
      for (double y = 0; y < GameEngine.fieldSize; y+=60) {
        canvas.drawRect(Rect.fromLTWH(x, y, 2, 2), dotPaint);
      }
    }

    // 2. Draw Obstacles (Brick blocks like Mario)
    for (int i = 0; i < engine.obstacles.length; i++) {
      final obs = engine.obstacles[i];
      
      canvas.drawRect(obs, Paint()..color = const Color(0xFFD2691E)); // Brick brown
      
      // Draw pixelated brick lines
      final linePaint = Paint()..color = const Color(0xFF8B4513)..strokeWidth = 2.0;
      for (double y = obs.top + 10; y < obs.bottom; y+=40) {
        canvas.drawLine(Offset(obs.left, y), Offset(obs.right, y), linePaint);
      }
      for (double x = obs.left + 10; x < obs.right; x+=40) {
        // Staggered vertical lines
        bool offset = ((x - obs.left) / 10).toInt() % 2 == 0;
        for (double y = obs.top + (offset ? 0 : 5); y < obs.bottom; y+=60) {
          canvas.drawLine(Offset(x, y), Offset(x, y + 10), linePaint);
        }
      }
    }

    // 3. Draw Targets (8-Bit Coins)
    for (int i = 0; i < engine.targets.length; i++) {
      if (i < engine.currentTargetIndex) continue;
      
      final target = engine.targets[i];
      final isNext = i == engine.currentTargetIndex;
      
      canvas.save();
      canvas.translate(target.dx, target.dy);
      
      double spin = isNext ? math.cos(engine.time * 6) : 1.0;
      canvas.scale(spin.abs(), 1.0);
      
      final yellow = isNext ? const Color(0xFFFFFF00) : const Color(0xFF888800);
      final border = const Color(0xFF000000);
      
      // Pixel coin (approximate with rects)
      canvas.drawRect(const Rect.fromLTWH(-6, -10, 12, 20), Paint()..color = yellow);
      canvas.drawRect(const Rect.fromLTWH(-10, -6, 20, 12), Paint()..color = yellow);
      // Center hole
      canvas.drawRect(const Rect.fromLTWH(-2, -6, 4, 12), Paint()..color = border);
      
      canvas.restore();
    }

    // 4. Draw Exit Gate (Green Pipe)
    if (engine.exitGate != null) {
      canvas.save();
      canvas.translate(engine.exitGate!.dx, engine.exitGate!.dy);

      final pipeColor = const Color(0xFF00AA00);
      final pipeHighlight = const Color(0xFF55FF55);
      final pipeDark = const Color(0xFF005500);

      // Main pipe body
      canvas.drawRect(const Rect.fromLTWH(-20, -10, 40, 30), Paint()..color = pipeColor);
      canvas.drawRect(const Rect.fromLTWH(-10, -10, 5, 30), Paint()..color = pipeHighlight); // highlight
      
      // Pipe top rim
      canvas.drawRect(const Rect.fromLTWH(-25, -25, 50, 15), Paint()..color = pipeColor);
      canvas.drawRect(const Rect.fromLTWH(-25, -25, 50, 15), Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 2);
      canvas.drawRect(const Rect.fromLTWH(-20, -25, 5, 15), Paint()..color = pipeHighlight);
      
      // Hole
      canvas.drawRect(const Rect.fromLTWH(-15, -25, 30, 8), Paint()..color = Colors.black);

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
  bool shouldRepaint(covariant GamePainterA13Retro oldDelegate) => true; 
}
