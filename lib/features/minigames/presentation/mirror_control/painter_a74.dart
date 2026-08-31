import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'game_engine.dart';

class GamePainterA74 extends CustomPainter {
  GamePainterA74({required this.engine, this.images});
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

    final rnd = math.Random(74);

    // 1. FLOOR & BACKGROUND (Floating Sky Islands)
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize),
      Paint()..shader = ui.Gradient.linear(
        const Offset(0, 0),
        const Offset(0, GameEngine.fieldSize),
        [const Color(0xFF4FC3F7), const Color(0xFFB3E5FC)],
      )
    );

    // Floating Islands in Background
    for (int i = 0; i < 8; i++) {
      double cx = rnd.nextDouble() * GameEngine.fieldSize;
      double cy = rnd.nextDouble() * GameEngine.fieldSize;
      double w = rnd.nextDouble() * 200 + 100;
      
      // Floating offset
      cy += math.sin(engine.time + i) * 15;

      final islandTop = Path();
      islandTop.moveTo(cx - w/2, cy);
      islandTop.quadraticBezierTo(cx, cy - 30, cx + w/2, cy);
      
      final islandBottom = Path();
      islandBottom.moveTo(cx - w/2, cy);
      islandBottom.lineTo(cx - w/4, cy + 50);
      islandBottom.lineTo(cx + w/4, cy + 80);
      islandBottom.lineTo(cx + w/2, cy);

      canvas.drawPath(islandTop, Paint()..color = const Color(0xFF81C784)); // Grass
      canvas.drawPath(islandBottom, Paint()..color = const Color(0xFF795548)); // Dirt/Rock
    }

    // 2. WEATHER / PARTICLES (Clouds & Wind)
    for (int i = 0; i < 20; i++) {
      double px = (rnd.nextDouble() * GameEngine.fieldSize + engine.time * 20) % (GameEngine.fieldSize + 200) - 100;
      double py = rnd.nextDouble() * GameEngine.fieldSize;
      
      canvas.drawCircle(Offset(px, py), 40, Paint()..color = Colors.white.withValues(alpha: 0.4)..maskFilter=const MaskFilter.blur(BlurStyle.normal, 3));
      canvas.drawCircle(Offset(px+30, py-10), 30, Paint()..color = Colors.white.withValues(alpha: 0.4)..maskFilter=const MaskFilter.blur(BlurStyle.normal, 3));
    }

    // 3. OBSTACLES
    for (int i = 0; i < engine.obstacles.length; i++) {
        final obs = engine.obstacles[i];
        canvas.drawRect(obs.shift(const Offset(0, 20)), Paint()..color=Colors.black26..maskFilter=const MaskFilter.blur(BlurStyle.normal, 3)); // Deep soft shadow for floating
        
        // Marble Temple Blocks
        canvas.drawRect(obs, Paint()..color=const Color(0xFFF5F5F5));
        
        // Greek columns detail
        for (double x = obs.left + 5; x < obs.right; x+=60) {
           canvas.drawLine(Offset(x, obs.top), Offset(x, obs.bottom), Paint()..color=Colors.black12..strokeWidth=4);
        }
        
        // Golden trim
        canvas.drawRect(Rect.fromLTRB(obs.left, obs.top, obs.right, obs.top + 5), Paint()..color=Colors.amberAccent);
        canvas.drawRect(Rect.fromLTRB(obs.left, obs.bottom - 5, obs.right, obs.bottom), Paint()..color=Colors.amberAccent);
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
        
        // Golden Winged Orb
        canvas.drawCircle(target, 15, Paint()..color=Colors.amber);
        final wings = Path();
        wings.moveTo(target.dx - 15, target.dy);
        wings.quadraticBezierTo(target.dx - 30, target.dy - 20, target.dx - 40, target.dy - 10);
        wings.quadraticBezierTo(target.dx - 30, target.dy + 5, target.dx - 15, target.dy);
        
        wings.moveTo(target.dx + 15, target.dy);
        wings.quadraticBezierTo(target.dx + 30, target.dy - 20, target.dx + 40, target.dy - 10);
        wings.quadraticBezierTo(target.dx + 30, target.dy + 5, target.dx + 15, target.dy);
        
        canvas.drawPath(wings, Paint()..color=Colors.white);
        
        canvas.restore();
    }

    // 5. EXIT GATE
    if (engine.exitGate != null) {
        canvas.drawCircle(engine.exitGate!, 45, Paint()..color=Colors.lightBlueAccent..style=PaintingStyle.stroke..strokeWidth=8);
        
        // Swirling winds around portal
        for(int i=0; i<3; i++) {
            canvas.drawArc(
              Rect.fromCircle(center: engine.exitGate!, radius: 35 + i*5), 
              engine.time*3 + i, 
              math.pi/2, 
              false, 
              Paint()..color=Colors.white..style=PaintingStyle.stroke..strokeWidth=3
            );
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

  @override bool shouldRepaint(covariant GamePainterA74 old) => true;
}
