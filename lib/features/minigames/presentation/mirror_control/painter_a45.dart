import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'game_engine.dart';

class GamePainterA45 extends CustomPainter {
  GamePainterA45({required this.engine, this.images});
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

    // FLOOR

    canvas.drawRect(const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize), Paint()..color = const Color(0xFFCDBA96)); // Dusty sand
    final dust = Paint()..color=const Color(0xFFA0522D).withValues(alpha: 0.3)..style=PaintingStyle.stroke..strokeWidth=2;
    for(double y=0; y<GameEngine.fieldSize; y+=60) {
        canvas.drawLine(Offset(0, y + math.sin(y)*10), Offset(GameEngine.fieldSize, y - math.sin(y)*10), dust); // wind lines
    }
    

    // WEATHER

    // Tumbleweeds rolling by
    for (int i = 0; i < 5; i++) {
      double px = ((i * 200) + engine.time * 150) % (GameEngine.fieldSize*1.5) - 200;
      double py = ((i * 180) + math.sin(engine.time*5 + i)*20) % GameEngine.fieldSize;
      canvas.save(); canvas.translate(px, py); canvas.rotate(engine.time * 5);
      canvas.drawCircle(Offset.zero, 20, Paint()..color=const Color(0xFF8B4513).withValues(alpha: 0.5)..style=PaintingStyle.stroke..strokeWidth=2);
      canvas.drawCircle(Offset.zero, 15, Paint()..color=const Color(0xFFA0522D).withValues(alpha: 0.5)..style=PaintingStyle.stroke..strokeWidth=2);
      for(int j=0; j<4; j++) { canvas.rotate(math.pi/4); canvas.drawLine(const Offset(-20, 0), const Offset(20, 0), Paint()..color=const Color(0xFF8B4513)..strokeWidth=1); }
      canvas.restore();
    }
    

    // OBSTACLES

    for (int i = 0; i < engine.obstacles.length; i++) {
      final obs = engine.obstacles[i];
      canvas.drawRect(obs.shift(const Offset(10, 10)), Paint()..color=Colors.black26);
      // Wooden barrels
      canvas.drawRect(obs, Paint()..color=const Color(0xFF8B5A2B));
      canvas.drawRect(obs.deflate(4.0), Paint()..color=const Color(0xFF5C4033)..style=PaintingStyle.stroke..strokeWidth=2);
      canvas.drawLine(obs.center + const Offset(-15, 0), obs.center + const Offset(15, 0), Paint()..color=const Color(0xFF5C4033)..strokeWidth=2);
      canvas.drawLine(obs.center + const Offset(0, -15), obs.center + const Offset(0, 15), Paint()..color=const Color(0xFF5C4033)..strokeWidth=2);
      // Iron bands
      canvas.drawRect(obs, Paint()..color=const Color(0xFF424242)..style=PaintingStyle.stroke..strokeWidth=3);
    }
    

    // TARGETS
    for (int i = 0; i < engine.targets.length; i++) {
      if (i < engine.currentTargetIndex) continue;
      final target = engine.targets[i];
      final tr = GameEngine.targetRadius; 
      double floatOffset = math.sin(engine.time * 4 + i) * 5;

      final isNext = i == engine.currentTargetIndex;
      canvas.drawOval(Rect.fromCenter(center: target + const Offset(0, 15), width: tr*1.5, height: tr*0.8), Paint()..color=Colors.black26);
      canvas.save(); canvas.translate(target.dx, target.dy - floatOffset);
      if (isNext) {
          // Glowing Silver Sheriff Star
          canvas.save(); canvas.rotate(engine.time * 2);
          Path star = Path();
          for(int s=0; s<12; s++) {
             double r = (s%2==0) ? 18.0 : 8.0;
             double angle = s * math.pi / 6;
             if(s==0) {
               star.moveTo(r*math.cos(angle), r*math.sin(angle));
             } else {
               star.lineTo(r*math.cos(angle), r*math.sin(angle));
             }
          }
          star.close();
          canvas.drawPath(star, Paint()..color=const Color(0xFFE0E0E0));
          canvas.drawPath(star, Paint()..color=Colors.white..style=PaintingStyle.stroke..strokeWidth=2);
          canvas.restore();
          canvas.drawCircle(Offset.zero, tr*2, Paint()..shader = ui.Gradient.radial(Offset.zero, tr*2, [Colors.white.withValues(alpha: 0.5), Colors.transparent]));
      } else {
          // Rusty spur
          canvas.drawCircle(Offset.zero, 12, Paint()..color=const Color(0xFF5D4037)..style=PaintingStyle.stroke..strokeWidth=3);
          canvas.drawCircle(Offset.zero, 4, Paint()..color=const Color(0xFF3E2723));
      }
      canvas.restore();
    
    }

    // EXIT GATE
    if (engine.exitGate != null) {
      final center = engine.exitGate!;

      canvas.drawRect(Rect.fromCenter(center: center, width: 80, height: 80), Paint()..color=const Color(0xFF8B5A2B));
      canvas.drawRect(Rect.fromCenter(center: center, width: 80, height: 80), Paint()..color=const Color(0xFF5C4033)..style=PaintingStyle.stroke..strokeWidth=4);
      // Saloon doors swinging
      canvas.save(); canvas.translate(center.dx, center.dy);
      double swing = math.sin(engine.time * 3) * 10;
      canvas.drawRect(Rect.fromLTWH(-40, -40, 35 + swing, 80), Paint()..color=const Color(0xFFCD853F));
      canvas.drawRect(Rect.fromLTWH(5 - swing, -40, 35 + swing, 80), Paint()..color=const Color(0xFFCD853F));
      canvas.restore();
    
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
  @override bool shouldRepaint(covariant GamePainterA45 old) => true;
}
