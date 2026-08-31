import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'game_engine.dart';

class GamePainterA105 extends CustomPainter {
  GamePainterA105({required this.engine, this.images});
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

// deleted

    // ==========================================
    // 1. ARTISTIC BACKGROUND AND FLOOR
    // ==========================================
    // The Core of Time - Bright gold/white
    canvas.drawRect(const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize), Paint()..color = const Color(0xFFFFFDF0));
    
    // Background giant gears
    final gearPaint = Paint()..color=const Color(0xFFF0E68C).withValues(alpha: 0.5)..style=PaintingStyle.stroke..strokeWidth=8;
    for(int i=0; i<3; i++) {
        final cx = (i * 400.0) % GameEngine.fieldSize;
        final cy = (i * 300.0) % GameEngine.fieldSize;
        canvas.save();
        canvas.translate(cx, cy);
        canvas.rotate(engine.time * 0.5 * (i%2==0?1:-1));
        
        canvas.drawCircle(Offset.zero, 150, gearPaint);
        for(int j=0; j<12; j++) {
            canvas.rotate(math.pi*2/12);
            canvas.drawRect(const Rect.fromLTWH(140, -10, 30, 20), Paint()..color=const Color(0xFFF0E68C).withValues(alpha: 0.5));
        }
        canvas.restore();
    }
    
    // Chronal energy waves
    final wavePaint = Paint()..color=Colors.amberAccent.withValues(alpha: 0.3)..style=PaintingStyle.stroke..strokeWidth=3;
    for(double y=0; y<GameEngine.fieldSize; y+=80) {
        final path = Path();
        path.moveTo(0, y);
        for(double x=0; x<=GameEngine.fieldSize; x+=50) {
            path.lineTo(x, y + math.sin(x*0.05 + engine.time*2)*20);
        }
        canvas.drawPath(path, wavePaint);
    }

    // ==========================================
    // 2. OBSTACLES
    // ==========================================
    for (int i = 0; i < engine.obstacles.length; i++) {
        final obs = engine.obstacles[i];
        
        // Shadow
        canvas.drawRect(obs.shift(const Offset(0, 15)), Paint()..color=Colors.black26); 
        
        // Golden hourglass block
        canvas.drawRect(obs, Paint()..color=const Color(0xFFFFD700)); // Gold
        canvas.drawRect(obs.deflate(4), Paint()..color=Colors.white.withValues(alpha: 0.8)); // Glass
        
        // Sand inside
        final sandHeight = obs.height * 0.5 * (1.0 + math.sin(engine.time + i)*0.5);
        canvas.drawRect(Rect.fromLTRB(obs.left+4, obs.bottom-4-sandHeight, obs.right-4, obs.bottom-4), Paint()..color=const Color(0xFFDAA520));
        
        // Hourglass shape lines
        canvas.drawLine(obs.topLeft, obs.bottomRight, Paint()..color=const Color(0xFFB8860B)..strokeWidth=2);
        canvas.drawLine(obs.topRight, obs.bottomLeft, Paint()..color=const Color(0xFFB8860B)..strokeWidth=2);
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
        
        // Pocket watch target
        canvas.drawCircle(target, 16, Paint()..color=const Color(0xFFFFD700));
        canvas.drawCircle(target, 14, Paint()..color=Colors.white);
        canvas.drawLine(target, target + Offset(math.cos(engine.time*5)*10, math.sin(engine.time*5)*10), Paint()..color=Colors.black..strokeWidth=2); // fast hand
        canvas.drawLine(target, target + Offset(math.cos(engine.time)*8, math.sin(engine.time)*8), Paint()..color=Colors.black..strokeWidth=3); // slow hand
        
        canvas.restore();
    }

    // ==========================================
    // 4. EXIT GATE
    // ==========================================
    if (engine.exitGate != null) {
        canvas.drawCircle(engine.exitGate!, 45, Paint()..color=const Color(0xFFFFD700)..style=PaintingStyle.stroke..strokeWidth=8);
        for(int i=0; i<12; i++) {
            double a = i * math.pi/6;
            canvas.drawCircle(engine.exitGate! + Offset(math.cos(a)*45, math.sin(a)*45), 4, Paint()..color=Colors.amber);
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

  @override bool shouldRepaint(covariant GamePainterA105 old) => true;
}
