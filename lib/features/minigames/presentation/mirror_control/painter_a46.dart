import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'game_engine.dart';

class GamePainterA46 extends CustomPainter {
  GamePainterA46({required this.engine, this.images});
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

    canvas.drawRect(const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize), Paint()..color = const Color(0xFF000000)); // Lead lines base
    // Large colored glass shards
    final rnd = math.Random(46);
    for(int i=0; i<40; i++) {
        Path shard = Path()..moveTo(rnd.nextDouble()*GameEngine.fieldSize, rnd.nextDouble()*GameEngine.fieldSize);
        shard.lineTo(rnd.nextDouble()*GameEngine.fieldSize, rnd.nextDouble()*GameEngine.fieldSize);
        shard.lineTo(rnd.nextDouble()*GameEngine.fieldSize, rnd.nextDouble()*GameEngine.fieldSize);
        shard.close();
        final c = [const Color(0xFF1E88E5), const Color(0xFFE53935), const Color(0xFFFFB300), const Color(0xFF43A047)][i%4];
        canvas.drawPath(shard, Paint()..color=c.withValues(alpha: 0.4));
        canvas.drawPath(shard, Paint()..color=Colors.black..style=PaintingStyle.stroke..strokeWidth=4);
    }
    

    // WEATHER

    for (int i = 0; i < 20; i++) {
      double px = ((i * 75) + engine.time * 20) % GameEngine.fieldSize;
      double py = ((i * 110) + engine.time * 20) % GameEngine.fieldSize;
      // Light rays piercing through
      canvas.drawLine(Offset(px, py), Offset(px+100, py+100), Paint()..shader=ui.Gradient.linear(Offset(px,py), Offset(px+100, py+100), [Colors.white.withValues(alpha: 0.3), Colors.transparent])..strokeWidth=15);
    }
    

    // OBSTACLES

    for (int i = 0; i < engine.obstacles.length; i++) {
      final obs = engine.obstacles[i];
      // Thick lead frames filled with solid glass color
      final c = [const Color(0xFF0D47A1), const Color(0xFFB71C1C), const Color(0xFF1B5E20)][i%3];
      canvas.drawRect(obs, Paint()..color=c);
      canvas.drawRect(obs, Paint()..color=Colors.black..style=PaintingStyle.stroke..strokeWidth=8);
      // Glare
      canvas.drawLine(obs.bottomLeft + const Offset(5, -5), obs.topRight + const Offset(-5, 5), Paint()..color=Colors.white.withValues(alpha: 0.5)..strokeWidth=4);
    }
    

    // TARGETS
    for (int i = 0; i < engine.targets.length; i++) {
      if (i < engine.currentTargetIndex) continue;
      final target = engine.targets[i];
      final tr = GameEngine.targetRadius; 
      double floatOffset = math.sin(engine.time * 4 + i) * 5;

      final isNext = i == engine.currentTargetIndex;
      canvas.save(); canvas.translate(target.dx, target.dy - floatOffset);
      if (isNext) {
          // Blinding pure light prism
          Path diamond = Path()..moveTo(0, -20)..lineTo(15, 0)..lineTo(0, 20)..lineTo(-15, 0)..close();
          canvas.drawPath(diamond, Paint()..color=Colors.white);
          canvas.drawCircle(Offset.zero, tr*3, Paint()..shader = ui.Gradient.radial(Offset.zero, tr*3, [Colors.white.withValues(alpha: 0.8), Colors.transparent]));
          // Rainbow dispersion
          canvas.save(); canvas.rotate(engine.time * 2);
          canvas.drawLine(Offset.zero, const Offset(40, 40), Paint()..color=Colors.cyanAccent..strokeWidth=2);
          canvas.drawLine(Offset.zero, const Offset(-40, -40), Paint()..color=Colors.pinkAccent..strokeWidth=2);
          canvas.drawLine(Offset.zero, const Offset(-40, 40), Paint()..color=Colors.yellowAccent..strokeWidth=2);
          canvas.restore();
      } else {
          // Dull lead piece
          canvas.drawRect(const Rect.fromLTWH(-10, -10, 20, 20), Paint()..color=const Color(0xFF212121));
          canvas.drawRect(const Rect.fromLTWH(-10, -10, 20, 20), Paint()..color=Colors.black..style=PaintingStyle.stroke..strokeWidth=4);
      }
      canvas.restore();
    
    }

    // EXIT GATE
    if (engine.exitGate != null) {
      final center = engine.exitGate!;

      canvas.drawCircle(center, 45, Paint()..color=Colors.black);
      canvas.save(); canvas.translate(center.dx, center.dy); canvas.rotate(engine.time);
      for(int i=0; i<12; i++) {
         canvas.rotate(math.pi/6);
         Path slice = Path()..moveTo(0,0)..lineTo(15, -40)..lineTo(-15, -40)..close();
         final c = [Colors.red, Colors.yellow, Colors.blue][i%3];
         canvas.drawPath(slice, Paint()..color=c);
         canvas.drawPath(slice, Paint()..color=Colors.black..style=PaintingStyle.stroke..strokeWidth=2);
      }
      canvas.drawCircle(Offset.zero, 15, Paint()..color=Colors.white);
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
  @override bool shouldRepaint(covariant GamePainterA46 old) => true;
}
