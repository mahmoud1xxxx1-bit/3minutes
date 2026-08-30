import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'game_engine.dart';

class GamePainterA51 extends CustomPainter {
  GamePainterA51({required this.engine, this.images});
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

    final rnd = math.Random(51);

    // 1. FLOOR & BACKGROUND - Alien Coral Reef
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize), 
      Paint()..shader = ui.Gradient.linear(
        const Offset(0, 0), 
        const Offset(0, GameEngine.fieldSize), 
        [const Color(0xFF001133), const Color(0xFF003366), const Color(0xFF005577)],
        [0.0, 0.5, 1.0],
      )
    );

    // Draw wavy sand dunes at the bottom
    Path sandPath = Path()..moveTo(0, GameEngine.fieldSize);
    for (double x = 0; x <= GameEngine.fieldSize; x+=60) {
      sandPath.lineTo(x, GameEngine.fieldSize - 50 + math.sin(x * 0.05) * 20);
    }
    sandPath.lineTo(GameEngine.fieldSize, GameEngine.fieldSize);
    sandPath.close();
    canvas.drawPath(sandPath, Paint()..color = const Color(0xFF448866));

    // Draw alien coral shapes
    for (int i = 0; i < 30; i++) {
      double cx = rnd.nextDouble() * GameEngine.fieldSize;
      double cy = rnd.nextDouble() * GameEngine.fieldSize;
      double r = 10 + rnd.nextDouble() * 30;
      canvas.drawCircle(
        Offset(cx, cy), 
        r, 
        Paint()
          ..color = Color.fromARGB(255, rnd.nextInt(255), 100, rnd.nextInt(255)).withOpacity(0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3)
      );
    }

    // 2. WEATHER / PARTICLES - Bubbles
    for(int i = 0; i < 20; i++) {
      double bx = rnd.nextDouble() * GameEngine.fieldSize;
      double by = (engine.time * (10 + rnd.nextDouble()*20) + rnd.nextDouble() * GameEngine.fieldSize) % GameEngine.fieldSize;
      by = GameEngine.fieldSize - by;
      canvas.drawCircle(Offset(bx, by), 2 + rnd.nextDouble()*4, Paint()..color=Colors.white.withOpacity(0.3)..style=PaintingStyle.stroke);
    }

    // 3. OBSTACLES
    for (int i = 0; i < engine.obstacles.length; i++) {
        final obs = engine.obstacles[i];
        
        canvas.drawRect(obs.shift(const Offset(5, 15)), Paint()..color=const Color(0x66000000));
        
        canvas.drawRect(obs, Paint()..shader = ui.Gradient.linear(
          obs.topLeft, obs.bottomRight, 
          [Colors.pinkAccent, Colors.purpleAccent, Colors.deepPurple],
          [0.0, 0.5, 1.0]
        ));
        
        for(double y=obs.top+5; y<obs.bottom; y+=40) {
           canvas.drawLine(Offset(obs.left, y), Offset(obs.right, y), Paint()..color=Colors.white24..strokeWidth=2);
        }
    }

    // 4. TARGETS
    for (int i = 0; i < engine.targets.length; i++) {
        if (i < engine.currentTargetIndex) continue; 
        
        bool isActive = (i == engine.currentTargetIndex);
        final target = engine.targets[i];

        if (isActive) {
            double p = 1.0 + math.sin(engine.time*8)*0.2;
            canvas.drawCircle(target, 35*p, Paint()..color=Colors.cyanAccent.withOpacity(0.6)..maskFilter=const MaskFilter.blur(BlurStyle.normal, 3));
            canvas.drawCircle(target, 20*p, Paint()..color=Colors.white.withOpacity(0.8)..maskFilter=const MaskFilter.blur(BlurStyle.normal, 5));
        }

        canvas.saveLayer(Rect.fromCenter(center: target, width: 80, height: 80), Paint()..color=Colors.white.withOpacity(isActive ? 1.0 : 0.3));
        
        canvas.drawCircle(target, 15, Paint()..shader = ui.Gradient.radial(
          target, 15, [Colors.white, Colors.cyan, Colors.blue], [0.0, 0.5, 1.0]
        ));
        
        canvas.restore();
    }

    // 5. EXIT GATE
    if (engine.exitGate != null) {
        double pulse = math.sin(engine.time * 5) * 5;
        canvas.drawCircle(engine.exitGate!, 45 + pulse, Paint()..color=Colors.lightBlueAccent.withOpacity(0.5)..maskFilter=const MaskFilter.blur(BlurStyle.normal, 3));
        canvas.drawCircle(engine.exitGate!, 40, Paint()..color=Colors.white..style=PaintingStyle.stroke..strokeWidth=4);
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

  @override bool shouldRepaint(covariant GamePainterA51 old) => true;
}
