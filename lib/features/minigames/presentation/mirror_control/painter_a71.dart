import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'game_engine.dart';

class GamePainterA71 extends CustomPainter {
  GamePainterA71({required this.engine, this.images});
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

    final rnd = math.Random(71);

    // 1. FLOOR & BACKGROUND (Overgrown Bioluminescent Jungle)
    canvas.drawRect(const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize), Paint()..color = const Color(0xFF0A1208));

    // Giant Glowing Mushrooms
    for (int i = 0; i < 15; i++) {
      double cx = rnd.nextDouble() * GameEngine.fieldSize;
      double cy = rnd.nextDouble() * GameEngine.fieldSize;
      
      canvas.drawCircle(Offset(cx, cy), 60, Paint()..color = const Color(0x3344FF44)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
      
      final mushroomPath = Path();
      mushroomPath.moveTo(cx - 30, cy);
      mushroomPath.quadraticBezierTo(cx, cy - 50, cx + 30, cy);
      mushroomPath.close();
      canvas.drawPath(mushroomPath, Paint()..color = const Color(0xFF77FF77));
      
      canvas.drawRect(Rect.fromCenter(center: Offset(cx, cy + 15), width: 10, height: 30), Paint()..color = Colors.white70);
    }

    // 2. WEATHER / PARTICLES (Fireflies)
    for (int i = 0; i < 100; i++) {
      double px = (rnd.nextDouble() * GameEngine.fieldSize + math.cos(engine.time * 2 + i) * 30) % GameEngine.fieldSize;
      double py = (rnd.nextDouble() * GameEngine.fieldSize + math.sin(engine.time * 2 + i) * 30) % GameEngine.fieldSize;
      double glow = 0.5 + 0.5 * math.sin(engine.time * 5 + i);
      
      canvas.drawCircle(Offset(px, py), 4, Paint()..color = Colors.greenAccent.withValues(alpha: glow)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
      canvas.drawCircle(Offset(px, py), 1.5, Paint()..color = Colors.white);
    }

    // 3. OBSTACLES
    for (int i = 0; i < engine.obstacles.length; i++) {
        final obs = engine.obstacles[i];
        canvas.drawRect(obs.shift(const Offset(0, 15)), Paint()..color=Colors.black54);
        
        // Stone blocks covered in moss
        canvas.drawRect(obs, Paint()..color=const Color(0xFF333333));
        canvas.drawRect(obs.deflate(2), Paint()..color=const Color(0xFF444444));
        
        // Moss top
        final mossPath = Path();
        mossPath.moveTo(obs.left, obs.top);
        mossPath.lineTo(obs.right, obs.top);
        mossPath.lineTo(obs.right, obs.top + 15);
        for(double x=obs.right; x>=obs.left; x-=10) {
           mossPath.quadraticBezierTo(x-5, obs.top+25, x-10, obs.top+10);
        }
        mossPath.close();
        canvas.drawPath(mossPath, Paint()..color=const Color(0xFF2E7D32));
    }

    // 4. TARGETS
    for (int i = 0; i < engine.targets.length; i++) {
        if (i < engine.currentTargetIndex) continue; 
        
        bool isActive = (i == engine.currentTargetIndex);
        final target = engine.targets[i];

        if (isActive) {
            double p = 1.0 + math.sin(engine.time*8)*0.2;
            canvas.drawCircle(target, 35*p, Paint()..color=Colors.purpleAccent.withValues(alpha: 0.6)..maskFilter=const MaskFilter.blur(BlurStyle.normal, 3));
            canvas.drawCircle(target, 20*p, Paint()..color=Colors.white.withValues(alpha: 0.8)..maskFilter=const MaskFilter.blur(BlurStyle.normal, 5));
        }

        canvas.saveLayer(Rect.fromCenter(center: target, width: 80, height: 80), Paint()..color=Colors.white.withValues(alpha: isActive ? 1.0 : 0.3));
        
        // Glowing Seed
        canvas.drawOval(Rect.fromCenter(center: target, width: 20, height: 30), Paint()..color=Colors.purpleAccent);
        canvas.drawOval(Rect.fromCenter(center: target, width: 10, height: 20), Paint()..color=Colors.white);
        
        canvas.restore();
    }

    // 5. EXIT GATE
    if (engine.exitGate != null) {
        canvas.drawCircle(engine.exitGate!, 45, Paint()..color=Colors.lightGreenAccent..style=PaintingStyle.stroke..strokeWidth=8);
        
        for (int i=0; i<8; i++) {
            double a = i * math.pi / 4 + engine.time;
            canvas.drawCircle(engine.exitGate! + Offset(math.cos(a)*45, math.sin(a)*45), 10, Paint()..color=Colors.greenAccent);
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

  @override bool shouldRepaint(covariant GamePainterA71 old) => true;
}
