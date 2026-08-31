import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'game_engine.dart';

class GamePainterA86 extends CustomPainter {
  GamePainterA86({required this.engine, this.images});
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

    final rnd = math.Random(86);

    // ==========================================
    // 1. ARTISTIC BACKGROUND AND FLOOR
    // ==========================================
    canvas.drawRect(const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize), Paint()..color = const Color(0xFF1a0f0f));
    
    for (int i=0; i<30; i++) {
        double rX = rnd.nextDouble() * GameEngine.fieldSize;
        double rY = rnd.nextDouble() * GameEngine.fieldSize;
        double rS = rnd.nextDouble() * 40 + 20;
        canvas.drawCircle(Offset(rX, rY), rS, Paint()..color = const Color(0xFF330000)..maskFilter=const MaskFilter.blur(BlurStyle.normal, 3));
    }
    
    // Lava river
    final lavaPath = Path();
    lavaPath.moveTo(0, GameEngine.fieldSize * 0.3);
    lavaPath.quadraticBezierTo(GameEngine.fieldSize * 0.5, GameEngine.fieldSize * 0.6, GameEngine.fieldSize, GameEngine.fieldSize * 0.4);
    lavaPath.lineTo(GameEngine.fieldSize, GameEngine.fieldSize * 0.6);
    lavaPath.quadraticBezierTo(GameEngine.fieldSize * 0.5, GameEngine.fieldSize * 0.8, 0, GameEngine.fieldSize * 0.5);
    lavaPath.close();
    
    canvas.drawPath(lavaPath, Paint()..color = Colors.orangeAccent.withOpacity(0.8)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
    canvas.drawPath(lavaPath, Paint()..color = Colors.red..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));

    // Ash particles
    for (int i=0; i<100; i++) {
        double rX = rnd.nextDouble() * GameEngine.fieldSize;
        double rY = (rnd.nextDouble() * GameEngine.fieldSize + engine.time * 20) % GameEngine.fieldSize;
        canvas.drawCircle(Offset(rX, rY), rnd.nextDouble() * 2 + 1, Paint()..color = Colors.grey.withOpacity(0.5));
    }

    // ==========================================
    // 2. OBSTACLES
    // ==========================================
    for (int i = 0; i < engine.obstacles.length; i++) {
        final obs = engine.obstacles[i];
        canvas.drawRect(obs.shift(const Offset(0, 10)), Paint()..color=Colors.black.withOpacity(0.8)); // Shadow
        
        // Dragon scales obstacle
        canvas.drawRRect(RRect.fromRectAndRadius(obs, const Radius.circular(8)), Paint()..color=const Color(0xFF4A1010));
        
        final scalePaint = Paint()..color=const Color(0xFF6B1818)..style=PaintingStyle.stroke..strokeWidth=2;
        for (double dx = obs.left; dx < obs.right; dx+=60) {
            for (double dy = obs.top; dy < obs.bottom; dy+=60) {
                canvas.drawArc(Rect.fromLTWH(dx, dy, 15, 15), 0, math.pi, false, scalePaint);
            }
        }
    }

    // ==========================================
    // 3. TARGETS
    // ==========================================
    for (int i = 0; i < engine.targets.length; i++) {
        if (i < engine.currentTargetIndex) continue;
        bool isActive = (i == engine.currentTargetIndex);
        final target = engine.targets[i];
        
        if (isActive) {
            double p = 1.0 + math.sin(engine.time*8)*0.2;
            // Active glow - DO NOT MODIFY
            canvas.drawCircle(target, 35*p, Paint()..color=Colors.amber.withOpacity(0.6)..maskFilter=const MaskFilter.blur(BlurStyle.normal, 3));
            canvas.drawCircle(target, 20*p, Paint()..color=Colors.white.withOpacity(0.8)..maskFilter=const MaskFilter.blur(BlurStyle.normal, 5));
        }
        
        canvas.saveLayer(Rect.fromCenter(center: target, width: 80, height: 80), Paint()..color=Colors.white.withOpacity(isActive ? 1.0 : 0.3));
        
        // Molten gold egg
        final goldGradient = ui.Gradient.radial(
            target, 20, [const Color(0xFFFFD700), const Color(0xFFB8860B)]
        );
        canvas.drawOval(Rect.fromCenter(center: target, width: 20, height: 30), Paint()..shader = goldGradient);
        canvas.drawOval(Rect.fromCenter(center: target, width: 20, height: 30), Paint()..color = Colors.white24..style = PaintingStyle.stroke..strokeWidth = 2);
        
        canvas.restore();
    }

    // ==========================================
    // 4. EXIT GATE
    // ==========================================
    if (engine.exitGate != null) {
        canvas.drawCircle(engine.exitGate!, 45, Paint()..color=const Color(0xFFFF5500)..style=PaintingStyle.stroke..strokeWidth=10);
        canvas.drawCircle(engine.exitGate!, 50, Paint()..color=const Color(0xFFFF2200).withOpacity(0.5)..style=PaintingStyle.stroke..strokeWidth=15..maskFilter=const MaskFilter.blur(BlurStyle.normal, 3));
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

  @override bool shouldRepaint(covariant GamePainterA86 old) => true;
}
