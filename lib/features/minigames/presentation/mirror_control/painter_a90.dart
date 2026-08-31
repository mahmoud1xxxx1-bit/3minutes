import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'game_engine.dart';

class GamePainterA90 extends CustomPainter {
  GamePainterA90({required this.engine, this.images});
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

    final rnd = math.Random(90);

    // ==========================================
    // 1. ARTISTIC BACKGROUND AND FLOOR
    // ==========================================
    // Apocalyptic ruined city floor
    canvas.drawRect(const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize), Paint()..color = const Color(0xFF404540));
    
    // Cracked asphalt
    final crackPaint = Paint()..color = const Color(0xFF2A2D2A)..style=PaintingStyle.stroke..strokeWidth=3;
    for (int i=0; i<20; i++) {
        double startX = rnd.nextDouble() * GameEngine.fieldSize;
        double startY = rnd.nextDouble() * GameEngine.fieldSize;
        
        final path = Path();
        path.moveTo(startX, startY);
        for(int j=0; j<5; j++) {
            startX += (rnd.nextDouble() - 0.5) * 40;
            startY += (rnd.nextDouble() - 0.5) * 40;
            path.lineTo(startX, startY);
        }
        canvas.drawPath(path, crackPaint);
    }
    
    // Overgrown toxic green patches
    for (int i=0; i<40; i++) {
        double rX = rnd.nextDouble() * GameEngine.fieldSize;
        double rY = rnd.nextDouble() * GameEngine.fieldSize;
        canvas.drawCircle(Offset(rX, rY), rnd.nextDouble() * 20 + 10, Paint()..color = const Color(0xFF556B2F).withValues(alpha: 0.6)..maskFilter=const MaskFilter.blur(BlurStyle.normal, 3));
    }

    // ==========================================
    // 2. OBSTACLES
    // ==========================================
    for (int i = 0; i < engine.obstacles.length; i++) {
        final obs = engine.obstacles[i];
        canvas.drawRect(obs.shift(const Offset(5, 15)), Paint()..color=Colors.black87); // Shadow
        
        // Rusted structures / cars
        canvas.drawRect(obs, Paint()..color=const Color(0xFF5A4D41));
        
        // Rust spots
        final rustPaint = Paint()..color=const Color(0xFF8B4513);
        for(int j=0; j<5; j++) {
            double rx = obs.left + rnd.nextDouble() * obs.width;
            double ry = obs.top + rnd.nextDouble() * obs.height;
            canvas.drawCircle(Offset(rx, ry), rnd.nextDouble() * 8, rustPaint);
        }
        
        // Shattered glass lines
        final glassPaint = Paint()..color=Colors.white24..style=PaintingStyle.stroke..strokeWidth=2;
        canvas.drawLine(obs.topLeft, obs.bottomRight, glassPaint);
        canvas.drawLine(Offset(obs.left, obs.bottom), Offset(obs.right, obs.top), glassPaint);
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
            canvas.drawCircle(target, 35*p, Paint()..color=Colors.amber.withValues(alpha: 0.6)..maskFilter=const MaskFilter.blur(BlurStyle.normal, 3));
            canvas.drawCircle(target, 20*p, Paint()..color=Colors.white.withValues(alpha: 0.8)..maskFilter=const MaskFilter.blur(BlurStyle.normal, 5));
        }
        
        canvas.saveLayer(Rect.fromCenter(center: target, width: 80, height: 80), Paint()..color=Colors.white.withValues(alpha: isActive ? 1.0 : 0.3));
        
        // Glowing survival cache or battery
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: target, width: 24, height: 32), const Radius.circular(4)), Paint()..color=Colors.grey.shade800);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: target, width: 20, height: 28), const Radius.circular(3)), Paint()..color=const Color(0xFF22FF44));
        canvas.drawLine(target + const Offset(-5, 0), target + const Offset(5, 0), Paint()..color=Colors.white..strokeWidth=3);
        
        canvas.restore();
    }

    // ==========================================
    // 4. EXIT GATE
    // ==========================================
    if (engine.exitGate != null) {
        canvas.drawCircle(engine.exitGate!, 45, Paint()..color=const Color(0xFFAAAA00)..style=PaintingStyle.stroke..strokeWidth=8);
        canvas.drawCircle(engine.exitGate!, 45, Paint()..color=const Color(0xFFDDDD00).withValues(alpha: 0.5)..style=PaintingStyle.stroke..strokeWidth=15..maskFilter=const MaskFilter.blur(BlurStyle.normal, 3));
        
        // Hazard stripes on the edge
        final dashPaint = Paint()..color=Colors.black..style=PaintingStyle.stroke..strokeWidth=8;
        for(double t=0; t<math.pi*2; t+=10.4) {
            double x1 = engine.exitGate!.dx + math.cos(t) * 45;
            double y1 = engine.exitGate!.dy + math.sin(t) * 45;
            double x2 = engine.exitGate!.dx + math.cos(t+0.2) * 45;
            double y2 = engine.exitGate!.dy + math.sin(t+0.2) * 45;
            canvas.drawLine(Offset(x1, y1), Offset(x2, y2), dashPaint);
        }
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

  @override bool shouldRepaint(covariant GamePainterA90 old) => true;
}
