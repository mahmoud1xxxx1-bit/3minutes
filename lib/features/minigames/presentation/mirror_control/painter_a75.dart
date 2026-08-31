import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'game_engine.dart';

class GamePainterA75 extends CustomPainter {
  GamePainterA75({required this.engine, this.images});
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

    final rnd = math.Random(75);

    // 1. FLOOR & BACKGROUND (Neon Cyberpunk Alley)
    canvas.drawRect(const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize), Paint()..color = const Color(0xFF0F0F1A));

    // Synthwave Grid
    for (double y = 0; y < GameEngine.fieldSize; y+=40) {
      double intensity = math.max(0, math.sin(engine.time*2 + y*0.05));
      canvas.drawLine(Offset(0, y), Offset(GameEngine.fieldSize, y), Paint()..color=const Color(0xFFE91E63).withValues(alpha: 0.2 + 0.3*intensity));
    }
    for (double x = 0; x < GameEngine.fieldSize; x+=40) {
      canvas.drawLine(Offset(x, 0), Offset(x, GameEngine.fieldSize), Paint()..color=const Color(0xFF00BCD4).withValues(alpha: 0.2));
    }

    // Billboards / Holograms in background
    for (int i = 0; i < 5; i++) {
      double cx = rnd.nextDouble() * GameEngine.fieldSize;
      double cy = rnd.nextDouble() * GameEngine.fieldSize;
      canvas.drawRect(Rect.fromCenter(center: Offset(cx, cy), width: 100, height: 50), Paint()..color=Colors.cyanAccent.withValues(alpha: 0.1)..maskFilter=const MaskFilter.blur(BlurStyle.normal, 3));
      canvas.drawRect(Rect.fromCenter(center: Offset(cx, cy), width: 100, height: 50), Paint()..color=Colors.cyanAccent.withValues(alpha: 0.3)..style=PaintingStyle.stroke..strokeWidth=2);
    }

    // 2. WEATHER / PARTICLES (Digital Rain / Matrix)
    for (int i = 0; i < 200; i++) {
      double px = rnd.nextDouble() * GameEngine.fieldSize;
      double py = (GameEngine.fieldSize - (rnd.nextDouble() * GameEngine.fieldSize - engine.time * 100)) % GameEngine.fieldSize;
      canvas.drawRect(Rect.fromLTWH(px, py, 2, 10), Paint()..color = Colors.greenAccent.withValues(alpha: 0.6));
    }

    // 3. OBSTACLES
    for (int i = 0; i < engine.obstacles.length; i++) {
        final obs = engine.obstacles[i];
        canvas.drawRect(obs.shift(const Offset(0, 15)), Paint()..color=Colors.black54);
        
        // Cybernetic Server Racks
        canvas.drawRect(obs, Paint()..color=const Color(0xFF1A1A24));
        canvas.drawRect(obs.deflate(2), Paint()..color=const Color(0xFF2B2B3C));
        
        // Neon Strips
        canvas.drawLine(Offset(obs.left, obs.top), Offset(obs.right, obs.top), Paint()..color=Colors.pinkAccent..strokeWidth=3..maskFilter=const MaskFilter.blur(BlurStyle.solid, 3));
        canvas.drawLine(Offset(obs.left, obs.bottom), Offset(obs.right, obs.bottom), Paint()..color=Colors.cyanAccent..strokeWidth=3..maskFilter=const MaskFilter.blur(BlurStyle.solid, 3));
        
        // Blinking lights
        for (double y = obs.top + 10; y < obs.bottom - 10; y+=60) {
            bool on = math.sin(engine.time * (rnd.nextDouble()*10) + y) > 0;
            canvas.drawCircle(Offset(obs.left + 10, y), 3, Paint()..color = on ? Colors.redAccent : Colors.red[900]!);
        }
    }

    // 4. TARGETS
    for (int i = 0; i < engine.targets.length; i++) {
        if (i < engine.currentTargetIndex) continue; 
        
        bool isActive = (i == engine.currentTargetIndex);
        final target = engine.targets[i];

        if (isActive) {
            double p = 1.0 + math.sin(engine.time*8)*0.2;
            canvas.drawCircle(target, 35*p, Paint()..color=Colors.greenAccent.withValues(alpha: 0.6)..maskFilter=const MaskFilter.blur(BlurStyle.normal, 3));
            canvas.drawCircle(target, 20*p, Paint()..color=Colors.white.withValues(alpha: 0.8)..maskFilter=const MaskFilter.blur(BlurStyle.normal, 5));
        }

        canvas.saveLayer(Rect.fromCenter(center: target, width: 80, height: 80), Paint()..color=Colors.white.withValues(alpha: isActive ? 1.0 : 0.3));
        
        // Data Chip
        canvas.drawRect(Rect.fromCenter(center: target, width: 24, height: 24), Paint()..color=Colors.black87);
        canvas.drawRect(Rect.fromCenter(center: target, width: 24, height: 24), Paint()..color=Colors.greenAccent..style=PaintingStyle.stroke..strokeWidth=2);
        canvas.drawRect(Rect.fromCenter(center: target, width: 12, height: 12), Paint()..color=Colors.greenAccent);
        
        canvas.restore();
    }

    // 5. EXIT GATE
    if (engine.exitGate != null) {
        canvas.drawCircle(engine.exitGate!, 45, Paint()..color=Colors.pinkAccent..style=PaintingStyle.stroke..strokeWidth=8..maskFilter=const MaskFilter.blur(BlurStyle.solid, 5));
        
        // Hexagon portal
        final hex = Path();
        for (int i=0; i<6; i++) {
            double a = i * math.pi/3 + engine.time;
            double hx = engine.exitGate!.dx + math.cos(a)*30;
            double hy = engine.exitGate!.dy + math.sin(a)*30;
            if(i==0) {
              hex.moveTo(hx, hy);
            } else {
              hex.lineTo(hx, hy);
            }
        }
        hex.close();
        canvas.drawPath(hex, Paint()..color=Colors.cyanAccent..style=PaintingStyle.stroke..strokeWidth=4);
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

  @override bool shouldRepaint(covariant GamePainterA75 old) => true;
}
