import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'game_engine.dart';

class GamePainterA56 extends CustomPainter {
  GamePainterA56({required this.engine, this.images});
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

    final rnd = math.Random(56);

    // 1. FLOOR & BACKGROUND - Mushroom Forest
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize), 
      Paint()..shader = ui.Gradient.linear(
        const Offset(0, 0), 
        const Offset(GameEngine.fieldSize, GameEngine.fieldSize), 
        [const Color(0xFF1B2A1B), const Color(0xFF0F140F), const Color(0xFF050A05)],
        [0.0, 0.5, 1.0],
      )
    );

    // Glowing moss patches
    for(int i=0; i<40; i++) {
       double mx = rnd.nextDouble() * GameEngine.fieldSize;
       double my = rnd.nextDouble() * GameEngine.fieldSize;
       canvas.drawCircle(Offset(mx, my), 10 + rnd.nextDouble()*20, Paint()..color=const Color(0xFF55AA55).withOpacity(0.15)..maskFilter=const MaskFilter.blur(BlurStyle.normal, 3));
    }

    // Background giant mushrooms
    for(int i=0; i<8; i++) {
       double mx = rnd.nextDouble() * GameEngine.fieldSize;
       double my = rnd.nextDouble() * GameEngine.fieldSize;
       
       // stem
       canvas.drawRect(Rect.fromCenter(center: Offset(mx, my+20), width: 10, height: 40), Paint()..color=Colors.grey[400]!);
       // cap
       canvas.drawArc(Rect.fromCenter(center: Offset(mx, my), width: 60, height: 40), math.pi, math.pi, true, Paint()..color=Colors.purple[700]!);
       // spots
       canvas.drawCircle(Offset(mx-10, my-5), 5, Paint()..color=Colors.cyanAccent.withOpacity(0.7));
       canvas.drawCircle(Offset(mx+15, my-8), 4, Paint()..color=Colors.cyanAccent.withOpacity(0.7));
    }

    // 2. WEATHER / PARTICLES - Spores
    for(int i = 0; i < 30; i++) {
      double sx = (rnd.nextDouble() * GameEngine.fieldSize + math.cos(engine.time+i) * 20) % GameEngine.fieldSize;
      double sy = (rnd.nextDouble() * GameEngine.fieldSize - engine.time * 15) % GameEngine.fieldSize;
      if (sy < 0) sy += GameEngine.fieldSize;
      canvas.drawCircle(Offset(sx, sy), 3, Paint()..color=Colors.lightGreenAccent.withOpacity(0.6)..maskFilter=const MaskFilter.blur(BlurStyle.solid, 3));
    }

    // 3. OBSTACLES - Wooden logs / Dense roots
    for (int i = 0; i < engine.obstacles.length; i++) {
        final obs = engine.obstacles[i];
        
        canvas.drawRect(obs.shift(const Offset(0, 15)), Paint()..color=const Color(0x99000000)..maskFilter=const MaskFilter.blur(BlurStyle.normal, 5));
        
        canvas.drawRect(obs, Paint()..color=const Color(0xFF4A3525));
        canvas.drawRect(obs, Paint()..color=const Color(0xFF2E1C11)..style=PaintingStyle.stroke..strokeWidth=4);
        
        // Root bark lines
        for(double y=obs.top+8; y<obs.bottom-5; y+=60) {
           canvas.drawLine(Offset(obs.left, y), Offset(obs.right, y+rnd.nextDouble()*5), Paint()..color=const Color(0xFF2E1C11)..strokeWidth=2);
        }
    }

    // 4. TARGETS - Acorns
    for (int i = 0; i < engine.targets.length; i++) {
        if (i < engine.currentTargetIndex) continue; 
        
        bool isActive = (i == engine.currentTargetIndex);
        final target = engine.targets[i];

        if (isActive) {
            double p = 1.0 + math.sin(engine.time*8)*0.2;
            canvas.drawCircle(target, 35*p, Paint()..color=Colors.limeAccent.withOpacity(0.6)..maskFilter=const MaskFilter.blur(BlurStyle.normal, 3));
            canvas.drawCircle(target, 20*p, Paint()..color=Colors.white.withOpacity(0.8)..maskFilter=const MaskFilter.blur(BlurStyle.normal, 5));
        }

        canvas.saveLayer(Rect.fromCenter(center: target, width: 80, height: 80), Paint()..color=Colors.white.withOpacity(isActive ? 1.0 : 0.3));
        
        // Acorn body
        canvas.drawOval(Rect.fromCenter(center: target, width: 20, height: 26), Paint()..color=Colors.orange[300]!);
        // Acorn cap
        canvas.drawArc(Rect.fromCenter(center: target + const Offset(0, -6), width: 24, height: 16), math.pi, math.pi, true, Paint()..color=Colors.brown[700]!);
        
        canvas.restore();
    }

    // 5. EXIT GATE - Fairy Ring
    if (engine.exitGate != null) {
        canvas.drawCircle(engine.exitGate!, 45, Paint()..color=Colors.pinkAccent.withOpacity(0.3)..maskFilter=const MaskFilter.blur(BlurStyle.normal, 3));
        
        for(int i=0; i<8; i++) {
           double angle = i * math.pi / 4 + engine.time;
           double rx = engine.exitGate!.dx + math.cos(angle)*40;
           double ry = engine.exitGate!.dy + math.sin(angle)*40;
           canvas.drawCircle(Offset(rx, ry), 6, Paint()..color=Colors.pinkAccent);
        }
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

  @override bool shouldRepaint(covariant GamePainterA56 old) => true;
}
