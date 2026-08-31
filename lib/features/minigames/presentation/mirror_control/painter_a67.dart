import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'game_engine.dart';

class GamePainterA67 extends CustomPainter {
  GamePainterA67({required this.engine, this.images});
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

    final rnd = math.Random(67);

    // 1. FLOOR & BACKGROUND (Cyberpunk Neon Slums)
    canvas.drawRect(const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize), Paint()..color = const Color(0xFF0B0C10));
    
    // Grid lines
    for (double i = 0; i < GameEngine.fieldSize; i+=40) {
        canvas.drawLine(Offset(i, 0), Offset(i, GameEngine.fieldSize), Paint()..color=Colors.cyanAccent.withValues(alpha: 0.1)..strokeWidth=1);
        canvas.drawLine(Offset(0, i), Offset(GameEngine.fieldSize, i), Paint()..color=Colors.cyanAccent.withValues(alpha: 0.1)..strokeWidth=1);
    }
    
    // Rain
    for (int i = 0; i < 100; i++) {
        double x = rnd.nextDouble() * GameEngine.fieldSize;
        double y = (rnd.nextDouble() * GameEngine.fieldSize + engine.time * 200) % GameEngine.fieldSize;
        canvas.drawLine(Offset(x, y), Offset(x - 5, y + 15), Paint()..color=Colors.cyanAccent.withValues(alpha: 0.5)..strokeWidth=2);
    }

    // 3. OBSTACLES
    for (int i = 0; i < engine.obstacles.length; i++) {
        final obs = engine.obstacles[i];
        
        canvas.drawRect(obs.shift(const Offset(10, 10)), Paint()..color=Colors.black);
        canvas.drawRect(obs, Paint()..color=const Color(0xFF1F2833));
        
        // Neon borders
        Color neon = i % 2 == 0 ? Colors.pinkAccent : Colors.cyanAccent;
        canvas.drawRect(obs, Paint()..color=neon.withValues(alpha: 0.8)..style=PaintingStyle.stroke..strokeWidth=2..maskFilter=const MaskFilter.blur(BlurStyle.normal, 5));
        canvas.drawRect(obs, Paint()..color=Colors.white..style=PaintingStyle.stroke..strokeWidth=1);
        
        // Tech details
        canvas.drawRect(Rect.fromLTWH(obs.left + 5, obs.top + 5, obs.width/3, obs.height/3), Paint()..color=Colors.black45);
    }

    // 4. TARGETS
    for (int i = 0; i < engine.targets.length; i++) {
        if (i < engine.currentTargetIndex) continue; 
        bool isActive = (i == engine.currentTargetIndex);
        final target = engine.targets[i];

        if (isActive) {
            double p = 1.0 + math.sin(engine.time*12)*0.2;
            canvas.drawCircle(target, 35*p, Paint()..color=Colors.greenAccent.withValues(alpha: 0.6)..maskFilter=const MaskFilter.blur(BlurStyle.normal, 3));
            canvas.drawCircle(target, 20*p, Paint()..color=Colors.white.withValues(alpha: 0.8)..maskFilter=const MaskFilter.blur(BlurStyle.normal, 5));
        }
        canvas.saveLayer(Rect.fromCenter(center: target, width: 80, height: 80), Paint()..color=Colors.white.withValues(alpha: isActive ? 1.0 : 0.3));
        
        canvas.drawRect(Rect.fromCenter(center: target, width: 20, height: 20), Paint()..color=Colors.greenAccent..style=PaintingStyle.stroke..strokeWidth=4..maskFilter=const MaskFilter.blur(BlurStyle.normal, 3));
        canvas.drawRect(Rect.fromCenter(center: target, width: 20, height: 20), Paint()..color=Colors.white..style=PaintingStyle.stroke..strokeWidth=2);
        canvas.drawCircle(target, 4, Paint()..color=Colors.white);
        
        canvas.restore();
    }

    // 5. EXIT GATE
    if (engine.exitGate != null) {
        canvas.drawCircle(engine.exitGate!, 45, Paint()..color=Colors.purpleAccent..style=PaintingStyle.stroke..strokeWidth=8..maskFilter=const MaskFilter.blur(BlurStyle.normal, 3));
        canvas.drawCircle(engine.exitGate!, 45, Paint()..color=Colors.white..style=PaintingStyle.stroke..strokeWidth=2);
        
        Path zig = Path();
        zig.moveTo(engine.exitGate!.dx - 20, engine.exitGate!.dy - 20);
        zig.lineTo(engine.exitGate!.dx + 10, engine.exitGate!.dy);
        zig.lineTo(engine.exitGate!.dx - 10, engine.exitGate!.dy + 10);
        zig.lineTo(engine.exitGate!.dx + 20, engine.exitGate!.dy + 20);
        canvas.drawPath(zig, Paint()..color=Colors.cyanAccent..style=PaintingStyle.stroke..strokeWidth=4..maskFilter=const MaskFilter.blur(BlurStyle.normal, 3));
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

  @override bool shouldRepaint(covariant GamePainterA67 old) => true;
}
