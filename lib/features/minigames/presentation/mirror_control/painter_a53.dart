import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'game_engine.dart';

class GamePainterA53 extends CustomPainter {
  GamePainterA53({required this.engine, this.images});
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

    final rnd = math.Random(53);

    // 1. FLOOR & BACKGROUND - Haunted Victorian Mansion
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize), 
      Paint()..shader = ui.Gradient.radial(
        Offset(GameEngine.fieldSize/2, GameEngine.fieldSize/2),
        GameEngine.fieldSize/1.5,
        [const Color(0xFF2C1E30), const Color(0xFF100818), const Color(0xFF000000)],
        [0.0, 0.6, 1.0],
      )
    );

    // Checkered broken floor
    for(int i=0; i<GameEngine.fieldSize; i+=40) {
      for(int j=0; j<GameEngine.fieldSize; j+=40) {
        if ((i~/40 + j~/40) % 2 == 0) {
          canvas.drawRect(Rect.fromLTWH(i.toDouble(), j.toDouble(), 40, 40), Paint()..color=Colors.black54);
        } else {
          canvas.drawRect(Rect.fromLTWH(i.toDouble(), j.toDouble(), 40, 40), Paint()..color=const Color(0xFF332233));
        }
        // Random cracks
        if (rnd.nextDouble() > 0.8) {
           canvas.drawLine(Offset(i+10.0, j+10.0), Offset(i+30.0, j+30.0), Paint()..color=Colors.black87..strokeWidth=1);
        }
      }
    }

    // 2. WEATHER / PARTICLES - Fog/Dust
    for(int i = 0; i < 15; i++) {
      double fx = (rnd.nextDouble() * GameEngine.fieldSize + math.sin(engine.time+i) * 20) % GameEngine.fieldSize;
      double fy = (rnd.nextDouble() * GameEngine.fieldSize + math.cos(engine.time+i) * 20) % GameEngine.fieldSize;
      canvas.drawCircle(Offset(fx, fy), 20 + rnd.nextDouble()*30, Paint()..color=Colors.purpleAccent.withValues(alpha: 0.05)..maskFilter=const MaskFilter.blur(BlurStyle.normal, 3));
    }

    // 3. OBSTACLES - Bookcases / Victorian Furniture
    for (int i = 0; i < engine.obstacles.length; i++) {
        final obs = engine.obstacles[i];
        
        canvas.drawRect(obs.shift(const Offset(0, 20)), Paint()..color=const Color(0x99000000)..maskFilter=const MaskFilter.blur(BlurStyle.normal, 5));
        
        canvas.drawRect(obs, Paint()..color=const Color(0xFF3E2723));
        canvas.drawRect(obs, Paint()..color=const Color(0xFF261411)..style=PaintingStyle.stroke..strokeWidth=4);
        
        // Books on shelf
        for(double x = obs.left+5; x < obs.right-5; x+=40) {
          canvas.drawRect(Rect.fromLTWH(x, obs.top+5, 6, obs.height-10), Paint()..color=Color.fromARGB(255, rnd.nextInt(100)+50, 20, rnd.nextInt(50)+20));
        }
    }

    // 4. TARGETS - Ghostly Candles
    for (int i = 0; i < engine.targets.length; i++) {
        if (i < engine.currentTargetIndex) continue; 
        
        bool isActive = (i == engine.currentTargetIndex);
        final target = engine.targets[i];

        if (isActive) {
            double p = 1.0 + math.sin(engine.time*10)*0.1;
            canvas.drawCircle(target, 30*p, Paint()..color=Colors.deepOrangeAccent.withValues(alpha: 0.6)..maskFilter=const MaskFilter.blur(BlurStyle.normal, 3));
            canvas.drawCircle(target, 15*p, Paint()..color=Colors.yellow.withValues(alpha: 0.8)..maskFilter=const MaskFilter.blur(BlurStyle.normal, 5));
        }

        canvas.saveLayer(Rect.fromCenter(center: target, width: 80, height: 80), Paint()..color=Colors.white.withValues(alpha: isActive ? 1.0 : 0.3));
        
        // Candle stick
        canvas.drawRect(Rect.fromCenter(center: target+const Offset(0, 5), width: 10, height: 20), Paint()..color=Colors.grey[300]!);
        // Flame
        canvas.drawCircle(target+const Offset(0, -8), 6, Paint()..color=Colors.orange);
        
        canvas.restore();
    }

    // 5. EXIT GATE - Creepy Mirror
    if (engine.exitGate != null) {
        canvas.drawOval(Rect.fromCenter(center: engine.exitGate!, width: 60, height: 90), Paint()..color=Colors.teal.withValues(alpha: 0.3)..maskFilter=const MaskFilter.blur(BlurStyle.normal, 3));
        canvas.drawOval(Rect.fromCenter(center: engine.exitGate!, width: 60, height: 90), Paint()..color=Colors.amber[900]!..style=PaintingStyle.stroke..strokeWidth=6);
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

  @override bool shouldRepaint(covariant GamePainterA53 old) => true;
}
