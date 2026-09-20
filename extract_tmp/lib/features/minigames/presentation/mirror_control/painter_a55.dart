import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'game_engine.dart';

class GamePainterA55 extends CustomPainter {
  GamePainterA55({required this.engine, this.images});
  final GameEngine engine;
  final Map<String, ui.Image>? images;

  void drawGear(Canvas canvas, Offset center, double radius, double angle, Color color) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    
    Path gearPath = Path();
    int teeth = 12;
    double innerRadius = radius * 0.7;
    for(int i=0; i<teeth; i++) {
      double a1 = i * (math.pi * 2) / teeth;
      double a2 = (i + 0.3) * (math.pi * 2) / teeth;
      double a3 = (i + 0.5) * (math.pi * 2) / teeth;
      double a4 = (i + 0.8) * (math.pi * 2) / teeth;
      
      if(i==0) gearPath.moveTo(math.cos(a1)*radius, math.sin(a1)*radius);
      else gearPath.lineTo(math.cos(a1)*radius, math.sin(a1)*radius);
      
      gearPath.lineTo(math.cos(a2)*radius, math.sin(a2)*radius);
      gearPath.lineTo(math.cos(a3)*innerRadius, math.sin(a3)*innerRadius);
      gearPath.lineTo(math.cos(a4)*innerRadius, math.sin(a4)*innerRadius);
    }
    gearPath.close();
    
    canvas.drawPath(gearPath, Paint()..color = color);
    canvas.drawPath(gearPath, Paint()..color = Colors.black45..style=PaintingStyle.stroke..strokeWidth=2);
    canvas.drawCircle(Offset.zero, radius*0.3, Paint()..color=Colors.black54);
    canvas.restore();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / GameEngine.fieldSize;
    final scaleY = size.height / GameEngine.fieldSize;
    final scale = scaleX < scaleY ? scaleX : scaleY;
    
    canvas.translate((size.width - (GameEngine.fieldSize * scale)) / 2, (size.height - (GameEngine.fieldSize * scale)) / 2);
    canvas.scale(scale, scale);
    canvas.clipRect(const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize));

    final rnd = math.Random(55);

    // 1. FLOOR & BACKGROUND - Clockwork Gearbox
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize), 
      Paint()..color = const Color(0xFF2A1B14)
    );

    // Giant background gears turning
    drawGear(canvas, const Offset(100, 100), 120, engine.time, const Color(0xFF8B5A2B));
    drawGear(canvas, const Offset(300, 400), 180, -engine.time*0.5, const Color(0xFFCD853F));
    drawGear(canvas, const Offset(450, 100), 90, engine.time*1.5, const Color(0xFFB87333));
    
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize), 
      Paint()..color = Colors.black.withOpacity(0.4)
    );

    // 2. WEATHER / PARTICLES - Steam
    for(int i = 0; i < 20; i++) {
      double sx = (rnd.nextDouble() * GameEngine.fieldSize + math.sin(engine.time+i) * 30) % GameEngine.fieldSize;
      double sy = (rnd.nextDouble() * GameEngine.fieldSize - engine.time * 20) % GameEngine.fieldSize;
      if (sy < 0) sy += GameEngine.fieldSize;
      canvas.drawCircle(Offset(sx, sy), 15 + rnd.nextDouble()*20, Paint()..color=Colors.white.withOpacity(0.1)..maskFilter=const MaskFilter.blur(BlurStyle.normal, 3));
    }

    // 3. OBSTACLES - Brass Blocks
    for (int i = 0; i < engine.obstacles.length; i++) {
        final obs = engine.obstacles[i];
        
        canvas.drawRect(obs.shift(const Offset(5, 10)), Paint()..color=const Color(0x99000000));
        
        canvas.drawRect(obs, Paint()..shader = ui.Gradient.linear(
          obs.topLeft, obs.bottomRight, 
          [const Color(0xFFE5C158), const Color(0xFFB87333), const Color(0xFF8B4513)],
          [0.0, 0.5, 1.0]
        ));
        
        canvas.drawRect(obs, Paint()..color=const Color(0xFF3E2723)..style=PaintingStyle.stroke..strokeWidth=2);
        
        // Rivets
        canvas.drawCircle(obs.topLeft + const Offset(5,5), 2, Paint()..color=Colors.black54);
        canvas.drawCircle(obs.topRight + const Offset(-5,5), 2, Paint()..color=Colors.black54);
        canvas.drawCircle(obs.bottomLeft + const Offset(5,-5), 2, Paint()..color=Colors.black54);
        canvas.drawCircle(obs.bottomRight + const Offset(-5,-5), 2, Paint()..color=Colors.black54);
    }

    // 4. TARGETS - Glowing Gemstones
    for (int i = 0; i < engine.targets.length; i++) {
        if (i < engine.currentTargetIndex) continue; 
        
        bool isActive = (i == engine.currentTargetIndex);
        final target = engine.targets[i];

        if (isActive) {
            double p = 1.0 + math.sin(engine.time*8)*0.2;
            canvas.drawCircle(target, 35*p, Paint()..color=Colors.orangeAccent.withOpacity(0.6)..maskFilter=const MaskFilter.blur(BlurStyle.normal, 3));
            canvas.drawCircle(target, 20*p, Paint()..color=Colors.white.withOpacity(0.8)..maskFilter=const MaskFilter.blur(BlurStyle.normal, 5));
        }

        canvas.saveLayer(Rect.fromCenter(center: target, width: 80, height: 80), Paint()..color=Colors.white.withOpacity(isActive ? 1.0 : 0.3));
        
        // Gem shape
        Path gem = Path()
          ..moveTo(target.dx, target.dy - 12)
          ..lineTo(target.dx + 12, target.dy)
          ..lineTo(target.dx, target.dy + 12)
          ..lineTo(target.dx - 12, target.dy)
          ..close();
        canvas.drawPath(gem, Paint()..color=Colors.redAccent);
        canvas.drawPath(gem, Paint()..color=Colors.yellow..style=PaintingStyle.stroke..strokeWidth=2);
        
        canvas.restore();
    }

    // 5. EXIT GATE - Vault Door
    if (engine.exitGate != null) {
        canvas.drawCircle(engine.exitGate!, 45, Paint()..color=Colors.amber.withOpacity(0.3)..maskFilter=const MaskFilter.blur(BlurStyle.normal, 3));
        drawGear(canvas, engine.exitGate!, 40, engine.time*2, const Color(0xFFD4AF37));
        canvas.drawCircle(engine.exitGate!, 20, Paint()..color=Colors.black87);
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

  @override bool shouldRepaint(covariant GamePainterA55 old) => true;
}
