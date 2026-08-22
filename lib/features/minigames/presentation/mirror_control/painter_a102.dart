import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'game_engine.dart';

class GamePainterA102 extends CustomPainter {
  GamePainterA102({required this.engine, this.images});
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

    final rnd = math.Random(102);

    // ==========================================
    // 1. ARTISTIC BACKGROUND AND FLOOR
    // ==========================================
    // Deep space void
    canvas.drawRect(const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize), Paint()..color = const Color(0xFF00001A));
    
    final center = const Offset(GameEngine.fieldSize/2, GameEngine.fieldSize/2);
    
    // Swirling vortex background
    for(int i=0; i<30; i++) {
        double r = (engine.time * 50 + i * 40) % 1000;
        double angle = r * 0.01 + engine.time;
        final swirlPaint = Paint()
            ..color = HSVColor.fromAHSV(1.0, (angle * 40) % 360, 1.0, 1.0 - (r/1000)).toColor().withOpacity(0.4)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2 + (r/100);
        canvas.drawArc(Rect.fromCircle(center: center, radius: r), angle, math.pi/2, false, swirlPaint);
        canvas.drawArc(Rect.fromCircle(center: center, radius: r), angle + math.pi, math.pi/2, false, swirlPaint);
    }
    
    // Stretched light rays
    final rayPaint = Paint()..color = Colors.white.withOpacity(0.3)..style = PaintingStyle.stroke;
    for(int i=0; i<20; i++) {
        double a = rnd.nextDouble() * math.pi * 2 + engine.time * 0.5 * (i%2==0?1:-1);
        canvas.drawLine(
            center + Offset(math.cos(a) * 50, math.sin(a) * 50),
            center + Offset(math.cos(a) * GameEngine.fieldSize, math.sin(a) * GameEngine.fieldSize),
            rayPaint..strokeWidth = rnd.nextDouble() * 3 + 1
        );
    }

    // ==========================================
    // 2. OBSTACLES
    // ==========================================
    for (int i = 0; i < engine.obstacles.length; i++) {
        final obs = engine.obstacles[i];
        
        // Shadow (glow actually)
        canvas.drawRect(obs.inflate(5), Paint()..color=const Color(0xFF9400D3).withOpacity(0.5)..maskFilter=const MaskFilter.blur(BlurStyle.normal, 3)); 
        
        // Crystalline Space debris
        final gradPaint = Paint()..shader = ui.Gradient.linear(
            obs.topLeft, obs.bottomRight, 
            [const Color(0xFF4B0082), const Color(0xFF9400D3), const Color(0xFF00FFFF)]
        );
        canvas.drawRect(obs, gradPaint);
        
        canvas.drawRect(obs.deflate(2), Paint()..color=Colors.white.withOpacity(0.2)..style=PaintingStyle.stroke..strokeWidth=1);
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
        
        // Mini wormhole target
        for (int j=0; j<3; j++) {
            canvas.drawCircle(target, 15 - j*4.0, Paint()..color=HSVColor.fromAHSV(1.0, (engine.time*100 + j*50)%360, 1.0, 1.0).toColor().withOpacity(0.8)..style=PaintingStyle.stroke..strokeWidth=2);
        }
        canvas.drawCircle(target, 5, Paint()..color=Colors.white);
        
        canvas.restore();
    }

    // ==========================================
    // 4. EXIT GATE
    // ==========================================
    if (engine.exitGate != null) {
        final r = 45.0 + math.sin(engine.time*10)*5;
        canvas.drawCircle(engine.exitGate!, r, Paint()..color=Colors.cyanAccent.withOpacity(0.8)..style=PaintingStyle.stroke..strokeWidth=8..maskFilter=const MaskFilter.blur(BlurStyle.normal, 5));
        canvas.drawCircle(engine.exitGate!, r-10, Paint()..color=Colors.purpleAccent.withOpacity(0.8)..style=PaintingStyle.stroke..strokeWidth=4);
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

  @override bool shouldRepaint(covariant GamePainterA102 old) => true;
}
