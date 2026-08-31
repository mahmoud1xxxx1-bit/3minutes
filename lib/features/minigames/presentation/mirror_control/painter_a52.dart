import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'game_engine.dart';

class GamePainterA52 extends CustomPainter {
  GamePainterA52({required this.engine, this.images});
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

    final rnd = math.Random(52);

    // 1. FLOOR & BACKGROUND - Viking Longship Deck
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize), 
      Paint()..shader = ui.Gradient.linear(
        const Offset(0, 0), 
        const Offset(GameEngine.fieldSize, GameEngine.fieldSize), 
        [const Color(0xFF003366), const Color(0xFF001133), const Color(0xFF002244)],
        [0.0, 0.5, 1.0],
      )
    );

    for (double x = 40; x < GameEngine.fieldSize - 40; x+=30) {
      canvas.drawRect(Rect.fromLTWH(x, 0, 28, GameEngine.fieldSize), Paint()..color = const Color(0xFF5C4033));
      for(int k=0; k<5; k++) {
        double y = rnd.nextDouble() * GameEngine.fieldSize;
        canvas.drawLine(Offset(x+5, y), Offset(x+5, y+20+rnd.nextDouble()*30), Paint()..color=const Color(0xFF3E2723)..strokeWidth=1.5);
      }
    }
    
    canvas.drawRect(const Rect.fromLTWH(0, 0, 40, GameEngine.fieldSize), Paint()..color = const Color(0xFF4E342E));
    canvas.drawRect(Rect.fromLTWH(GameEngine.fieldSize-40, 0, 40, GameEngine.fieldSize), Paint()..color = const Color(0xFF4E342E));

    for (double y = 50; y < GameEngine.fieldSize; y+=120) {
      canvas.drawCircle(Offset(20, y), 25, Paint()..color=Colors.blueGrey);
      canvas.drawCircle(Offset(20, y), 25, Paint()..color=Colors.black..style=PaintingStyle.stroke..strokeWidth=3);
      canvas.drawCircle(Offset(20, y), 5, Paint()..color=Colors.grey);

      canvas.drawCircle(Offset(GameEngine.fieldSize-20, y), 25, Paint()..color=Colors.brown);
      canvas.drawCircle(Offset(GameEngine.fieldSize-20, y), 25, Paint()..color=Colors.black..style=PaintingStyle.stroke..strokeWidth=3);
      canvas.drawCircle(Offset(GameEngine.fieldSize-20, y), 5, Paint()..color=Colors.grey);
    }

    // 2. WEATHER / PARTICLES - Rain
    for(int i = 0; i < 40; i++) {
      double px = (rnd.nextDouble() * GameEngine.fieldSize + engine.time * 20) % GameEngine.fieldSize;
      double py = (engine.time * (30 + rnd.nextDouble()*30) + rnd.nextDouble() * GameEngine.fieldSize) % GameEngine.fieldSize;
      canvas.drawLine(Offset(px, py), Offset(px - 10, py + 20), Paint()..color=Colors.white.withValues(alpha: 0.4)..strokeWidth=1.5);
    }

    // 3. OBSTACLES 
    for (int i = 0; i < engine.obstacles.length; i++) {
        final obs = engine.obstacles[i];
        
        canvas.drawRect(obs.shift(const Offset(5, 10)), Paint()..color=const Color(0x88000000));
        
        canvas.drawRect(obs, Paint()..color=const Color(0xFF8D6E63));
        canvas.drawRect(obs, Paint()..color=const Color(0xFF3E2723)..style=PaintingStyle.stroke..strokeWidth=3);
        canvas.drawLine(obs.topLeft, obs.bottomRight, Paint()..color=const Color(0xFF3E2723)..strokeWidth=2);
        canvas.drawLine(obs.topRight, obs.bottomLeft, Paint()..color=const Color(0xFF3E2723)..strokeWidth=2);
    }

    // 4. TARGETS
    for (int i = 0; i < engine.targets.length; i++) {
        if (i < engine.currentTargetIndex) continue; 
        
        bool isActive = (i == engine.currentTargetIndex);
        final target = engine.targets[i];

        if (isActive) {
            double p = 1.0 + math.sin(engine.time*8)*0.2;
            canvas.drawCircle(target, 35*p, Paint()..color=Colors.yellowAccent.withValues(alpha: 0.6)..maskFilter=const MaskFilter.blur(BlurStyle.normal, 3));
            canvas.drawCircle(target, 20*p, Paint()..color=Colors.white.withValues(alpha: 0.8)..maskFilter=const MaskFilter.blur(BlurStyle.normal, 5));
        }

        canvas.saveLayer(Rect.fromCenter(center: target, width: 80, height: 80), Paint()..color=Colors.white.withValues(alpha: isActive ? 1.0 : 0.3));
        
        canvas.drawCircle(target, 15, Paint()..color=Colors.amber);
        canvas.drawLine(target+const Offset(-5, -5), target+const Offset(5, 5), Paint()..color=Colors.black..strokeWidth=2);
        canvas.drawLine(target+const Offset(-5, 5), target+const Offset(5, -5), Paint()..color=Colors.black..strokeWidth=2);
        
        canvas.restore();
    }

    // 5. EXIT GATE
    if (engine.exitGate != null) {
        canvas.drawCircle(engine.exitGate!, 45, Paint()..color=Colors.lightGreenAccent.withValues(alpha: 0.5)..maskFilter=const MaskFilter.blur(BlurStyle.normal, 3));
        canvas.drawCircle(engine.exitGate!, 40, Paint()..color=Colors.lightGreenAccent..style=PaintingStyle.stroke..strokeWidth=6);
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

  @override bool shouldRepaint(covariant GamePainterA52 old) => true;
}
