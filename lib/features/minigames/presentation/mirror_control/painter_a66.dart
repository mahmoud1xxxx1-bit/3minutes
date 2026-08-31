import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'game_engine.dart';

class GamePainterA66 extends CustomPainter {
  GamePainterA66({required this.engine, this.images});
  final GameEngine engine;
  final Map<String, ui.Image>? images;

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / GameEngine.fieldSize;
    final scaleY = size.height / GameEngine.fieldSize;
    final scale = scaleX < scaleY ? scaleX : scaleY;
    
    canvas.translate((size.width - (GameEngine.fieldSize * scale)) / 2, (size.height - (GameEngine.fieldSize * scale)) / 2);
    canvas.scale(scale, scale);
    canvas.clipRect(const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize));

    final rnd = math.Random(66);

    // 1. FLOOR & BACKGROUND (Zen Garden)
    canvas.drawRect(const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize), Paint()..color = const Color(0xFFF3E5AB));
    
    // Raked sand patterns
    for (int i = 0; i < GameEngine.fieldSize; i+=60) {
        Path wave = Path();
        wave.moveTo(0, i.toDouble());
        for(double x = 0; x <= GameEngine.fieldSize; x+=50) {
            wave.quadraticBezierTo(x + 25, i + 10, x + 50, i.toDouble());
        }
        canvas.drawPath(wave, Paint()..color=Colors.black.withValues(alpha: 0.05)..style=PaintingStyle.stroke..strokeWidth=4);
    }
    
    // Cherry blossoms
    for (int i = 0; i < 40; i++) {
        double x = rnd.nextDouble() * GameEngine.fieldSize;
        double y = rnd.nextDouble() * GameEngine.fieldSize;
        double offset = math.sin(engine.time + x) * 10;
        canvas.drawCircle(Offset(x + offset, y + (engine.time * 20 % GameEngine.fieldSize)), 5, Paint()..color=Colors.pinkAccent.withValues(alpha: 0.6));
        canvas.drawCircle(Offset(x + offset + 2, y + 2 + (engine.time * 20 % GameEngine.fieldSize)), 3, Paint()..color=Colors.pink.withValues(alpha: 0.4));
    }

    // 3. OBSTACLES
    for (int i = 0; i < engine.obstacles.length; i++) {
        final obs = engine.obstacles[i];
        canvas.drawRect(obs.shift(const Offset(0, 10)), Paint()..color=Colors.black38..maskFilter=const MaskFilter.blur(BlurStyle.normal, 5));
        
        // Bamboo sticks
        canvas.drawRect(obs, Paint()..color=Colors.green[800]!);
        for (double x = obs.left + 5; x < obs.right; x+=60) {
            canvas.drawLine(Offset(x, obs.top), Offset(x, obs.bottom), Paint()..color=Colors.green[600]!..strokeWidth=8);
            for(double y = obs.top + 10; y < obs.bottom; y+=60) {
                 canvas.drawLine(Offset(x-4, y), Offset(x+4, y), Paint()..color=Colors.green[900]!..strokeWidth=2);
            }
        }
    }

    // 4. TARGETS
    for (int i = 0; i < engine.targets.length; i++) {
        if (i < engine.currentTargetIndex) continue; 
        bool isActive = (i == engine.currentTargetIndex);
        final target = engine.targets[i];

        if (isActive) {
            double p = 1.0 + math.sin(engine.time*8)*0.2;
            canvas.drawCircle(target, 35*p, Paint()..color=Colors.pinkAccent.withValues(alpha: 0.6)..maskFilter=const MaskFilter.blur(BlurStyle.normal, 3));
            canvas.drawCircle(target, 20*p, Paint()..color=Colors.white.withValues(alpha: 0.8)..maskFilter=const MaskFilter.blur(BlurStyle.normal, 5));
        }
        canvas.saveLayer(Rect.fromCenter(center: target, width: 80, height: 80), Paint()..color=Colors.white.withValues(alpha: isActive ? 1.0 : 0.3));
        
        // Lotus flower
        for(int j=0; j<8; j++){
            canvas.save();
            canvas.translate(target.dx, target.dy);
            canvas.rotate(j * math.pi/4);
            canvas.drawOval(Rect.fromCenter(center: const Offset(10, 0), width: 20, height: 10), Paint()..color=Colors.pinkAccent);
            canvas.restore();
        }
        canvas.drawCircle(target, 6, Paint()..color=Colors.yellow);
        
        canvas.restore();
    }

    // 5. EXIT GATE
    if (engine.exitGate != null) {
        canvas.drawRect(Rect.fromCenter(center: engine.exitGate!, width: 90, height: 10), Paint()..color=Colors.red[900]!);
        canvas.drawRect(Rect.fromCenter(center: engine.exitGate! - const Offset(30, 0), width: 10, height: 90), Paint()..color=Colors.red[900]!);
        canvas.drawRect(Rect.fromCenter(center: engine.exitGate! + const Offset(30, 0), width: 10, height: 90), Paint()..color=Colors.red[900]!);
        canvas.drawRect(Rect.fromCenter(center: engine.exitGate! - const Offset(0, 35), width: 110, height: 15), Paint()..color=Colors.red[900]!);
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

  @override bool shouldRepaint(covariant GamePainterA66 old) => true;
}
